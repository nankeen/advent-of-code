use anyhow::{anyhow, Context, Result};
use std::{
    env::args,
    fs::File,
    io::{self, BufRead},
};

type Input = Vec<String>;

fn solve_1(_input: &Input) -> usize {
    unimplemented!("solve_1 not implemented")
}

fn solve_2(_input: &Input) -> usize {
    unimplemented!("solve_2 not implemented")
}

fn main() -> Result<()> {
    let file = File::open(args().nth(1).ok_or_else(|| anyhow!("Invalid arguments"))?)?;
    let input: Input = io::BufReader::new(file)
        .lines()
        .map(|s| s.with_context(|| "Could not read line from file"))
        // .map(|s| s.and_then(|s| Ok(assignment(&s).map_err(|_| anyhow!("Failed to parse"))?.1)))
        .collect::<Result<_>>()?;

    println!("Solution for part 1: {}", solve_1(&input));
    println!("Solution for part 2: {}", solve_2(&input));
    Ok(())
}
