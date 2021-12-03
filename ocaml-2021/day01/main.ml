open Core

let input_path = (Sys.get_argv ()).(1)

(* `part_1` counts the number of increases in the measurements *)
let part_1 = function
  | first :: measurements ->
      let n, _ =
        List.fold measurements ~init:(0, first) ~f:(fun (n, last) current ->
            if current > last then (n + 1, current) else (n, current))
      in
      n
  | _ -> 0

(* `windows` creates a sliding window of size `n` on a given list *)
let rec windows n = function
  | x :: xs ->
      let open List in
      let window = take (x :: xs) n in
      if length window < n then [] else window :: windows n xs
  | _ -> []

(* `part_2` counts the number of increases in a sliding window of size 3 *)
let part_2 measurements =
  windows 3 measurements |> List.(map ~f:(fold ~init:0 ~f:( + ))) |> part_1

let () =
  let lines = (List.map @@ In_channel.read_lines input_path) ~f:int_of_string in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  Stdio.printf "Part 1: %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  Stdio.printf "Part 2: %d\n" part_2_result
