use anyhow::{anyhow, bail, Result};
use std::{
    collections::{BTreeSet, HashSet},
    env::args,
    fs::File,
    io::{self, BufRead},
};

#[derive(PartialEq, PartialOrd, Eq, Ord, Hash)]
struct Item(u8);

struct Rucksack(Vec<Item>);

impl Item {
    pub fn new(c: char) -> Result<Self> {
        match c {
            c if c.is_lowercase() => Ok(Self((c as u8) - b'a' + 1)),
            c if c.is_uppercase() => Ok(Self((c as u8) - b'A' + 27)),
            c => bail!("invalid character {} for Item", c),
        }
    }
}

impl Rucksack {
    pub fn new(s: String) -> Result<Self> {
        Ok(Self(s.chars().map(Item::new).collect::<Result<_>>()?))
    }

    fn left(&self) -> &'_ [Item] {
        &self.0[..(self.0.len() / 2)]
    }

    fn right(&self) -> &'_ [Item] {
        &self.0[(self.0.len() / 2)..]
    }

    pub fn find_repeated_sum(&self) -> u64 {
        self.left()
            .iter()
            .collect::<BTreeSet<_>>()
            .intersection(&self.right().iter().collect())
            .map(|p| p.0 as u64)
            .sum()
    }

    pub fn find_types(&self) -> HashSet<&'_ Item> {
        self.0.iter().collect()
    }
}

fn solve_1(rucksacks: &[Rucksack]) -> u64 {
    rucksacks.iter().map(Rucksack::find_repeated_sum).sum()
}

fn solve_2(rucksacks: &[Rucksack]) -> u64 {
    rucksacks
        .iter()
        .map(Rucksack::find_types)
        .collect::<Vec<_>>()
        .chunks(3)
        .flat_map(|chunk| {
            let mut intersect = chunk[0].clone();
            intersect.retain(|e| chunk[1..].iter().all(|x| x.contains(e)));
            intersect
        })
        .map(|p| p.0 as u64)
        .sum()
}

fn main() -> Result<()> {
    let file = File::open(args().nth(1).ok_or_else(|| anyhow!("Invalid arguments"))?)?;
    let rucksacks: Vec<_> = io::BufReader::new(file)
        .lines()
        .map(|s| s.map_err(Into::into).and_then(Rucksack::new))
        .collect::<Result<_>>()?;

    println!("Solution for part 1: {}", solve_1(&rucksacks));
    println!("Solution for part 2: {}", solve_2(&rucksacks));
    Ok(())
}
