open Types

let negate = function
  | Pos x -> Neg x
  | Neg x -> Pos x

let (<|>) x y = x @ y

(* same as dpll but with List monad instead of Option monad *)
let sat_all (xxs:cnf) : literal list list =
  let propagate lit xss =
    List.filter_map (fun xs ->
      if List.mem lit xs then None
      else
        Some (List.filter (fun x -> x <> negate lit) xs)
    ) xss
  in
  let rec dpll xss =
    match xss with
    | [] -> [[]]
    | _ :: _ when List.exists (fun xs -> xs = []) xss -> []
    | _ ->
      (
      (* propagate unit clauses *)
      match List.find_map (fun xs ->
        match xs with
        | [x] -> Some x
        | _ -> None
      ) xss with
      | Some x -> dpll (propagate x xss) |> List.map (fun ys -> x :: ys)
      | None ->
        (* make a decision *)
        let lit = List.hd (List.hd xss) in
        (dpll (propagate lit xss) |> List.map (fun ys -> lit :: ys)) <|>
        (dpll (propagate (negate lit) xss) |> List.map (fun ys -> negate lit :: ys))
      )
  in
  dpll xxs