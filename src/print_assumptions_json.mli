type output_format = Compact | Pretty | Jsonl

type assumption_mode =
  | Assumptions
  | OpaqueOnly
  | Transparent
  | AllDeps

val print_structured :
  opaque_access:Global.indirect_accessor ->
  assumption_mode -> output_format ->
  Libnames.qualid Constrexpr.or_by_notation list -> unit
