(lang dune 3.8)
(using coq 0.8)

(name rocq-print-assumptions-json)

(generate_opam_files true)

(license MIT)
(maintainers "Jason Gross <jason@theorem.dev>")
(authors "Jason Gross")
(source (github theorem-labs/rocq-structured-output-print-assumptions))
(bug_reports "https://github.com/theorem-labs/rocq-structured-output-print-assumptions/issues")
(homepage "https://github.com/theorem-labs/rocq-structured-output-print-assumptions")

(package
 (name rocq-print-assumptions-json)
 (synopsis "Structured JSON output for Print Assumptions")
 (description
  "A Rocq plugin providing variants of Print Assumptions that output results as JSON (compact or pretty-printed) or JSONL, for programmatic consumption.")
 (depends
  (ocaml (>= 4.14))
  (dune :build)
  (ppx_optcomp :build)
  (rocq-core (or (>= 9.0) (= dev)))
  (coq-core (or (>= 9.0) (= dev)))
  (rocq-stdlib :with-test)))
