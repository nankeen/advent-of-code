open Core

let input_path = (Sys.get_argv ()).(1)

type tok_typ = Paren | Brace | Brack | ABrac
type token = Opener of tok_typ | Closer of tok_typ

let parse_syntax line =
  let rec loop stack = function
    | Opener opener :: chars ->
        Stack.push stack opener;
        loop stack chars
    | Closer closer :: chars ->
        let expected = Stack.pop_exn stack in
        if phys_equal closer expected then loop stack chars
        else closer :: loop stack chars
    | [] -> []
  in
  let stack = Stack.create () in
  (loop stack line, stack)

let score_of_error = function
  | Paren -> 3
  | Brack -> 57
  | Brace -> 1197
  | ABrac -> 25137

let score_of_completion = function
  | Paren -> 1
  | Brack -> 2
  | Brace -> 3
  | ABrac -> 4

let part_1 =
  let line_score line =
    let errs, _ = parse_syntax line in
    errs |> List.hd |> Option.value_map ~default:0 ~f:score_of_error
  in
  List.sum (module Int) ~f:line_score

let part_2 input =
  let line_score line =
    let errs, completions = parse_syntax line in
    if List.is_empty errs then
      Some
        (completions |> Stack.to_list
        |> List.fold ~init:0 ~f:(fun score comp ->
               (score * 5) + score_of_completion comp))
    else None
  in
  let scores =
    input |> List.filter_map ~f:line_score |> List.sort ~compare:Poly.compare
  in
  List.nth_exn scores (List.length scores / 2)

let token_of_char = function
  | '(' -> Opener Paren
  | '{' -> Opener Brace
  | '[' -> Opener Brack
  | '<' -> Opener ABrac
  | ')' -> Closer Paren
  | '}' -> Closer Brace
  | ']' -> Closer Brack
  | '>' -> Closer ABrac
  | _ -> failwith "invalid syntax"

let parse_line line = String.to_list line |> List.map ~f:token_of_char

let () =
  let input = In_channel.read_lines input_path |> List.map ~f:parse_line in

  (* Compute part 1 *)
  let part_1_result = part_1 input in
  Stdio.printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 input in
  Stdio.printf "Part 2 %d\n" part_2_result
