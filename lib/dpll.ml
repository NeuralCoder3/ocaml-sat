open Types
open Monad

(* avoiding higher-order module type dependency and escaping scopes in return type *)
(* for inline binding, see https://discuss.ocaml.org/t/type-constructor-would-escape-its-scope-how-to-express-return-type/2492/7 *)
module SAT (M:Monad) = struct

  module MO = MonadOps(M) 
  open M
  open MO

  let sat (xxs:cnf) : literal list M.t =
    let propagate lit xss =
      List.filter_map (fun xs ->
        if List.mem lit xs then None
        else
          Some (List.filter (fun x -> x <> negate lit) xs)
      ) xss
    in
    let rec dpll xss =
      match xss with
      | [] -> return []
      | _ :: _ when List.exists (fun xs -> xs = []) xss -> mzero
      | _ ->
        (
        (* propagate unit clauses *)
        match List.find_map (fun xs ->
          match xs with
          | [x] -> Some x
          | _ -> None
        ) xss with
        | Some x -> dpll (propagate x xss) |> map (fun ys -> x :: ys)
        | None ->
          (* make a decision *)
          let lit = List.hd (List.hd xss) in
          (dpll (propagate lit xss) |> map (fun ys -> lit :: ys)) <|>
          (dpll (propagate (negate lit) xss) |> map (fun ys -> negate lit :: ys))
        )
    in
    dpll xxs

end

(** Finds one satisfying assignment to the formula if it exists.
    Not necessarily all literals are assigned in the solution.
*)
let sat xxs = 
  let module M = SAT(OptionMonad) in
  M.sat xxs

(** Finds all (distinct in at least one decision) to the formula.
    Not necessarily all literals are assigned in each solution.
*)
let sat_all xxs = 
  let module M = SAT(ListMonad) in
  M.sat xxs