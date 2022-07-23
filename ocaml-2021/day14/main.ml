open Core

module Polymer = struct
  type t = (char * char, int) Hashtbl.t
  type rule = (char * char) * char

  module Pair = struct
    module T = struct
      type t = char * char [@@deriving sexp, compare, hash]
    end

    include T
    include Hashable.Make (T)
  end

  let ( let* ) = Opal.( >>= )

  let parse_rule =
    let open Opal in
    let* left1 = upper in
    let* left2 = upper in

    let* produces = space >> token "->" << space >> upper << newline in
    return ((left1, left2), produces)

  let touch_n t s n =
    let count = match Pair.Table.find t s with Some x -> x | None -> 0 in
    Pair.Table.set t ~key:s ~data:(count + n)

  let count_pairs polymer_str =
    let counter = Pair.Table.create ()
    and s1 = Sequence.of_list polymer_str
    and s2 = Sequence.of_list (List.tl_exn polymer_str) in
    Sequence.(zip s1 s2 |> iter ~f:(fun pair -> touch_n counter pair 1));
    counter

  let parse_problem =
    let open Opal in
    let* polymer_template = many1 upper in
    let* _ = many newline in
    let* rules = many parse_rule in
    return (count_pairs polymer_template, Pair.Table.of_alist_exn rules)

  let pair_insertion rules old_counter =
    let new_counter = Pair.Table.create () in
    Pair.Table.iteri old_counter ~f:(fun ~key:(a, b) ~data ->
        let product_option = Pair.Table.find rules (a, b) in
        match product_option with
        | Some product ->
            touch_n new_counter (a, product) data;
            touch_n new_counter (product, b) data
        | None -> touch_n new_counter (a, b) data);
    new_counter
end

let count_polymer polymer =
  let counter = Hashtbl.create (module Char) in
  let touch_counter elem n =
    let count =
      match Hashtbl.find counter elem with Some i -> i | None -> 0
    in
    Hashtbl.set counter ~key:elem ~data:(count + n)
  in
  Hashtbl.iteri polymer ~f:(fun ~key:(a, b) ~data ->
      touch_counter a data;
      touch_counter b data);
  (* Divide each entry by 2 *)
  Hashtbl.map counter ~f:(fun count -> (count / 2) + (count % 2))

let input_path = (Sys.get_argv ()).(1)

let part_1 counter rules =
  let polymer_count =
    List.fold ~init:counter
      ~f:(fun counter _ -> Polymer.pair_insertion rules counter)
      (List.range 0 10)
    |> count_polymer |> Hashtbl.to_alist
  in
  let _, max_c =
    List.max_elt ~compare:(fun (_, ca) (_, cb) -> compare ca cb) polymer_count
    |> Option.value_exn
  in
  let _, min_c =
    List.min_elt ~compare:(fun (_, ca) (_, cb) -> compare ca cb) polymer_count
    |> Option.value_exn
  in
  max_c - min_c

let part_2 polymer rules =
  let polymer_count =
    List.fold ~init:polymer
      ~f:(fun polymer _ -> Polymer.pair_insertion rules polymer)
      (List.range 0 40)
    |> count_polymer |> Hashtbl.to_alist
  in
  let _, max_c =
    List.max_elt ~compare:(fun (_, ca) (_, cb) -> compare ca cb) polymer_count
    |> Option.value_exn
  in
  let _, min_c =
    List.min_elt ~compare:(fun (_, ca) (_, cb) -> compare ca cb) polymer_count
    |> Option.value_exn
  in
  max_c - min_c

let () =
  let pair_counter, rules =
    In_channel.create input_path
    |> Opal.LazyStream.of_channel
    |> Opal.parse Polymer.parse_problem
    |> Option.value_exn
  in

  (* Compute part 1 *)
  let part_1_result = part_1 pair_counter rules in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 pair_counter rules in
  printf "Part 2 %d\n" part_2_result
