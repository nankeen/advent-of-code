open Core

let input_path = (Sys.get_argv ()).(1)

type parse_result = Point of int * int | FoldX of int | FoldY of int
[@@deriving show]

module Point_set = Set.Make (struct
  type t = int * int [@@deriving compare, sexp_of]

  let t_of_sexp = opaque_of_sexp
end)

let integer =
  let open Opal in
  many1 digit => implode % int_of_string

let parse_point =
  let open Opal in
  integer << exactly ',' >>= fun x ->
  integer >>= fun y -> return (Point (x, y))

let parse_fold =
  let open Opal in
  let fold_x =
    exactly 'x' >> exactly '=' >> integer >>= fun x -> return (FoldX x)
  and fold_y =
    exactly 'y' >> exactly '=' >> integer >>= fun y -> return (FoldY y)
  in

  token "fold" >> space >> token "along" >> space >> (fold_x <|> fold_y)

let reflect f (x, y) =
  match f with
  | FoldY i -> Some (if y < i then (x, y) else (x, i - abs (i - y)))
  | FoldX i -> Some (if x < i then (x, y) else (i - abs (i - x), y))
  | _ -> None

let part_1 points folds =
  let fold = List.hd_exn folds in
  Point_set.of_list points
  |> Point_set.filter_map ~f:(reflect fold)
  |> Set.length

let part_2 points folds =
  let point_set = Point_set.of_list points in
  let result =
    List.fold ~init:point_set
      ~f:(fun points fold -> Point_set.filter_map ~f:(reflect fold) points)
      folds
    |> Point_set.to_list
  in
  let render points =
    let max_x =
      List.map result ~f:(fun (x, _) -> x)
      |> List.max_elt ~compare:Poly.compare
      |> Option.value_exn
    and max_y =
      List.map result ~f:(fun (_, y) -> y)
      |> List.max_elt ~compare:Poly.compare
      |> Option.value_exn 
    in
    let screen = Array.make_matrix ~dimx:(max_y + 1) ~dimy:(max_x + 1) '.' in
    List.iter ~f:(fun (x, y) -> screen.(y).(x) <- '#') points;
    Array.map ~f:(fun line -> Array.to_list line |> String.of_char_list) screen
    |> String.concat_array ~sep:"\n"
  in
  render result

let parse_line line =
  let open Opal in
  LazyStream.of_string line |> parse (parse_point <|> parse_fold)

let () =
  let input =
    In_channel.read_lines input_path |> List.filter_map ~f:parse_line
  in
  let points, folds =
    List.partition_map
      ~f:(function
        | Point (x, y) -> Either.First (x, y) | fold -> Either.Second fold)
      input
  in

  (* Compute part 1 *)
  let part_1_result = part_1 points folds in
  printf "Part 1 %d\n" part_1_result;

  (* Compute part 2 *)
  let part_2_result = part_2 points folds in
  printf "Part 2 \n%s\n" part_2_result
