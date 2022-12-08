use anyhow::{anyhow, Context, Result};
use std::{
    env::args,
    fs::read_to_string,
};
use nom::IResult;

type Input = Vec<String>;

fn parse_problem(_input: &str) -> IResult<&str, Input> {
    unimplemented!("parse not implemented")
}

fn solve_1(_input: &Input) -> usize {
    unimplemented!("solve_1 not implemented")
}

fn solve_2(_input: &Input) -> usize {
    unimplemented!("solve_2 not implemented")
}

fn main() -> Result<()> {
    let input = read_to_string(args().nth(1).with_context(|| "Invalid arguments")?)?;
    let (_, input) = parse_problem(&input).map_err(|_| {
        anyhow!("Failed to parse")
    })?;

    println!("Solution for part 1: {}", solve_1(&input));
    println!("Solution for part 2: {}", solve_2(&input));
    Ok(())
}
