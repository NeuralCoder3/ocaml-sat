module type Monad = sig
    type 'a t
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
    (* monoid property (a monad is just a monoid in the category of endofunctors) *)
    (* the mplus monad extension (orElse for option) -- https://wiki.haskell.org/MonadPlus *)
    val mzero : 'a t
    val (<|>) : 'a t -> 'a t -> 'a t
end

(* we make the type instantiation public *)
module OptionMonad : (Monad with type 'a t = 'a option) = struct
  type 'a t = 'a option

  let return x = Some x
  let bind = Option.bind
  let mzero = None
  let (<|>) x y = match x with
    | Some _ -> x
    | None -> y
end


module ListMonad : (Monad with type 'a t = 'a list) = struct
  type 'a t = 'a list

  let return x = [x]
  let bind xs f =
    List.concat (List.map f xs)
  let mzero = []
  let (<|>) x y = x @ y
end

module MonadOps (M : Monad) = struct
  open M

  let ( let* ) = bind
  let ( let+ ) x f = bind x (fun x -> return (f x))

  let map f x = bind x (fun x -> return (f x))
end


(*
  We have many options to represent monads:
  - as records
  - using higher-rank polymorphism
  - with polymorphic constraint module arguments

  Also see: https://discuss.ocaml.org/t/generalizing-types-for-monadic-map/8935/2
*)