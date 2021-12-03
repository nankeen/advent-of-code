open Core

let input_path = (Sys.get_argv ()).(1)

type movement = Forward of int | Down of int | Up of int

let part_1 =
  let move (horizontal, depth) = function
    | Forward n -> (horizontal + n, depth)
    | Down n -> (horizontal, depth + n)
    | Up n -> (horizontal, depth - n)
  in
  List.fold ~init:(0, 0) ~f:move

let part_2 movements =
  let move (horizontal, depth, aim) = function
    | Forward n -> (horizontal + n, depth + (aim * n), aim)
    | Down n -> (horizontal, depth, aim + n)
    | Up n -> (horizontal, depth, aim - n)
  in
  let horizontal, depth, _ = movements |> List.fold ~init:(0, 0, 0) ~f:move in
  (horizontal, depth)

let parse_line (line : string) : movement =
  let line = String.split ~on:' ' line in
  match line with
  | [ "forward"; n ] -> Forward (int_of_string n)
  | [ "down"; n ] -> Down (int_of_string n)
  | [ "up"; n ] -> Up (int_of_string n)
  | _ -> failwith "Bad input"

let () =
  let lines = (In_channel.read_lines input_path |> List.map) ~f:parse_line in

  (* Compute part 1 *)
  let horizontal, depth = part_1 lines in
  Stdio.printf "Part 1 - horizontal: %d depth: %d answer: %d\n" horizontal depth
    (horizontal * depth);

  (* Compute part 2 *)
  let horizontal, depth = part_2 lines in
  Stdio.printf "Part 2 - horizontal: %d depth: %d answer: %d\n" horizontal depth
    (horizontal * depth)
