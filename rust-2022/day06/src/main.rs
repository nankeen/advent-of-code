use anyhow::{Context, Result};
use itertools::Itertools;
use std::{env::args, fs::read_to_string};

fn solve_1(input: &str) -> usize {
    (0..input.len() - 4)
        .find(|&i| input[i..i + 4].chars().all_unique())
        .unwrap()
        + 4
}

fn solve_2(input: &str) -> usize {
    (0..input.len() - 14)
        .find(|&i| input[i..i + 14].chars().all_unique())
        .unwrap()
        + 14
}

fn main() -> Result<()> {
    let input = read_to_string(args().nth(1).with_context(|| "Invalid arguments")?)?;

    println!("Solution for part 1: {}", solve_1(&input));
    println!("Solution for part 2: {}", solve_2(&input));
    Ok(())
}
