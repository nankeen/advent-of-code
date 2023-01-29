use anyhow::{anyhow, Context, Result};
use itertools::Itertools;
use nom::character::complete::{newline, satisfy};
use nom::multi::many1;
use nom::sequence::terminated;
use nom::{IResult, Parser};
use std::{env::args, fs::read_to_string};

fn parse_problem(input: &str) -> IResult<&str, Vec<Vec<u32>>> {
    let line = terminated(
        many1(satisfy(|c| char::is_digit(c, 10)).map(|c| char::to_digit(c, 10).unwrap())),
        newline,
    );
    many1(line).parse(input)
}

fn solve_1(input: &[Vec<u32>]) -> usize {
    let n = input.len();
    let m = input[0].len();

    let is_visible = |&(x, y): &(usize, usize)| {
        let height = input[y][x];

        let up = (0..y).all(|y| input[y][x] < height);
        let down = (y + 1..n).all(|y| input[y][x] < height);
        let left = (0..x).all(|x| input[y][x] < height);
        let right = (x + 1..m).all(|x| input[y][x] < height);

        left || right || up || down
    };

    let inner_visible = (1..n - 1).cartesian_product(1..m - 1).filter(is_visible);

    let perimeter = 2 * m + 2 * n - 4;

    inner_visible.count() + perimeter
}

fn solve_2(input: &[Vec<u32>]) -> usize {
    let n = input.len();
    let m = input[0].len();

    let scenic_score = |(x, y): (usize, usize)| {
        let height = input[y][x];

        let mut up = 0;
        for y in (0..y).rev() {
            up += 1;
            if input[y][x] >= height {
                break;
            }
        }

        let mut down = 0;
        for y in y + 1..n {
            down += 1;
            if input[y][x] >= height {
                break;
            }
        }

        let mut left = 0;
        for x in (0..x).rev() {
            left += 1;
            if input[y][x] >= height {
                break;
            }
        }

        let mut right = 0;
        for x in x + 1..m {
            right += 1;
            if input[y][x] >= height {
                break;
            }
        }

        up * down * left * right
    };

    (0..n)
        .cartesian_product(0..m)
        .map(scenic_score)
        .max()
        .expect("Empty input")
}

fn main() -> Result<()> {
    let input = read_to_string(args().nth(1).with_context(|| "invalid arguments")?)?;
    let (_, input) = parse_problem(&input).map_err(|_| anyhow!("failed to parse"))?;

    println!("Solution for part 1: {}", solve_1(&input));
    println!("Solution for part 2: {}", solve_2(&input));
    Ok(())
}
