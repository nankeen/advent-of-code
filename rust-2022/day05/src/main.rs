use anyhow::{anyhow, Context, Result};
use nom::bytes::complete::tag;
use nom::character::complete::{anychar, char, newline, u64};
use nom::multi::{count, many1, separated_list1};
use nom::sequence::{delimited, preceded, separated_pair, terminated, tuple};
use nom::{IResult, Parser};
use std::env::args;
use std::fs::read_to_string;

#[derive(Clone, Debug)]
struct Stack(Vec<char>);
#[derive(Debug)]
struct Move(u64, u64, u64);

fn cargo_stack(input: &str) -> IResult<&str, Vec<Stack>> {
    let cargo = delimited(char('['), anychar, char(']'));
    let three_spaces = count(char(' '), 3);
    let cargo_or_empty = cargo.map(|c| Some(c)).or(three_spaces.map(|_| None));
    let cargo_line = terminated(separated_list1(char(' '), cargo_or_empty), newline);
    let cargo_index = terminated(
        separated_list1(char(' '), delimited(char(' '), u64, char(' '))),
        newline,
    );
    let (input, res) = terminated(many1(cargo_line), cargo_index)(input)?;

    // Transpose result
    let n = res[0].len();
    let res = (0..n)
        .map(|i| res.iter().flat_map(|inner| inner[i]).rev().collect())
        .map(|s| Stack(s))
        .collect();
    Ok((input, res))
}

fn cargo_moves(input: &str) -> IResult<&str, Vec<Move>> {
    let move_line = tuple((
        preceded(tag("move "), u64),
        preceded(tag(" from "), u64),
        preceded(tag(" to "), u64),
    ))
    .map(|(n, from, to)| Move(n, from, to));

    many1(terminated(move_line, newline))(input)
}

fn parse_problem(input: &str) -> IResult<&str, (Vec<Stack>, Vec<Move>)> {
    separated_pair(cargo_stack, newline, cargo_moves)(input)
}

fn do_move1(stacks: &mut [Stack], &Move(k, from, to): &Move) {
    let from = &mut stacks[from as usize - 1];
    let n = from.0.len();
    let removed = from.0.drain(n - k as usize..).rev().collect::<Vec<_>>();
    let to = &mut stacks[to as usize - 1];
    to.0.extend_from_slice(&removed);
}

fn do_move2(stacks: &mut [Stack], &Move(k, from, to): &Move) {
    let from = &mut stacks[from as usize - 1];
    let n = from.0.len();
    let removed = from.0.drain(n - k as usize..).collect::<Vec<_>>();
    let to = &mut stacks[to as usize - 1];
    to.0.extend_from_slice(&removed);
}

fn solve_1(stacks: &[Stack], moves: &[Move]) -> String {
    let mut stacks = stacks.to_vec();

    moves.into_iter().for_each(|m| do_move1(&mut stacks, m));
    stacks
        .into_iter()
        .flat_map(|mut inner| inner.0.pop())
        .collect()
}

fn solve_2(stacks: &[Stack], moves: &[Move]) -> String {
    let mut stacks = stacks.to_vec();

    moves.into_iter().for_each(|m| do_move2(&mut stacks, m));
    stacks
        .into_iter()
        .flat_map(|mut inner| inner.0.pop())
        .collect()
}

fn main() -> Result<()> {
    let input = read_to_string(args().nth(1).with_context(|| "Invalid arguments")?)?;
    let (_, (stacks, moves)) = parse_problem(&input).map_err(|c| {
        dbg!(c);
        anyhow!("Failed to parse")
    })?;

    println!("Solution for part 1: {}", solve_1(&stacks, &moves));
    println!("Solution for part 2: {}", solve_2(&stacks, &moves));
    Ok(())
}
