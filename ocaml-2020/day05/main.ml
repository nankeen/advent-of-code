open Core

let input_path = (Sys.get_argv ()).(1)

type row = Front | Back

type column = Left | Right

type index = { rows : row list; cols : column list }

let seat_idx ({ cols; rows } : index) : int * int =
  let bsp_col (start, stop) col =
    match col with
    | Left -> (start, start + ((stop - start) / 2))
    | Right -> (start + ((stop - start) / 2), stop)
  in
  let col_idx, _ = List.fold cols ~f:bsp_col ~init:(0, 8) in
  let bsp_row (start, stop) row =
    match row with
    | Front -> (start, start + ((stop - start) / 2))
    | Back -> (start + ((stop - start) / 2), stop)
  in
  let row_idx, _ = List.fold rows ~f:bsp_row ~init:(0, 128) in
  (row_idx, col_idx)

let seat_id (idx : index) : int =
  let row_idx, col_idx = seat_idx idx in
  (row_idx * 8) + col_idx

let part_1 indexes =
  let open List in
  let seat_ids = map indexes ~f:seat_id in
  match seat_ids with
  | x :: xs -> fold xs ~init:x ~f:max
  | [] -> failwith "No seat ids provided in part 1"

let part_2 indexes =
  let open List in
  let find_gap prev current =
    let open Continue_or_stop in
    if current - prev <= 1 then Continue current else Stop (current - 1)
  in
  let seat_ids = map indexes ~f:seat_id |> sort ~compare:Poly.compare in
  match seat_ids with
  | x :: xs -> fold_until xs ~finish:ident ~init:x ~f:find_gap
  | [] -> failwith "No seat ids provided in part 2"

let parse_line (line : string) : index =
  let parse_row = function
    | 'F' -> Front
    | 'B' -> Back
    | _ -> failwith "Bad row input"
  in
  let parse_col = function
    | 'L' -> Left
    | 'R' -> Right
    | _ -> failwith "Bad col input"
  in
  let line = String.to_list line in
  let rows = List.(take line 7 |> map ~f:parse_row) in
  let cols = List.(drop line 7 |> map ~f:parse_col) in

  { rows; cols }

let () =
  let lines = List.map (In_channel.read_lines input_path) ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  printf "Part 1: %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  printf "Part 2: %d\n" part_2_result
