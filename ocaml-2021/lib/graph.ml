open! Core
include Graph_intf

module Make (M : Basic.S) = struct
  include M

  (* Helper record type to keep track of Dijkstra main loop state *)
  type dijkstra_state = {
    queue : (int * M.node) Fheap.t;
    distance : int M.Node.Map.t;
    previous : M.node M.Node.Map.t;
  }

  (* Shortest path from (0, 0) using Dijkstra's algorithm *)
  let dijkstra t ~from ~target ~cost =
    let update_neighbour state v ~u =
      let v_dist =
        Map.find state.distance v |> Option.value ~default:Int.max_value
      and u_dist =
        Map.find state.distance u |> Option.value ~default:Int.max_value
      in
      let new_dist = u_dist + cost (u, v) in
      if new_dist < v_dist && not (u_dist = Int.max_value) then
        {
          queue = Fheap.add state.queue (new_dist, v);
          distance = Map.set state.distance ~key:v ~data:new_dist;
          previous = Map.set state.previous ~key:v ~data:u;
        }
      else state
    in

    (* Produce a queue with only the source (distance, (y, x)) *)
    let queue =
      Fheap.of_list
        ~compare:(Tuple2.compare ~cmp1:compare ~cmp2:M.Node.compare)
        [ (0, from) ]
    in

    (* 2D matrix that maps each vertex to distance which is initialized to infinity *)
    let distance = M.Node.Map.singleton from 0 in

    let rec loop (state : dijkstra_state) =
      match Fheap.pop state.queue with
      | None -> state
      | Some ((_, u), new_q) ->
          if M.Node.equal u target then state
          else
            neighbours t u
            |> List.fold
                 ~init:{ state with queue = new_q }
                 ~f:(update_neighbour ~u)
            |> loop
    in
    loop { queue; distance; previous = M.Node.Map.empty }

    let dijkstra_shortest_path_cost t ~from ~target ~cost = 
      let { distance ; _ } = dijkstra t ~from ~target ~cost in
      Map.find distance target
end
