open Core

let input_path = (Sys.get_argv ()).(1)

module Graph = struct
  include Aoc_utils.Grid

  let expand graph n =
    let increment_row = Array.map ~f:(fun e -> (e % 9) + 1) in

    let expand_row row =
      let row_sequence =
        Sequence.unfold ~init:row ~f:(fun r ->
            let new_r = increment_row r in
            Some (r, new_r))
      in
      Sequence.(take row_sequence n |> to_list) |> Array.concat
    in

    let g = Array.map ~f:expand_row graph in
    let seqs =
      Sequence.unfold ~init:g ~f:(fun g ->
          let new_g = Array.map ~f:increment_row g in
          Some (g, new_g))
    in
    Sequence.(take seqs n |> to_list) |> Array.concat
end

let part_1 graph =
  let n, m = Graph.shape graph in
  let from = (0, 0) in
  Graph.dijkstra_shortest_path_cost graph ~from
    ~target:(m - 1, n - 1)
    ~cost:(fun (_, (vy, vx)) -> graph.(vy).(vx))
  |> Option.value_exn

let part_2 graph =
  let expanded_graph = Graph.expand graph 5 in
  part_1 expanded_graph

let parse_row =
  let open Angstrom in
  let digit = satisfy Char.is_digit in
  many1 (digit >>| Char.to_string >>| int_of_string) >>| List.to_array

let parse_problem =
  let open Angstrom in
  many1 (parse_row <* char '\n') >>| List.to_array

let () =
  let map_grid =
    In_channel.read_all input_path
    |> Angstrom.parse_string ~consume:Prefix parse_problem
    |> Result.ok_or_failwith
  in

  (* Compute part 1 *)
  let part_1_result = part_1 map_grid in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 map_grid in
  printf "Part 2 %d\n" part_2_result
