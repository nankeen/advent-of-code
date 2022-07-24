open! Core

module T = struct
  type node = int * int
  type 'a t = 'a array array

  module Node = Comparable.Make (struct
    type t = int * int [@@deriving sexp, compare]
  end)

  (* Returns the shape of the graph (height, width) *)
  let shape t = (Array.length t, Array.length t.(0))

  let nodes t =
    let n, m = shape t in
    let ys = List.range 0 n and xs = List.range 0 m in
    List.cartesian_product ys xs

  (* Checks if vertex is contained within the graph *)
  let mem t (y, x) =
    let n, m = shape t in
    x < m && x >= 0 && y >= 0 && y < n

  (* Get neighbours of a vertex *)
  let neighbours t (y, x) =
    [ (y, x - 1); (y, x + 1); (y - 1, x); (y + 1, x) ] |> List.filter ~f:(mem t)

  let get t ((y, x) as v) = if mem t v then Some t.(y).(x) else None
  let get_exn t v = get t v |> Option.value_exn
end

include T
include Graph.Make (T)
