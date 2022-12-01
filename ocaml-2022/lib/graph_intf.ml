open! Core

module Basic = struct
  module type S = sig
    type node
    type 'a t

    module Node : Comparable with type t := node

    val nodes : 'a t -> node list
    (** List of all nodes in the graph **)

    val mem : 'a t -> node -> bool
    (** Returns true of the given node is in the graph **)

    val neighbours : 'a t -> node -> node list
    (** Neighbours of a given node **)
  end
end

module type S = sig
  include Basic.S

  val dijkstra_shortest_path_cost :
    'a t -> from:node -> target:node -> cost:(node * node -> int) -> int option
  (*
  val dijkstra_shortest_path :
    t ->
    from:node ->
    target:node ->
    cost:(node -> node -> int) ->
    node list
    *)
end

module type Graph = sig
  module Basic = Basic

  module type S = S

  module Make (M : Basic.S) : S with type 'a t := 'a M.t and type node := M.node
end
