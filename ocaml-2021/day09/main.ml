open Core

module Seafloor = struct
  include Aoc_utils.Grid

  let adjacent t pos =
    neighbours t pos |> List.filter_map ~f:(get t)

end

let input_path = (Sys.get_argv ()).(1)

let part_1 seafloor =
  let open List in
  let is_lowpoint pos height =
    Seafloor.adjacent seafloor pos |> for_all ~f:(( < ) height)
  in

  Seafloor.(
    nodes seafloor
    |> fold ~init:0 ~f:(fun acc pos ->
           let height = get_exn seafloor pos in
           acc + if is_lowpoint pos height then height + 1 else 0))

(*
   Point module that implements Comparator.S so that
   tuples of integers can be used with Sets
*)
module Point = struct
  module T = struct
    type t = int * int [@@deriving sexp, compare]
  end

  include T
  include Comparable.Make (T)
end

let flood_fill seafloor pos =
  let open Seafloor in
  (* Create queue and visited set *)
  let q = Queue.create () in
  let visited = ref Point.Set.empty in

  (* Mark root as visited and put on queue *)
  visited := Set.add !visited pos;
  Queue.enqueue q pos;

  (*
    1. Dequeue frontier
    2. Get eligible neighbours
    3. Mark eligible as visited
    4. Enqueue eligible neighbours
  *)
  while not @@ Queue.is_empty q do
    let pos = Queue.dequeue_exn q in
    let height = get_exn seafloor pos in
    let eligible =
      neighbours seafloor pos
      |> List.filter ~f:(fun ad_pos -> mem seafloor ad_pos)
      |> List.filter ~f:(fun ad_pos ->
             let ad_height = get_exn seafloor ad_pos in
             (not (ad_height = 9))
             && ad_height > height
             && not (Set.mem !visited ad_pos))
    in
    List.iter
      ~f:(fun pos ->
        visited := Set.add !visited pos;
        Queue.enqueue q pos)
      eligible
  done;
  !visited

let part_2 seafloor =
  let open Seafloor in
  let open List in
  (* 1. Compute all the low points on the seafloor *)
  let is_lowpoint pos =
    let height = get_exn seafloor pos in
    adjacent seafloor pos |> for_all ~f:(Fn.flip ( > ) height)
  in

  let low_points = nodes seafloor |> filter ~f:is_lowpoint in

  (* 2. Find basins by floodfill from low point *)
  let basins =
    map low_points ~f:(fun p -> flood_fill seafloor p |> Set.length)
    |> filter ~f:(( < ) 0)
    |> sort ~compare:Int.descending
  in

  (* 3. Take top 3 basin by size *)
  take basins 3 |> fold ~init:1 ~f:( * )

let parse_line line = String.to_array line |> Array.map ~f:Char.get_digit_exn

let () =
  let seafloor =
    List.map (In_channel.read_lines input_path) ~f:parse_line |> Array.of_list
  in

  (* Compute part 1 *)
  let part_1_result = part_1 seafloor in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 seafloor in
  Stdio.printf "Part 2 %d\n" part_2_result
