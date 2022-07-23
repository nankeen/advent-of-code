open Core

module Graph = struct
  type 'a t = { nodes : 'a list; edges : ('a * 'a) list } [@@deriving show]

  let of_list edges =
    let rec loop = function
      | (n1, n2) :: es -> n1 :: n2 :: loop es
      | [] -> []
    in
    { nodes = loop edges; edges }

  let neighbours ~equal graph node =
    let neighbour ns (n1, n2) =
      if equal n1 node then n2 :: ns else if equal n2 node then n1 :: ns else ns
    in
    List.fold graph.edges ~init:[] ~f:neighbour
end

let input_path = (Sys.get_argv ()).(1)

module Cave = struct
  module T = struct
    type t = Big of string | Small of string[@@deriving compare, sexp]
  end

  include T
  include Comparable.Make (T)
end

let part_1 graph =
  let start_cave = Cave.Small "start" and end_cave = Cave.Small "end" in
  let rec dfs visited cur =
    let is_end_cave = Cave.equal cur end_cave in
    let new_visited = Set.add visited cur in

    (* Enqueue all neighbours if it is not the end node *)
    if is_end_cave then 1
    else
      Graph.neighbours ~equal:Cave.equal graph cur
      |> List.filter_map ~f:(function
           (* Always enqueue big caves *)
           | Cave.Big x -> Some (Cave.Big x)
           (* Never enqueue start cave *)
           | x -> if not (Set.mem visited x) then Some x else None)
      |> List.fold ~init:0 ~f:(fun acc next -> acc + dfs new_visited next)
  in
  dfs Cave.Set.empty start_cave

let part_2 graph =
  let start_cave = Cave.Small "start" and end_cave = Cave.Small "end" in

  let rec dfs visited (cur_seen, cur) =
    let is_end_cave = Cave.equal cur end_cave in
    let new_visited = Set.add visited cur in

    (* Enqueue all neighbours if it is not the end node *)
    if is_end_cave then 1
    else
      Graph.neighbours ~equal:Cave.equal graph cur
      |> List.filter_map ~f:(function
           (* Always enqueue big caves *)
           | Cave.Big x -> Some (cur_seen, Cave.Big x)
           (* Never enqueue start cave *)
           | Cave.Small "start" -> None
           | x ->
               let seen_before = Set.mem visited x in
               if not ((cur_seen || Cave.equal end_cave x) && seen_before) then
                 Some (seen_before || cur_seen, x)
               else None)
      |> List.fold ~init:0 ~f:(fun acc next -> acc + dfs new_visited next)
  in
  dfs Cave.Set.empty (false, start_cave)

let parse_big_cave =
  let open Opal in
  many1 upper => implode % fun x -> Cave.Big x

and parse_small_cave =
  let open Opal in
  many1 lower => implode % fun x -> Cave.Small x

let parse_node =
  let open Opal in
  parse_big_cave <|> parse_small_cave

let parse_edge =
  let open Opal in
  parse_node << exactly '-' >>= fun e1 ->
  parse_node >>= fun e2 -> return (e1, e2)

let parse_line line =
  let open Opal in
  LazyStream.of_string line |> parse parse_edge

let () =
  let graph =
    In_channel.read_lines input_path
    |> List.filter_map ~f:parse_line
    |> Graph.of_list
  in

  (* Compute part 1 *)
  let part_1_result = part_1 graph in
  Stdio.printf "Part 1 %d\n" @@ part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 graph in
  Stdio.printf "Part 2 %d\n" part_2_result
