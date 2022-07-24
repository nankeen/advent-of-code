type node = int * int
type 'a t = 'a array array

val shape : 'a t -> int * int

include Graph.S with type 'a t := 'a t and type node := node
