use anyhow::{anyhow, Context, Result};
use nom::bytes::complete::{tag, take_till};
use nom::character::complete::{char, newline, space1, u64};
use nom::combinator::iterator;
use nom::sequence::{separated_pair, terminated};
use nom::{IResult, Parser};
use std::env::args;
use std::fs::read_to_string;
use tree::{Tree, arena::*};

mod tree;

#[derive(Debug)]
enum Command {
    Ls,
    Cd(String),
}

#[derive(Debug)]
enum FsData {
    File { name: String, size: usize },
    Dir { name: String, size: usize },
}

impl FsData {
    pub fn size(&self) -> usize {
        match *self {
            FsData::File { size, .. } => size,
            FsData::Dir { size, .. } => size,
        }
    }

    pub fn name(&self) -> &str {
        match self {
            FsData::File { name, .. } => name,
            FsData::Dir { name, .. } => name,
        }
    }

    pub fn is_dir(&self) -> bool {
        matches!(self, FsData::Dir { .. })
    }
}

type FsTree = ArenaTree<FsData>;

fn path(input: &str) -> IResult<&str, &str> {
    take_till(|c| c == '\n').map(Into::into).parse(input)
}

fn command(input: &str) -> IResult<&str, Command> {
    let ls_command = tag("ls").map(|_| Command::Ls);
    let cd_command =
        separated_pair(tag("cd"), space1, path).map(|(_, s): (_, &str)| Command::Cd(s.into()));
    let ls_or_cd = ls_command.or(cd_command);
    terminated(separated_pair(char('$'), space1, ls_or_cd), newline)
        .map(|(_, r)| r)
        .parse(input)
}

fn listing(input: &str) -> IResult<&str, FsData> {
    let file_listing =
        separated_pair(u64, space1, take_till(|c| c == '\n')).map(|(size, name): (_, &str)| {
            FsData::File {
                name: name.to_string(),
                size: size as usize,
            }
        });
    let dir_listing =
        separated_pair(tag("dir"), space1, take_till(|c| c == '\n')).map(|(_, name): (_, &str)| {
            FsData::Dir {
                name: name.to_string(),
                size: 0,
            }
        });
    terminated(file_listing.or(dir_listing), newline).parse(input)
}

fn command_and_output<'a, 'b>(
    arena: &'a mut FsTree,
    node: NodeId,
    input: &'b str,
) -> IResult<&'b str, NodeId> {
    let (input, cmd) = command(input)?;

    match cmd {
        Command::Ls => {
            let mut it = iterator(input, listing);
            for data in &mut it {
                arena.add_child(node, data);
            }
            let (input, _) = it.finish()?;
            Ok((input, node))
        }
        Command::Cd(dirname) if dirname == "." => Ok((input, node)),
        Command::Cd(dirname) if dirname == ".." => {
            let node = arena.parent(node).unwrap();
            Ok((input, node.id))
        }
        Command::Cd(dirname) => {
            let node = arena.get_node(node);
            let new_dir = arena
                .children(node)
                .find(|&node| node.data.name() == dirname && node.data.is_dir())
                .unwrap();
            Ok((input, new_dir.id))
        }
    }
}

fn parse_problem(input: &str) -> IResult<&str, FsTree> {
    let (mut input, _) = command(input)?;
    let mut arena = FsTree::new();

    let root = arena.new_node(
        FsData::Dir {
            name: "/".to_string(),
            size: 0,
        },
        None,
    );

    let mut ctx = root;
    while let Ok((input_, ctx_)) = command_and_output(&mut arena, ctx, input) {
        input = input_;
        ctx = ctx_;
    }

    let root = arena.get_node(NodeId(0));

    // Janky way around the borrow checker
    let tmp: Vec<_> = arena
        .postorder(root)
        .map(|node| (arena.parent(node.id).unwrap().id, node.id))
        .collect();

    let iter = tmp.into_iter();

    iter.for_each(|(parent, node)| {
        let node_size = arena.get_node(node).data.size();
        match arena.get_node_mut(parent).data {
            FsData::Dir { ref mut size, .. } => *size += node_size,
            FsData::File { ref mut size, .. } => *size += node_size,
        }
    });

    Ok((input, arena))
}

fn solve_1(input: &FsTree) -> usize {
    let root = input.get_node(NodeId(0));
    input
        .postorder(root)
        .filter_map(|node| match node.data {
            FsData::Dir { size, .. } if size <= 100000 => Some(size),
            _ => None,
        })
        .sum()
}

fn solve_2(input: &FsTree) -> usize {
    let root = input.get_node(NodeId(0));
    let space_required = 30000000 - (70000000 - root.data.size());
    input
        .postorder(root)
        .filter_map(|node| match node.data {
            FsData::Dir { size, .. } if size >= space_required => Some(size),
            _ => None,
        })
        .min()
        .unwrap()
}

fn main() -> Result<()> {
    let input = read_to_string(args().nth(1).with_context(|| "Invalid arguments")?)?;
    let (_, fs) = parse_problem(&input).map_err(|e| anyhow!("Failed to parse {}", e.to_owned()))?;

    println!("Solution for part 1: {}", solve_1(&fs));
    println!("Solution for part 2: {}", solve_2(&fs));
    Ok(())
}
