open Sat
open Types
open Cnf
open Dpll

(* ignore unused function *)
[@@@ocaml.warning "-32"]

let example1 = 
  Implies (
    And(
      Or(Var "p", Var "q"),
      Var "r"
    ),
    Not (Var "s")
  )

let cnf e = 
  e
  |> simplify
  |> cnf_of_simpl_expr

let () =
  cnf example1
  |> show_cnf
  |> print_endline


let show_model m = 
  let name = function
    | Pos v -> v
    | Neg v -> v
  in
    m
    |> List.filter (function Pos v | Neg v -> not (String.starts_with ~prefix:"tseytin" v))
    |> List.sort (fun a b -> compare (name a) (name b))
    |> List.map (function 
      | Pos v -> " " ^ v
      | Neg v -> "¬" ^ v
    ) 
    |> String.concat ", "

let show_result = function
  | Some m -> show_model m
  | None -> "unsat"

let () = print_endline ""
let () = print_endline "satisfiable?"
let () = cnf example1 |> sat |> show_result |> print_endline
let () = print_endline ""
let () = print_endline "all solutions:"
let () = cnf example1 |> sat_all |> List.map show_model |> List.iter print_endline
