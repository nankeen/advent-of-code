open Core

let input_path = (Sys.get_argv ()).(1)

module Grid = struct
  include Aoc_utils.Grid

  let neighbours t (x, y) =
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
    |> List.filter ~f:(mem t)

  let rec advance_point t p =
    let x, y = p in
    let life = t.(y).(x) in
    t.(y).(x) <- life + 1;
    flash t p (life + 1)

  and flash board p life =
    if life = 10 then
      (* Update board *)
      ignore
        (neighbours board p |> List.map ~f:(advance_point board)
          : 'a list)

  let advance_all t =
    (* Advance and flash *)
    nodes t |> List.fold ~init:() ~f:(fun _ p -> advance_point t p)

  let reset_flashed t =
    let reset_point flashed p =
      let x, y = p in
      if t.(y).(x) > 9 then (
        t.(y).(x) <- 0;
        flashed + 1)
      else flashed
    in

    nodes t |> List.fold ~init:0 ~f:reset_point
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
