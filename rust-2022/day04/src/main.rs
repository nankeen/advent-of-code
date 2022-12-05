use anyhow::{anyhow, Context, Result};
use nom::{
    character::complete::{char, digit1},
    combinator::map_res,
    sequence::separated_pair,
    IResult,
};
use std::{
    env::args,
    fs::File,
    io::{self, BufRead},
};

struct Range(u64, u64);

impl Range {
    pub fn contains(&self, b: &Self) -> bool {
        self.0 <= b.0 && self.1 >= b.1
    }

    pub fn overlaps(&self, b: &Self) -> bool {
        self.0 <= b.1 && self.1 >= b.0
    }
}

fn range(input: &str) -> IResult<&str, Range> {
    let (input, (lower, upper)) = separated_pair(
        map_res(digit1, str::parse),
        char('-'),
        map_res(digit1, str::parse),
    )(input)?;
    Ok((input, Range(lower, upper)))
}

fn assignment(input: &str) -> IResult<&str, (Range, Range)> {
    separated_pair(range, char(','), range)(&input)
}

fn solve_1(assignments: &[(Range, Range)]) -> usize {
    assignments
        .iter()
        .filter(|(a, b)| a.contains(b) || b.contains(a))
        .count()
}

fn solve_2(assignments: &[(Range, Range)]) -> usize {
    assignments
        .iter()
        .filter(|(a, b)| a.overlaps(b))
        .count()
}

fn main() -> Result<()> {
    let file = File::open(args().nth(1).ok_or_else(|| anyhow!("Invalid arguments"))?)?;
    let assignments: Vec<_> = io::BufReader::new(file)
        .lines()
        .map(|s| {
            s.with_context(|| "Cannot read line from file")
                .and_then(|s| Ok(assignment(&s).map_err(|_| anyhow!("Failed to parse"))?.1))
        })
        .collect::<Result<_>>()?;

    println!("Solution for part 1: {}", solve_1(&assignments));
    println!("Solution for part 2: {}", solve_2(&assignments));
    Ok(())
}
