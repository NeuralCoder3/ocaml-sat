open Types

(** Converts a formula to a simplified form only using the operators And, Or, Not, Var *)
let simplify expr = 
    let rec simplify' expr = 
        match expr with
        | Implies (a, b) -> SOr (SNot (simplify' a), simplify' b)
        | And (a, b) -> SAnd (simplify' a, simplify' b)
        | Or (a, b) -> SOr (simplify' a, simplify' b)
        | Not a -> SNot (simplify' a)
        | Var a -> SVar a
        | True -> SOr (SVar "dummy", SNot (SVar "dummy"))
        | False -> SAnd (SVar "dummy", SNot (SVar "dummy"))
        | Iff (a, b) -> SAnd (SOr (simplify' a, SNot (simplify' b)), SOr (SNot (simplify' a), simplify' b))
    in
    simplify' expr

(** Converts a simplified expression to a CNF formula (/\ \/ ~ literals) *)
let cnf_of_simpl_expr expr : cnf =
    (* returns 
       - var name representing the expression and 
       - the generated clause list 

      Each subexpression is replaced by a new variable X and a constraint (X <-> sub-expression)
      We use:
      - X <-> Y /\ Z  => ( X \/ ~Y \/ ~Z) (~X \/  Y) (~X \/  Z) 
      - X <-> Y \/ Z  => (~X \/  Y \/  Z) ( X \/ ~Y) ( X \/ ~Z)
      - X <-> ~Y      =>                  (~X \/ ~Y) ( X \/  Y)
    *)
    let prefix = "tseytin_" in
    let rec tseytin expr =
        match expr with
        | SVar a -> a, []
        | SAnd (a, b) -> 
            let a', a_clauses = tseytin a in
            let b', b_clauses = tseytin b in
            let new_var = prefix ^ a' ^ "_and_" ^ b' in
            new_var, [
                [Neg new_var; Pos a']; 
                [Neg new_var; Pos b'];
                [Pos new_var; Neg a'; Neg b']
             ] @ a_clauses @ b_clauses
        | SOr (a, b) ->
            let a', a_clauses = tseytin a in
            let b', b_clauses = tseytin b in
            let new_var = prefix ^ a' ^ "_or_" ^ b' in
            new_var, [
                [Neg new_var; Pos a'; Pos b'];
                [Pos new_var; Neg a'];
                [Pos new_var; Neg b']
            ] @ a_clauses @ b_clauses
        | SNot a -> 
            let a', a_clauses = tseytin a in
            let new_var = prefix ^ "not_" ^ a' in
            new_var, [
                [Neg new_var; Neg a'];
                [Pos new_var; Pos a']
            ] @ a_clauses
    in
    let v, clauses = tseytin expr in
    (* the main expression should be true *)
    [ [Pos v] ] @ clauses
