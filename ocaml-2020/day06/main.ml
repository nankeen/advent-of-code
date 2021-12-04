open Core

let input_path = (Sys.get_argv ()).(1)

type group = { mutable answers : char list list }

let questions_answered { answers } =
  List.(
    map answers ~f:(Set.of_list (module Char))
    |> fold ~init:(Set.empty (module Char)) ~f:Set.union)

let questions_all_answered { answers } =
  match List.map answers ~f:(Set.of_list (module Char)) with
  | x :: xs -> List.fold xs ~init:x ~f:Set.inter
  | _ -> failwith "Empty group"

let part_1 groups =
  List.(
    map ~f:questions_answered groups
    |> map ~f:Set.length
    |> sum (module Int) ~f:ident)

let part_2 groups =
  List.(
    map ~f:questions_all_answered groups
    |> map ~f:Set.length
    |> sum (module Int) ~f:ident)

let parse_input =
  let rec loop g = function
    | "" :: xs -> g :: loop { answers = [] } xs
    | line :: xs ->
        g.answers <- String.to_list line :: g.answers;
        loop g xs
    | [] -> [ g ]
  in
  loop { answers = [] }

let () =
  let group_inputs = parse_input @@ In_channel.read_lines input_path in

  (* Compute part 1 *)
  let part_1_result = part_1 group_inputs in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 group_inputs in
  Stdio.printf "Part 2 %d\n" part_2_result
