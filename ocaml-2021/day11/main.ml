open Core

let input_path = (Sys.get_argv ()).(1)

type point = int * int [@@deriving show]

module Grid = struct
  type t = int array array [@@deriving show]

  let contains board (x, y) =
    let n, m = Array.(length board, length board.(0)) in
    x < m && x >= 0 && y >= 0 && y < n

  let get_neighbourhood_idxs board ((x, y) : point) : point list =
    [
      (x + 1, y + 1);
      (x + 1, y - 1);
      (x - 1, y - 1);
      (x - 1, y + 1);
      (x, y - 1);
      (x, y + 1);
      (x - 1, y);
      (x + 1, y);
    ]
    |> List.filter ~f:(contains board)

  let get board (x, y) =
    if contains board (x, y) then Some board.(y).(x) else None

  let get_exn board (x, y) = board.(y).(x)

  let get_neighbourhood board pos =
    get_neighbourhood_idxs board pos |> List.filter_map ~f:(get board)

  let iteri board =
    let open Sequence.Generator in
    let n, m = Array.(length board, length board.(0)) in
    let rec loop (x, y) =
      if y >= n then return ()
      else
        yield (x, y) >>= fun () ->
        if x < m - 1 then loop (x + 1, y) else loop (0, y + 1)
    in
    loop (0, 0) |> run

  let rec advance_point board p =
    let x, y = p in
    let life = board.(y).(x) in
    board.(y).(x) <- life + 1;
    flash board p (life + 1)

  and flash board p life =
    if life = 10 then
      (* Update board *)
      ignore
        (get_neighbourhood_idxs board p |> List.map ~f:(advance_point board)
          : 'a list)

  let advance_all board =
    (* Advance and flash *)
    iteri board |> Sequence.fold ~init:() ~f:(fun _ p -> advance_point board p)

  let reset_flashed board =
    let reset_point flashed p =
      let x, y = p in
      if board.(y).(x) > 9 then (
        board.(y).(x) <- 0;
        flashed + 1)
      else flashed
    in

    iteri board |> Sequence.fold ~init:0 ~f:reset_point
end

let part_1 board =
  let rec loop total = function
    | 100 -> total
    | i ->
        Grid.advance_all board;
        loop (total + Grid.reset_flashed board) (i + 1)
  in
  loop 0 0

let part_2 board =
  let board_length = Array.length board * Array.length board.(0) in
  let rec loop i n_flashed =
    if n_flashed = board_length then i
    else (
      Grid.advance_all board;
      loop (i + 1) (Grid.reset_flashed board))
  in
  loop 0 0

let parse_line line = String.to_array line |> Array.map ~f:Char.get_digit_exn

let () =
  let input =
    In_channel.read_lines input_path |> List.map ~f:parse_line |> Array.of_list
  in
  let board_copy = Array.copy_matrix input in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 board_copy in
  Stdio.printf "Part 2 %d\n" part_2_result
