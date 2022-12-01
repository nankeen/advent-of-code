open Core

let input_path = (Sys.get_argv ()).(1)
let part_1 _ = raise_s [%message "Not implemented"]
let part_2 _ = raise_s [%message "Not implemented"]
let parse_line _ = raise_s [%message "Not implemented"]

let () =
  let input = In_channel.read_lines input_path |> List.map ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  print_s [%message (part_1_result : string)];

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  print_s [%message (part_2_result : string)]
