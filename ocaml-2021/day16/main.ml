open Core

let ( >>> ) = Fn.compose
let int_of_bits bits = "0b" ^ bits |> int_of_string

let binstring_of_hex hex =
  String.to_list hex
  |> List.map ~f:(function
       | '0' -> "0000"
       | '1' -> "0001"
       | '2' -> "0010"
       | '3' -> "0011"
       | '4' -> "0100"
       | '5' -> "0101"
       | '6' -> "0110"
       | '7' -> "0111"
       | '8' -> "1000"
       | '9' -> "1001"
       | 'A' -> "1010"
       | 'B' -> "1011"
       | 'C' -> "1100"
       | 'D' -> "1101"
       | 'E' -> "1110"
       | 'F' -> "1111"
       | c -> raise_s [%message "Unknown hex character" (c : char)])
  |> String.concat

let bit =
  let open Angstrom in
  char '1' <|> char '0'

module Type_id = struct
  type t =
    | Literal
    | Sum
    | Product
    | Minimum
    | Maximum
    | Greater_than
    | Less_than
    | Equals
  [@@deriving sexp]

  let of_int = function
    | 0 -> Sum
    | 1 -> Product
    | 2 -> Minimum
    | 3 -> Maximum
    | 4 -> Literal
    | 5 -> Greater_than
    | 6 -> Less_than
    | 7 -> Equals
    | i -> raise_s [%message "Invalid type id" (i : int)]
end

module Packet_header = struct
  type t = { version : int; type_id : Type_id.t } [@@deriving sexp]

  let parse =
    let open Angstrom in
    let open Angstrom.Let_syntax in
    let%bind version = count 3 bit >>| String.of_char_list >>| int_of_bits in
    let%bind type_id =
      count 3 bit >>| String.of_char_list >>| int_of_bits >>| Type_id.of_int
    in
    return { version; type_id } <?> "header"

  let length = 6
end

module Packet = struct
  type t =
    | Literal of { header : Packet_header.t; literal : int }
    | Operator of { header : Packet_header.t; subpackets : t list }
  [@@deriving sexp]

  let parse_operator header parse_packet =
    let open Angstrom in
    let open Angstrom.Let_syntax in
    let%bind length_type_id = bit >>| int_of_char <?> "length_type_id" in
    let%map subpackets =
      if length_type_id % 2 = 0 then
        let%bind n_bits =
          count 15 bit >>| String.of_char_list >>| int_of_bits
        in
        let%bind start_pos = pos in
        let rec loop subpackets =
          let%bind cur_pos = pos in
          if cur_pos - start_pos >= n_bits then List.rev subpackets |> return
          else
            let%bind packet = parse_packet in
            loop (packet :: subpackets)
        in
        loop []
      else
        let%bind n_packets =
          count 11 bit >>| String.of_char_list >>| int_of_bits
        in
        count n_packets parse_packet
    in
    Operator { header; subpackets }

  let parse_literal header =
    let open Angstrom in
    let open Angstrom.Let_syntax in
    let non_term =
      char '1' *> count 4 bit >>| String.of_char_list <?> "non_term"
    in
    let term = char '0' *> count 4 bit >>| String.of_char_list <?> "term" in
    let%bind non_terms = many non_term in
    let%map last = term in
    let literal = non_terms @ [ last ] |> String.concat |> int_of_bits in
    Literal { header; literal }

  let parse_packet =
    let open Angstrom in
    let open Angstrom.Let_syntax in
    fix (fun parse_packet ->
        let%bind header = Packet_header.parse <?> "header" in
        match header.type_id with
        | Literal -> parse_literal header <?> "parse_literal"
        | _ -> parse_operator header parse_packet <?> "parse_operator")

  let rec sum_version = function
    | Literal { header; _ } -> header.version
    | Operator { header; subpackets } ->
        header.version + List.sum (module Int) ~f:sum_version subpackets

  let rec value = function
    | Literal { literal; _ } -> literal
    | Operator { header; subpackets } -> (
        let values = List.map ~f:value subpackets in
        match header.type_id with
        | Sum -> List.sum (module Int) ~f:Fn.id values
        | Product -> List.fold ~init:1 ~f:( * ) values
        | Minimum -> List.min_elt ~compare:Int.compare values |> Option.value_exn
        | Maximum -> List.max_elt ~compare:Int.compare values |> Option.value_exn
        | Greater_than -> 
            let fst = List.hd_exn values and snd = List.nth_exn values 1 in
            if fst > snd then 1 else 0
        | Less_than ->
            let fst = List.hd_exn values and snd = List.nth_exn values 1 in
            if fst < snd then 1 else 0
        | Equals ->
            let fst = List.hd_exn values and snd = List.nth_exn values 1 in
            if fst = snd then 1 else 0
        | Literal -> raise_s [%message "Invalid packet"])
end

let input_path = (Sys.get_argv ()).(1)
let part_1 = List.sum (module Int) ~f:Packet.sum_version
let part_2 = Packet.value >>> List.hd_exn

let parse_line line =
  binstring_of_hex line
  |> Angstrom.parse_string ~consume:Prefix Packet.parse_packet
  |> Result.ok_or_failwith

let () =
  let input = In_channel.read_lines input_path |> List.map ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  printf "Part 2 %d\n" part_2_result
