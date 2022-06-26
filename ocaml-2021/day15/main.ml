open Core

let input_path = (Sys.get_argv ()).(1)

module Graph = struct
  (* Graph is a 2D array representing the cost of entering each vertex *)
  type t = int array array

  (* Vertex is represented by the (y, x) coordinate *)
  type vertex = int * int

  (* Returns the shape of the graph (height, width) *)
  let shape graph = (Array.length graph, Array.length graph.(0))

  (* Returns all (y, x) pairs in the 2D array *)
  let vertices graph =
    let n, m = shape graph in
    let ys = List.range 0 n and xs = List.range 0 m in
    List.cartesian_product ys xs

  (* Returns the cost of entering vertex (y, x) *)
  let cost graph (y, x) = graph.(y).(x)

  (* Checks if vertex is contained within the graph *)
  let contains graph (y, x) =
    let n, m = shape graph in
    x < m && x >= 0 && y >= 0 && y < n

  (* Get neighbours of a vertex *)
  let neighbours graph (y, x) =
    [ (y, x - 1); (y, x + 1); (y - 1, x); (y + 1, x) ]
    |> List.filter ~f:(contains graph)

  (* Shortest path from (0, 0) using Dijkstra's algorithm *)
  let shortest_path graph =
    (* Produce a queue with only the source (distance, (y, x)) *)
    let vertex_queue = Fheap.of_list ~compare:Poly.compare [ (0, (0, 0)) ] in

    (* 2D matrix that maps each vertex to distance which is initialized to infinity *)
    let m, n = shape graph in
    let dist = Array.make_matrix ~dimx:n ~dimy:m Int.max_value in

    (* Distance to source is zero *)
    dist.(0).(0) <- 0;

    let rec loop q =
      match Fheap.pop q with
      | None -> dist
      | Some ((_, u), q) ->
          neighbours graph u
          |> List.fold ~init:q ~f:(fun q v ->
                 let (vy, vx), (uy, ux) = (v, u) in
                 let v_dist, u_dist = (dist.(vy).(vx), dist.(uy).(ux)) in
                 let new_dist = u_dist + cost graph v in
                 if new_dist < v_dist && not (u_dist = Int.max_value) then (
                   (* Update the dist *)
                   dist.(vy).(vx) <- new_dist;
                   Fheap.add q (new_dist, v))
                 else q)
          |> loop
    in
    loop vertex_queue |> ignore;
    dist
end

let part_1 graph =
  let n, m = Graph.shape graph in
  let dist = Graph.shortest_path graph in
  dist.(m - 1).(n - 1)

let part_2 _ = failwith "Not implemented"

let parse_row =
  let open Opal in
  many1 (digit => Char.to_string => int_of_string) => List.to_array

let parse_problem =
  let open Opal in
  many1 (parse_row << newline) => List.to_array

let () =
  let map_grid =
    In_channel.create input_path
    |> Opal.LazyStream.of_channel |> Opal.parse parse_problem
    |> Option.value_exn
  in

  (* Compute part 1 *)
  let part_1_result = part_1 map_grid in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 map_grid in
  printf "Part 2 %s\n" part_2_result
