(lang dune 3.11)

(name sat)

(generate_opam_files true)

(source
 (github NeuralCoder3/ocaml-sat))

(authors "Marcel Ullrich")

(maintainers "Marcel Ullrich")

(license LICENSE)

(documentation https://github.com/NeuralCoder3/ocaml-sat)

(package
 (name sat)
 (synopsis "Boolean satisfiability solver")
 (description "A simply DPLL-like approach to boolean formula satisfiability in propositional logic. CNF transformation via tseytin.")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
