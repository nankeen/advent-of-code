open Core

module Seafloor = struct
  type t = int array array

  let bounds seafloor =
    let ybounds = Array.length seafloor in
    let xbounds = Array.length seafloor.(0) in
    (xbounds, ybounds)

  let contains seafloor (x, y) =
    let xbounds, ybounds = bounds seafloor in
    x >= 0 && x < xbounds && y >= 0 && y < ybounds

  let get seafloor (x, y) =
    if contains seafloor (x, y) then Some seafloor.(y).(x) else None

  let get_exn seafloor pos = Option.value_exn (get seafloor pos)

  let neighbour_idxs (x, y) =
    Sequence.Generator.(
      run
        ( yield (x + 1, y) >>= fun () ->
          yield (x - 1, y) >>= fun () ->
          yield (x, y + 1) >>= fun () ->
          yield (x, y - 1) >>= fun () -> return () ))

  let adjacent seafloor pos =
    neighbour_idxs pos |> Sequence.filter_map ~f:(get seafloor)

  let iteri seafloor =
    let open Sequence.Generator in
    let n = Array.length seafloor in
    let m = Array.length seafloor.(0) in
    let rec loop (x, y) =
      if y >= n then return ()
      else
        yield (x, y) >>= fun () ->
        if x >= m - 1 then loop (0, y + 1) else loop (x + 1, y)
    in
    loop (0, 0) |> run
end

let input_path = (Sys.get_argv ()).(1)

let part_1 seafloor =
  let open Sequence in
  let is_lowpoint pos height =
    Seafloor.adjacent seafloor pos |> for_all ~f:(( < ) height)
  in

  Seafloor.(
    iteri seafloor
    |> fold ~init:0 ~f:(fun acc pos ->
           let height = get_exn seafloor pos in
           acc + if is_lowpoint pos height then height + 1 else 0))

(* 
 Point module that implements Comparator.S so that
 tuples of integers can be used with Sets
*)
module Point = struct
  module T = struct
    type t = int * int [@@deriving sexp_of, compare]
  end

  include T
  include Comparator.Make (T)
end

let flood_fill seafloor pos =
  let open Sequence in
  let open Seafloor in
  (* Create queue and visited set *)
  let q = Queue.create () in
  let visited = ref @@ Set.empty (module Point) in

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
      neighbour_idxs pos
      |> filter ~f:(fun ad_pos -> contains seafloor ad_pos)
      |> filter ~f:(fun ad_pos ->
             let ad_height = get_exn seafloor ad_pos in
             (not (ad_height = 9))
             && ad_height > height
             && not (Set.mem !visited ad_pos))
    in
    iter
      ~f:(fun pos ->
        visited := Set.add !visited pos;
        Queue.enqueue q pos)
      eligible
  done;
  !visited

let part_2 seafloor =
  let open Sequence in
  let open Seafloor in
  (* 1. Compute all the low points on the seafloor *)
  let is_lowpoint pos =
    let height = get_exn seafloor pos in
    adjacent seafloor pos |> for_all ~f:(Fn.flip ( > ) height)
  in

  let low_points = iteri seafloor |> filter ~f:is_lowpoint in

  (* 2. Find basins by floodfill from low point *)
  let basins =
    map low_points ~f:(fun p -> flood_fill seafloor p |> Set.length)
    |> filter ~f:(( < ) 0)
    |> to_array
  in

  (* 3. Take top 3 basin by size *)
  Array.sort basins ~compare:(fun a b -> Int.compare b a);
  take (basins |> Array.to_sequence) 3 |> fold ~init:1 ~f:( * )

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
