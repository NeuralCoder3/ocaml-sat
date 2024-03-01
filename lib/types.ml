(* General propositional logic formulae *)
type expr = 
    | Implies of expr * expr
    | And of expr * expr
    | Or of expr * expr
    | Not of expr
    | Var of string
    | True
    | False
    | Iff of expr * expr

(* Simplified propositional logic formulae with primitive operators *)
(* Note that nand and var would be sufficient but we use and, or, not for convenience and convention
    and to allow further transformations *)
type simpl_expr =
    | SAnd of simpl_expr * simpl_expr
    | SOr of simpl_expr * simpl_expr
    | SNot of simpl_expr
    | SVar of string

(* A normal form for conjunctions of clauses
   Each clause is a disjunction of (possibly negated) literals

   The general shape is /\ \/ ~ var
   Example: (p ∨ ¬q ∨ r) ∧ (¬p ∨ q ∨ r) ∧ (¬p ∨ ¬q ∨ r)

   We use lists to abstract over unimportant associations and to remove operators.
   Hence, the type only allows for formulas in CNF, but not for arbitrary formulas by construction.
*)
type literal = 
    | Pos of string
    | Neg of string
type cnf = literal list list

(** A human-readable representation of a formula as string. *)
let show_cnf cnf =
    let show_literal = function
        | Pos s -> s
        | Neg s -> "¬" ^ s
    in
    let show_clause c = 
        "("^
        String.concat " ∨ " (List.map show_literal c)
        ^")"
    in
    String.concat " ∧ " (List.map show_clause cnf)

let negate = function
  | Pos x -> Neg x
  | Neg x -> Pos x