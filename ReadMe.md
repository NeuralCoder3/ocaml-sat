# Boolean Satisfiability

We present a simple satisfiability solver for boolean formulas in propositional logic.

The steps for solving are:
- Simplify complex expressions such as $\leftrightarrow$ and $\to$ into only $\land$, $\lor$, $\lnot$, and variables
- Use the [Tseytin transformation](https://en.wikipedia.org/wiki/Tseytin_transformation) to simplify further and transform to CNF
- Use a DPLL-like approach to go through all assignments and stop if a satisfying assignment was found

## Tranformations

Each transformation step ensures the shape of the result statically by enforcing strict restrictions on the types.
By construction, the simple expression type can only represent formulas using $\land$, $\lor$, $\lnot$, and variables.
Furthermore, the CNF type can only represent formulas in CNF.

The Tseytin transformation introduces variables $x_i$ for each subexpression and adds constraint of the form $x_i \leftrightarrow e$.
| Subexpression | Constraints |
| ------------- | ----------- |
| $Y\land Z$    | $X\lor \lnot Y\lor \lnot Z$, $\lnot X\lor Y$, $\lnot X \lor Z$ |
| $Y\lor Z$     | $\lnot X\lor Y\lor Z$, $X\lor \lnot Y$, $X \lor \lnot Z$ |
| $\lnot Y$     | $\lnot X\lor \lnot Y$, $X\lor Y$ |

Alternative transformations (among others) would be:
- Repeated application of [DeMorgan](https://en.wikipedia.org/wiki/De_Morgan%27s_laws) -- may lead to exponential blow-up
- [Karnaugh-Veitch](https://en.wikipedia.org/wiki/Karnaugh_map) / [Quine-McCluskey](https://en.wikipedia.org/wiki/Quine%E2%80%93McCluskey_algorithm) -- too expensive; the transformation corresponds to solving the formula

## DPLL

We use a simplified [DPLL](https://en.wikipedia.org/wiki/DPLL_algorithm) algorithm for demonstration.

- If a clause is just one literal, set this literal
- Propagate unit literals (remove all clauses with this literal and remove the negated literal in other clauses)
- Choose pure literals (same across all clauses)
- Make a decision about an arbitrary literal otherwise

No [CDCL](https://en.wikipedia.org/wiki/Conflict-driven_clause_learning) optimizations in the form of clause-learning for conflicts are applied.

The algorithm in `dpll.ml` exactly performs this algorithm in this order:
- Helper function for propagation of literal decisions
- Check if all clauses are satisfied (empty conjunction) => finished
- Check if empty clause => false clause => unsatisfiable
- Find clauses of length one (unit clauses), propagate unit literal
- choose arbitrary literal otherwise and decide upon it

The implementation uses the observation that one can generalize DPLL to general all (distinct) solutions by replacing the decision part.
Usually, one tries the positive literal decision and if this fails, tries the negative one.
Instead, if we try both literals, we enumerate all possibilities.
The only other difference is that the unit propagation now adds its decision to all possible solutions instead of just one.

Implementationwise, this corresponds to replacing the option map and None return with the list map and empty list return.
Hence, one can formulate the code as operating on a monad where the default implementation is the special case of the option monad and enumerating all solutions is the case for the list monad.

The combination for the decision case can be implemented using the [MPlus monoid](https://wiki.haskell.org/MonadPlus) which both options and lists satisfy in a simplified form that is sufficient for this use case.

For the implementation of the monad, monad extensions, and monad operations, we chose modules and functors.

Note that with pure literal, no longer all solutions are found.
Pure literals is a one-sided approximation.