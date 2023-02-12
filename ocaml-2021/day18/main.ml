open Core
open Aoc2021_day18.Snailfish_number

let input_path = (Sys.get_argv ()).(1)
let part_1 input = List.reduce ~f:( +. ) input |> Option.value_exn |> magnitude

let comb lst =
  let rec loop = function
    | hd :: tl -> List.map ~f:(fun e -> [(hd, e); (e, hd)]) tl :: loop tl
    | [] -> []
  in
  loop lst |> List.concat |> List.concat

let part_2 input =
  comb input
  |> List.map ~f:(fun (a, b) -> a +. b)
  |> List.map ~f:magnitude
  |> List.max_elt ~compare:Int.compare
  |> Option.value_exn

let parse_line line =
  Angstrom.parse_string ~consume:All parse line |> Result.ok_or_failwith

let () =
  let input = In_channel.read_lines input_path |> List.map ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  printf "Part 2 %d\n" part_2_result
