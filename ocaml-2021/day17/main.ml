open Core

let input_path = (Sys.get_argv ()).(1)

module Target = struct
  type t = { x_min : int; x_max : int; y_min : int; y_max : int }

  let vx_range { x_min; x_max; _ } =
    let vx_max = x_max
    and vx_min =
      (-1. +. sqrt (1. +. (8. *. float_of_int x_min))) /. 2.
      |> Float.round_up |> int_of_float
    in
    Sequence.range ~stop:`inclusive vx_min vx_max

  let vy_range { y_min; _ } =
    let vy_max = abs y_min - 1 and vy_min = y_min in
    Sequence.range ~stop:`inclusive ~stride:(-1) vy_max vy_min

  let will_hit t (ux, uy) =
    let rec loop vx vy x_t y_t =
      if x_t > t.x_max || y_t < t.y_min then false
      else if x_t >= t.x_min && y_t <= t.y_max then true
      else
        let x_t = x_t + vx and y_t = y_t + vy in
        let vx = max 0 (vx - 1) and vy = vy - 1 in
        loop vx vy x_t y_t
    in
    loop ux uy 0 0
end

let part_1 t =
  let n = Target.vy_range t |> Sequence.hd_exn in
  n * (n + 1) / 2

let part_2 t =
  let us =
    Sequence.(
      cartesian_product (Target.vx_range t) (Target.vy_range t)
      |> filter ~f:(Target.will_hit t))
  in
  Sequence.length us

module Pair = Comparable.Make (struct
  type t = int * int [@@deriving compare, sexp]
end)

let parse_problem =
  let open Angstrom in
  let integer =
    take_while1 (fun c -> Char.(is_digit c || c = '-')) >>| int_of_string
  in
  let* x_min = string "target area: x=" *> integer in
  let* x_max = string ".." *> integer in
  let* y_min = string ", y=" *> integer in
  let+ y_max = string ".." *> integer in
  Target.{ x_min; x_max; y_min; y_max }

let () =
  let input =
    In_channel.read_all input_path
    |> Angstrom.parse_string ~consume:Prefix parse_problem
    |> Result.ok_or_failwith
  in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  print_s [%message "Part 1" (part_1_result : int)];

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  print_s [%message "Part 2" (part_2_result : int)]
