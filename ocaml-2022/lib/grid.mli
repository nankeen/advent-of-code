type node = int * int
type 'a t = 'a array array

val shape : 'a t -> int * int
val get : 'a t -> node -> 'a option
val get_exn : 'a t -> node -> 'a

include Graph.S with type 'a t := 'a t and type node := node
