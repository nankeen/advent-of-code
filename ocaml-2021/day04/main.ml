open Core

type board_entry = Marked of int | Unmarked of int [@@deriving show]

type board = { mutable rows : board_entry list list } [@@deriving show]

let rec check_row = function
  | Marked _ :: xs -> true && check_row xs
  | Unmarked _ :: _ -> false
  | [] -> true

let check_board { rows } =
  let check_rows rows = Option.is_some @@ List.find rows ~f:check_row in
  check_rows rows || (check_rows @@ Option.value_exn @@ List.transpose rows)

let mark_board x { rows } =
  let mark_row =
    List.map ~f:(function Unmarked e when e = x -> Marked x | e -> e)
  in
  { rows = List.map ~f:mark_row rows }

let board_score { rows } =
  List.sum
    (module Int)
    rows
    ~f:(List.sum (module Int) ~f:(function Unmarked e -> e | _ -> 0))

let input_path = (Sys.get_argv ()).(1)

let rec first_winning_board boards = function
  | [] -> failwith "No winning boards found!"
  | d :: ds -> (
      let new_boards = List.map boards ~f:(mark_board d) in
      match List.find ~f:check_board new_boards with
      | Some winning_board -> (d, winning_board)
      | None -> first_winning_board new_boards ds)

let last_winning_board =
  let rec loop acc boards = function
    | [] -> Option.value_exn acc
    | d :: ds -> (
        let new_boards = List.map boards ~f:(mark_board d) in
        let w_board = List.find ~f:check_board new_boards in
        let new_boards_filtered =
          List.filter ~f:(fun x -> not @@ check_board x) new_boards
        in
        match w_board with
        | Some b -> loop (Some (d, b)) new_boards_filtered ds
        | None -> loop acc new_boards_filtered ds)
  in
  loop None

let part_1 boards draws =
  let w_draw, w_board = first_winning_board boards draws in
  board_score w_board * w_draw

let part_2 boards draws =
  let w_draw, w_board = last_winning_board boards draws in
  board_score w_board * w_draw

let parse_input =
  let parse_draws line =
    String.split ~on:',' line |> List.map ~f:int_of_string
  in
  let parse_boards =
    let parse_board_line line =
      String.split ~on:' ' line
      |> List.filter ~f:(fun x -> not @@ String.is_empty x)
      |> List.map ~f:(fun x -> Unmarked (int_of_string x))
    in
    let rec loop b = function
      | "" :: xs -> b :: loop { rows = [] } xs
      | line :: xs ->
          b.rows <- parse_board_line line :: b.rows;
          loop b xs
      | [] -> [ b ]
    in
    loop { rows = [] }
  in
  function
  | draw :: boards -> (parse_draws draw, parse_boards boards)
  | [] -> failwith "Empty input"

let () =
  let draws, boards = parse_input @@ In_channel.read_lines input_path in

  (* Compute part 1 *)
  let part_1_result = part_1 boards draws in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 boards draws in
  Stdio.printf "Part 2 %d\n" part_2_result
