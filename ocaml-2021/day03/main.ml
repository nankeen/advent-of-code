open Core

let input_path = (Sys.get_argv ()).(1)

let gamma_bits = function
  | x :: xs ->
      let open Array in
      let n = List.length xs in
      let element_sum x y =
        match zip x y with
        | Some xs -> map xs ~f:(fun (a, b) -> a + b)
        | None -> failwith "Reports have different length"
      in
      let gamma =
        List.fold xs ~init:x ~f:element_sum
        |> map ~f:(fun x -> if x > n - x then 1 else 0)
      in
      gamma
  | [] -> failwith "Empty reports"

let int_of_bits = Array.fold ~init:0 ~f:(fun acc x -> (acc * 2) + x)

let epsilon_bits = Array.map ~f:(fun x -> lnot x land 1)

let part_1 reports =
  let gamma = gamma_bits reports in
  let epsilon = epsilon_bits gamma in
  (int_of_bits gamma, int_of_bits epsilon)

let find_criteria criteria_function numbers =
  let rec loop i criteria = function
    | [] -> failwith "Not found"
    | [ found ] -> found
    | numbers ->
        let filtered_numbers = List.filter numbers ~f:(fun x -> x.(i) = criteria.(i)) in
        loop (i + 1) (criteria_function filtered_numbers) filtered_numbers
  in
  loop 0 (criteria_function numbers) numbers

let part_2 reports =
  let epsilon = (fun x -> epsilon_bits @@ gamma_bits x) in
  let ogr = find_criteria gamma_bits reports in
  let csr = find_criteria epsilon reports in
  (int_of_bits ogr, int_of_bits csr)

let parse_line line =
  String.to_array line |> Array.map ~f:(fun x -> int_of_char x - 0x30)

let () =
  let lines = List.map (In_channel.read_lines input_path) ~f:parse_line in

  (* Compute part 1 *)
  let gamma, epsilon = part_1 lines in
  Stdio.printf "Part 1 Gamma: %d Epsilon: %d Answer: %d\n" gamma epsilon
    (gamma * epsilon);

  (* Compute part 2 *)
  let ogr, csr = part_2 lines in
  Stdio.printf
    "Part 2 Oxygen Generator Rating: %d CO2 Scrubber Rating: %d Answer: %d\n"
    ogr csr (ogr * csr)
