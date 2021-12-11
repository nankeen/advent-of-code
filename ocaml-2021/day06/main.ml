open Core

let input_path = (Sys.get_argv ()).(1)

let count_fishes fishes =
  let counter = Hashtbl.create ~size:9 (module Int) in
  let update_counter fish =
    Hashtbl.incr counter fish
  in
  List.iter ~f:update_counter fishes;
  counter

let time_step fishes =
  let zero_count = Hashtbl.find_or_add fishes 0 ~default:(fun _ -> 0) in
  for t = 0 to 7 do
    let next_count =
      Hashtbl.find_or_add fishes (succ t) ~default:(fun _ -> 0)
    in
    Hashtbl.set fishes ~key:t ~data:next_count
  done;
  Hashtbl.set fishes ~key:8 ~data:zero_count;
  let seven_count = Hashtbl.find_or_add fishes 6 ~default:(fun _ -> 0) in
  Hashtbl.set fishes ~key:6 ~data:(zero_count + seven_count)

let total_fishes =
  Hashtbl.fold ~init:0 ~f:(fun ~key:_ ~data acc -> acc + data)

let part_1 fishes =
  let fish_bins = count_fishes fishes in
  for _ = 1 to 80 do
    time_step fish_bins
  done;
  total_fishes fish_bins


let part_2 fishes =
  let fish_bins = count_fishes fishes in
  for _ = 1 to 256 do
    time_step fish_bins
  done;
  total_fishes fish_bins
let parse_line line = String.split ~on:',' line |> List.map ~f:int_of_string

let () =
  (* Bins of fish implemented with a map of clock -> amount *)
  let fishes = parse_line @@ List.hd_exn (In_channel.read_lines input_path) in

  (* Compute part 1 *)
  let part_1_result = part_1 fishes in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 fishes in
  Stdio.printf "Part 2 %d\n" part_2_result
