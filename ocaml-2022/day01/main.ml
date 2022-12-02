open Core
open Angstrom

module Elf = struct
  type t = int list [@@deriving sexp]

  let parse =
    many1 (take_while1 Char.is_digit >>| int_of_string <* end_of_line)
    <* (end_of_line <|> end_of_input)

  let total_calories = List.sum (module Int) ~f:Fn.id
end

let input_path = (Sys.get_argv ()).(1)

let part_1 elves =
  List.(map ~f:Elf.total_calories elves |> max_elt ~compare:Int.compare)

let part_2 elves =
  List.(
    let sorted = map ~f:Elf.total_calories elves |> sort ~compare:(Int.descending) in
    take sorted 3 |> List.sum (module Int) ~f:Fn.id)

let parse_problem = many1 Elf.parse

let () =
  let input =
    In_channel.read_all input_path
    |> parse_string ~consume:Prefix parse_problem
    |> Result.ok_or_failwith
  in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  print_s [%message (part_1_result : int option)];

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  print_s [%message (part_2_result : int)]
