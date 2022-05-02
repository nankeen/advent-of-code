open Core

let input_path = (Sys.get_argv ()).(1)

let line_points ((x1, y1), (x2, y2)) =
  let range ~start ~len = List.init (len + 1) ~f:(fun x -> x + start) in

  let dx = abs (x1 - x2) and dy = abs (y1 - y2) in
  let startx, starty = (min x1 x2, min y1 y2) in

  let xs = range ~start:startx ~len:dx in
  let ys = range ~start:starty ~len:dy in

  if dx > 0 && dy > 0 then
    if (x1 - x2 >= 0 && y1 - y2 >= 0) || (x1 - x2 < 0 && y1 - y2 < 0) then
      List.map2_exn xs ys ~f:(fun x y -> (x, y))
    else List.map2_exn (List.rev xs) ys ~f:(fun x y -> (x, y))
  else if dx > 0 then List.map xs ~f:(fun x -> (x, starty))
  else List.map ys ~f:(fun y -> (startx, y))

let count_crossing lines =
  let lin_space = Array.init 1024 ~f:(fun _ -> Array.create ~len:1024 0) in
  List.iter lines ~f:(fun line ->
      let points = line_points line in
      List.iter points ~f:(fun (x, y) ->
          lin_space.(x).(y) <- lin_space.(x).(y) + 1));
  Array.map ~f:(Array.count ~f:(fun x -> x > 1)) lin_space |> Array.sum (module Int) ~f:Fn.id

let part_1 lines =
  List.filter ~f:(fun ((x1, y1), (x2, y2)) -> x1 = x2 || y1 = y2) lines
  |> count_crossing

let part_2 = count_crossing

let parse_line line =
  let parse_point p =
    let coords = String.split ~on:',' p |> List.map ~f:int_of_string in
    match coords with
    | [ x; y ] -> (x, y)
    | _ -> failwith "Expected only two intergers for point"
  in
  match String.split ~on:' ' line with
  | [ start; _; stop ] -> (parse_point start, parse_point stop)
  | _ -> failwith "Invalid format"

let () =
  let lines =
    List.map (In_channel.read_lines input_path) ~f:parse_line
    |> List.sort ~compare:Poly.compare
  in

  (* Compute part 1 *)
  let part_1_result = part_1 lines in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 lines in
  Stdio.printf "Part 2 %d\n" part_2_result
