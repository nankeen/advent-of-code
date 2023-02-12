open Core

type 'a t = Pair of 'a t * 'a t | Number of 'a [@@deriving variants]

module Reduce = struct
  type 'a t = Reduced of 'a | No_change of 'a [@@deriving variants]

  let map t ~f =
    match t with Reduced s -> Reduced (f s) | No_change s -> No_change (f s)

  let flatten = function
    | Reduced (Reduced s | No_change s) | No_change (Reduced s) -> Reduced s
    | No_change (No_change s) -> No_change s

  let bind_reduced t ~f =
    match t with Reduced s -> Reduced (f s) |> flatten | t -> t

  let bind_no_change t ~f =
    match t with No_change s -> No_change (f s) |> flatten | t -> t

  let inner = function Reduced s | No_change s -> s
end

module Split = struct
  let rec split = function
    | Number n when n >= 10 ->
        Pair (Number (n / 2), Number (Float.iround_up_exn (n // 2)))
        |> Reduce.reduced
    | Pair (l, r) ->
        split l
        |> Reduce.bind_reduced ~f:(fun l' -> Pair (l', r) |> Reduce.reduced)
        |> Reduce.bind_no_change ~f:(fun l ->
               split r |> Reduce.map ~f:(fun r' -> Pair (l, r')))
    | Number n -> Number n |> Reduce.no_change
end

module Explode = struct
  type 'a t =
    | Exp_both of int * int * 'a
    | Exp_left of int * 'a
    | Exp_right of int * 'a
    | Don't_explode of 'a

  let inner = function
    | Exp_both (_, _, s) | Exp_left (_, s) | Exp_right (_, s) | Don't_explode s
      ->
        s

  let rec map_leftmost_leaf ~f = function
    | Pair (l, r) -> Pair (map_leftmost_leaf ~f l, r)
    | Number num -> Number (f num)

  let rec map_rightmost_leaf ~f = function
    | Pair (l, r) -> Pair (l, map_rightmost_leaf ~f r)
    | Number num -> Number (f num)

  let explode snailfish_number =
    let rec explode' depth t =
      match t with
      | Pair (Number l, Number r) when depth >= 4 ->
          Exp_both (l, r, Number 0) |> Reduce.reduced
      | Pair (l, r) -> (
          match explode' (depth + 1) l with
          | Reduced exp ->
              (match exp with
              | Exp_both (el, er, n) ->
                  Exp_left (el, Pair (n, map_leftmost_leaf ~f:(( + ) er) r))
              | Exp_left (el, n) -> Exp_left (el, Pair (n, r))
              | Exp_right (er, n) ->
                  Don't_explode (Pair (n, map_leftmost_leaf ~f:(( + ) er) r))
              | Don't_explode n -> Don't_explode (Pair (n, r)))
              |> Reduce.reduced
          | No_change _ -> (
              match explode' (depth + 1) r with
              | Reduced exp ->
                  (match exp with
                  | Exp_both (el, er, n) ->
                      Exp_right
                        (er, Pair (map_rightmost_leaf ~f:(( + ) el) l, n))
                  | Exp_right (er, n) -> Exp_right (er, Pair (l, n))
                  | Exp_left (el, n) ->
                      Don't_explode
                        (Pair (map_rightmost_leaf ~f:(( + ) el) l, n))
                  | Don't_explode n -> Don't_explode (Pair (l, n)))
                  |> Reduce.reduced
              | No_change _ -> Don't_explode (Pair (l, r)) |> Reduce.no_change))
      | Number n -> Don't_explode (Number n) |> Reduce.no_change
    in
    explode' 0 snailfish_number |> Reduce.map ~f:inner
end

let rec reduce t =
  Explode.explode t
  |> Reduce.bind_no_change ~f:Split.split
  |> Reduce.bind_reduced ~f:reduce

let ( +. ) a b = Pair (a, b) |> reduce |> Reduce.inner

let rec magnitude = function
  | Pair (l, r) -> (magnitude l * 3) + (magnitude r * 2)
  | Number n -> n

let parse =
  let open Angstrom in
  let number = take_while1 Char.is_digit >>| int_of_string >>| number in
  fix (fun node ->
      let pair =
        let* left = number <|> node <* char ',' in
        let+ right = number <|> node in
        Pair (left, right)
      in
      char '[' *> pair <* char ']')

let rec to_string = function
  | Pair (l, r) -> [%string "[%{to_string l},%{to_string r}]"]
  | Number n -> string_of_int n

module For_testing = struct
  let parse_line line =
    Angstrom.parse_string ~consume:All parse line |> Result.ok_or_failwith

  let%expect_test "sum_simple" =
    [
      {|[1,1]
[2,2]
[3,3]
[4,4]|};
      {|[1,1]
[2,2]
[3,3]
[4,4]
[5,5]|};
      {|[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
[6,6]|};
      {|[[[[4,3],4],4],[7,[[8,4],9]]]
[1,1]|};
    ]
    |> List.iter ~f:(fun sample ->
           String.split_lines sample |> List.map ~f:parse_line
           |> List.reduce ~f:( +. ) |> Option.value_exn |> to_string
           |> print_endline);
    [%expect
      {|
      [[[[1,1],[2,2]],[3,3]],[4,4]]
      [[[[3,0],[5,3]],[4,4]],[5,5]]
      [[[[5,0],[7,4]],[5,5]],[6,6]]
      [[[[0,7],4],[[7,8],[6,0]]],[8,1]]|}]

  let%expect_test "sum_larger" =
    let rec sum = function
      | h1 :: h2 :: tl ->
          let h = h1 +. h2 in
          print_endline (to_string h);
          sum (h :: tl)
      | [ h1 ] -> h1
      | [] -> raise_s [%message "empty list"]
    in

    {|[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]|}
    |> String.split_lines |> List.map ~f:parse_line |> sum |> to_string
    |> print_endline;
    [%expect
      {|
[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]
[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]
[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]
[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]
[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]
[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]
[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]|}]

  let%expect_test "test_explode" =
    [
      "[[[[[9,8],1],2],3],4]";
      "[7,[6,[5,[4,[3,2]]]]]";
      "[[6,[5,[4,[3,2]]]],1]";
      "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]";
      "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]";
    ]
    |> List.iter ~f:(fun sample ->
           parse_line sample |> Explode.explode |> Reduce.inner |> to_string
           |> print_endline);
    [%expect
      {|
[[[[0,9],2],3],4]
[7,[6,[5,[7,0]]]]
[[6,[5,[7,0]]],3]
[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
[[3,[2,[8,0]]],[9,[5,[7,0]]]]|}]

  let%expect_test "test_magnitude" =
    List.(
      [
        "[[1,2],[[3,4],5]]";
        "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]";
        "[[[[1,1],[2,2]],[3,3]],[4,4]]";
        "[[[[3,0],[5,3]],[4,4]],[5,5]]";
        "[[[[5,0],[7,4]],[5,5]],[6,6]]";
        "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]";
      ]
      |> map ~f:parse_line |> map ~f:magnitude |> map ~f:string_of_int
      |> List.iter ~f:print_endline);
    [%expect
      {|
      143
      1384
      445
      791
      1137
      3488|}]

  let%expect_test "test_sample_input" =
    let sample =
      {|[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]|}
      |> String.split_lines |> List.map ~f:parse_line |> List.reduce ~f:( +. ) |> Option.value_exn
    in
    to_string sample |> print_endline;
    [%expect {|[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]|}]
end
