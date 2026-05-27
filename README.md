# rocq-print-assumptions-json

Structured JSON output for `Print Assumptions` in [the Rocq Prover](https://rocq-prover.org/).

Provides `Print Assumptions JSON`, `Print Assumptions JSON Pretty`, and `Print Assumptions JSONL` commands (plus variants for opaque, transparent, and all dependencies) for programmatic consumption of assumption data.

## Install

### From opam (extra-dev)

```sh
opam repo add rocq-extra-dev https://rocq-prover.org/opam/extra-dev
opam install rocq-print-assumptions-json
```

### From source

```sh
git clone https://github.com/theorem-labs/rocq-structured-output-print-assumptions.git
cd rocq-structured-output-print-assumptions
opam install . --deps-only
dune build
dune install
```

## Usage

```coq
From PrintAssumptionsJSON Require Import PrintAssumptionsJSON.

Axiom my_axiom : nat.
Definition foo := my_axiom + 1.

(* Compact one-line JSON *)
Print Assumptions JSON foo.
(* {"terms":["foo"],"assumptions":[{"name":"my_axiom","kind":"axiom","type":"nat"}]} *)

(* Pretty-printed JSON *)
Print Assumptions JSON Pretty foo.
(* {
     "terms": ["foo"],
     "assumptions": [
       {
         "name": "my_axiom",
         "kind": "axiom",
         "type": "nat"
       }
     ]
   } *)

(* JSONL — one JSON object per assumption per line *)
Print Assumptions JSONL foo.
(* {"name":"my_axiom","kind":"axiom","type":"nat"} *)

(* Multiple references at once *)
Print Assumptions JSON foo bar baz.
```

### Dependency variants

These mirror the standard Rocq commands and accept the same three output formats (`JSON`, `JSON Pretty`, `JSONL`):

| Command | Shows |
|---------|-------|
| `Print Assumptions JSON` | Axioms and section variables |
| `Print Opaque Dependencies JSON` | Also includes opaque constants |
| `Print Transparent Dependencies JSON` | Also includes transparent constants |
| `Print All Dependencies JSON` | Opaque + transparent |

### Output schema

Each assumption object has three fields:

| Field | Description |
|-------|-------------|
| `name` | Fully qualified name |
| `kind` | One of `axiom`, `variable`, `opaque`, `transparent`, `positive`, `guarded`, `type_in_type`, `uip` |
| `type` | Pretty-printed type string |

The `JSON` and `JSON Pretty` formats wrap assumptions in an envelope:

```json
{
  "terms": ["<ref1>", "<ref2>"],
  "assumptions": [<assumption>, ...]
}
```

`JSONL` outputs bare assumption objects, one per line.

## Compatibility

Supports Rocq 9.0, 9.1, 9.2, and dev.

## License

MIT
