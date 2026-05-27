open Names

[%%if coq = "9.0" || coq = "9.1"]
let assumptions ~opaque_access st ~add_opaque ~add_transparent grs =
  List.fold_left (fun acc gr ->
    let env = Global.env () in
    let cstr, _ = UnivGen.fresh_global_instance env gr in
    let m = Assumptions.assumptions ~add_opaque ~add_transparent opaque_access st gr cstr in
    Printer.ContextObjectMap.union (fun _ t1 _t2 -> Some t1) acc m
  ) Printer.ContextObjectMap.empty grs
[%%else]
let assumptions ~opaque_access st ~add_opaque ~add_transparent grs =
  Assumptions.assumptions ~add_opaque ~add_transparent opaque_access st grs
[%%endif]
