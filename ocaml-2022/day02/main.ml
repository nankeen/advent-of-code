open Core
open Angstrom

module Outcome = struct
  type t = Win | Draw | Lose [@@deriving sexp]

  let points = function Win -> 6 | Draw -> 3 | Lose -> 0
end

module Shape = struct
  type t = Rock | Paper | Scissors [@@deriving sexp]

  let parse =
    let* c = any_char in
    match c with
    | 'A' | 'X' -> return Rock
    | 'B' | 'Y' -> return Paper
    | 'C' | 'Z' -> return Scissors
    | c' -> fail [%string "invalid shape: %{Char.to_string c'}"]

  let points = function Rock -> 1 | Paper -> 2 | Scissors -> 3

  let to_outcome = function
    | Rock -> Outcome.Lose
    | Paper -> Draw
    | Scissors -> Win

  let ( ^ ) a b =
    match (a, b) with
    | Rock, Paper | Paper, Scissors | Scissors, Rock -> Outcome.Win
    | Paper, Rock | Scissors, Paper | Rock, Scissors -> Lose
    | _, _ -> Draw

  let ( ^+ ) a b =
    match (a, b) with
    | Rock, Outcome.Draw | Paper, Lose | Scissors, Win -> Rock
    | Paper, Draw | Scissors, Lose | Rock, Win -> Paper
    | Scissors, Draw | Rock, Lose | Paper, Win -> Scissors
end

module Strategy = struct
  type t = Shape.t * Shape.t [@@deriving sexp]

  let parse =
    let* opponent = Shape.parse <* char ' ' in
    let+ player = Shape.parse in
    (opponent, player)

  let points (opponent, player) =
    Shape.(points player + Outcome.points (opponent ^ player))

  let points' (opponent, player) =
    Shape.(
      let outcome = to_outcome player in
      (opponent ^+ outcome |> points) + Outcome.points outcome)
end

let input_path = (Sys.get_argv ()).(1)
let parse = many (Strategy.parse <* (end_of_line <|> end_of_input))
let part_1 = List.sum (module Int) ~f:Strategy.points
let part_2 = List.sum (module Int) ~f:Strategy.points'

let () =
  let input =
    In_channel.read_all input_path
    |> parse_string ~consume:Prefix parse
    |> Result.ok_or_failwith
  in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  print_s [%message (part_1_result : int)];

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  print_s [%message (part_2_result : int)]
