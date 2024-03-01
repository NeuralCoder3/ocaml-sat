open Types

let negate = function
  | Pos x -> Neg x
  | Neg x -> Pos x

let (<|>) x y = match x with
  | Some _ as s -> s
  | None -> y

let sat (xxs:cnf) : literal list option =
  let propagate lit xss =
    List.filter_map (fun xs ->
      if List.mem lit xs then None
      else
        Some (List.filter (fun x -> x <> negate lit) xs)
    ) xss
  in
  let rec dpll xss =
    match xss with
    | [] -> Some []
    | _ :: _ when List.exists (fun xs -> xs = []) xss -> None
    | _ ->
      (
      (* propagate unit clauses *)
      match List.find_map (fun xs ->
        match xs with
        | [x] -> Some x
        | _ -> None
      ) xss with
      | Some x -> dpll (propagate x xss) |> Option.map (fun ys -> x :: ys)
      | None ->
        (* make a decision *)
        let lit = List.hd (List.hd xss) in
        (dpll (propagate lit xss) |> Option.map (fun ys -> lit :: ys)) <|>
        (dpll (propagate (negate lit) xss) |> Option.map (fun ys -> negate lit :: ys))
      )
  in
  dpll xxs