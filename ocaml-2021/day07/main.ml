open Core

let input_path = (Sys.get_argv ()).(1)

let rec fuel_cost dest = function
  | crab :: crabs -> abs (dest - crab) + fuel_cost dest crabs
  | [] -> 0

let part_1 crabs =
  let median xs =
    let sorted_xs = List.sort ~compare:Poly.compare xs in
    let n = List.length xs in
    let median_idx = n / 2 in
    List.nth_exn sorted_xs median_idx
  in
  let position = median crabs in
  fuel_cost position crabs

let part_2 crabs =
  let crab_cost x =
    List.fold crabs ~init:0 ~f:(fun acc e ->
        let c = abs (e - x) in
        acc + (c * (c + 1) / 2))
  in
  let max_crab = Option.value_exn @@ List.max_elt crabs ~compare:Poly.compare in
  Sequence.(map ~f:crab_cost (range 0 max_crab)
  |> min_elt ~compare:Poly.compare)
  |> Option.value_exn

let parse_input line =
  String.strip line |> String.split ~on:',' |> List.map ~f:int_of_string

let () =
  let lines = parse_input @@ In_channel.read_all input_path in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  printf "Part 2 %d\n" part_2_result
