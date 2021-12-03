open Core

let input_path = (Sys.get_argv ()).(1)

let part_1 _ = failwith "Not implemented"

let part_2 _ = failwith "Not implemented"

let parse_line _ = failwith "Not implemented"

let () =
  let lines = List.map (In_channel.read_lines input_path) ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  Stdio.printf "Part 1 %s\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  Stdio.printf "Part 2 %s\n" part_2_result
