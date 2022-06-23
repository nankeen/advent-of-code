open Core

module Hashtbl_rule = Hashtbl.Make (struct
  type t = char * char [@@deriving of_sexp, sexp_of, compare, hash]
end)

module Polymer = struct
  type t = string
  type rule = (char * char) * char

  let ( let* ) = Opal.( >>= )

  let parse_rule =
    let open Opal in
    let* left1 = upper in
    let* left2 = upper in

    let* produces = space >> token "->" << space >> upper << newline in
    return ((left1, left2), produces)

  let parse_problem =
    let open Opal in
    let* polymer_template = many1 upper in
    let* _ = many newline in
    let* rules = many parse_rule in
    return (polymer_template, Hashtbl_rule.of_alist_exn rules)

  let pair_insertion rules polymer =
    let pairs =
      List.zip_exn (List.drop_last_exn polymer) (List.drop polymer 1)
    in
    List.fold pairs
      ~init:[ List.hd_exn polymer ]
      ~f:(fun p (a, b) ->
        let product_option = Hashtbl_rule.find rules (a, b) in
        match product_option with
        | Some product -> b :: product :: p
        | None -> b :: p)
    |> List.rev
end

let count_polymer elems =
  let add_count counter x =
    let count_opt = Hashtbl.find counter x in
    match count_opt with
    | Some count -> Hashtbl.set counter ~key:x ~data:(succ count)
    | None -> Hashtbl.set counter ~key:x ~data:0
  in
  let counter = Hashtbl.create (module Char) in
  List.iter elems ~f:(add_count counter);
  counter

let input_path = (Sys.get_argv ()).(1)

let part_1 polymer rules =
  let polymer_count =
    List.fold ~init:polymer
      ~f:(fun polymer _ -> Polymer.pair_insertion rules polymer)
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
  let polymer_template, rules =
    In_channel.create input_path
    |> Opal.LazyStream.of_channel
    |> Opal.parse Polymer.parse_problem
    |> Option.value_exn
  in

  (* Compute part 1 *)
  let part_1_result = part_1 polymer_template rules in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 polymer_template rules in
  printf "Part 2 %d\n" part_2_result
