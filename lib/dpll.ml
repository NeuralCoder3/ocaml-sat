open Types

let negate = function
  | Pos x -> Neg x
  | Neg x -> Pos x

let sat (xxs:cnf) : literal list option =
  let propagate lit xss =
    List.filter_map (fun xs ->
      if List.mem lit xs then None
      else
        Some (List.filter (fun x -> x <> negate lit) xs)
    ) xss
  in
  (* unit propagate *)
  let unit_propagate xss =
    let rec loop xss =
      match List.filter_map (fun xs ->
        match xs with
        | [x] -> Some x
        | _ -> None
      ) xss with
      | [] -> [], xss
      | lit :: _ -> 
        let choices, cnf' = loop (propagate lit xss) in
        lit :: choices, cnf'
    in
    loop xss
  in
  let rec dpll xss =
    match unit_propagate xss with
    | c, [] -> Some c
    | _, xss when List.exists (fun xs -> xs = []) xss -> None
    | c, xss ->
      (let lit = List.hd (List.hd xss) in
      match dpll (propagate lit xss) with
      | None -> 
        (match dpll (propagate (negate lit) xss) with
        | None -> None
        | Some lits -> Some (c @ negate lit :: lits))
      | Some lits -> Some (c@lit :: lits))
  in
  dpll xxs