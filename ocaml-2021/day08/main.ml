open Core

let input_path = (Sys.get_argv ()).(1)

let part_1 =
  let count_line (_, output) =
    List.count
      ~f:(fun s ->
        let n = String.length s in
        n = 2 || n = 4 || n = 7 || n = 3)
      output
  in
  List.sum (module Int) ~f:count_line

(* This part is a monstrosity I know, and I hate myself for writing this *)
let part_2 lines =
  let sort s =
    String.to_list s |> List.sort ~compare:Poly.compare |> String.of_char_list
  in
  let map_signals digits =
    let has_count count s = String.length s = count in
    let find_unique_lengths signals =
      let one, four, seven, eight =
        List.fold ~init:(None, None, None, None)
          ~f:(fun (one, four, seven, eight) signal ->
            match String.length signal with
            | 2 -> (Some signal, four, seven, eight)
            | 4 -> (one, Some signal, seven, eight)
            | 3 -> (one, four, Some signal, eight)
            | 7 -> (one, four, seven, Some signal)
            | _ -> (one, four, seven, eight))
          signals
      in
      ( Option.value_exn one,
        Option.value_exn four,
        Option.value_exn seven,
        Option.value_exn eight )
    in
    let has_segments segments signal =
      String.for_all ~f:(String.contains signal) segments
    in
    let one, four, seven, eight = find_unique_lengths digits in
    let nine =
      List.find_exn
        ~f:(fun s -> has_count 6 s && has_segments (one ^ four) s)
        digits
    in
    let six =
      List.find_exn
        ~f:(fun s -> has_count 6 s && not (has_segments one s))
        digits
    in
    let zero =
      List.find_exn
        ~f:(fun s ->
          has_count 6 s && (not (has_segments four s)) && has_segments one s)
        digits
    in
    let three =
      List.find_exn ~f:(fun s -> has_count 5 s && has_segments one s) digits
    in
    let four_diff_one =
      String.filter ~f:(fun s -> not @@ String.contains one s) four
    in
    let two =
      List.find_exn
        ~f:(fun s ->
          has_count 5 s
          && (not (has_segments four_diff_one s))
          && not (has_segments one s))
        digits
    in
    let five =
      List.find_exn
        ~f:(fun s -> has_count 5 s && has_segments four_diff_one s)
        digits
    in
    List.map
      ~f:(fun (k, v) -> (sort k, v))
      [
        (zero, 0);
        (one, 1);
        (two, 2);
        (three, 3);
        (four, 4);
        (five, 5);
        (six, 6);
        (seven, 7);
        (eight, 8);
        (nine, 9);
      ]
    |> Map.of_alist_exn (module String)
  in
  let output_line (signals, digits) =
    let signals_map = map_signals signals in
    Sequence.(
      of_list digits |> map ~f:sort
      |> map ~f:(fun s -> Map.find_exn signals_map s)
      |> fold ~init:0 ~f:(fun acc x -> (acc * 10) + x))
  in

  List.sum (module Int) ~f:output_line lines

let parse_line line =
  let signals, outputs =
    match String.split ~on:'|' line with
    | [ signals; outputs ] -> (signals, outputs)
    | _ -> failwith "Bad input format"
  in
  let signals =
    String.split ~on:' ' signals
    |> List.filter ~f:(fun s -> not @@ String.is_empty s)
  in
  let outputs =
    String.split ~on:' ' outputs
    |> List.filter ~f:(fun s -> not @@ String.is_empty s)
  in
  (signals, outputs)

let () =
  let lines = List.map (In_channel.read_lines input_path) ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  Stdio.printf "Part 2 %d\n" part_2_result
