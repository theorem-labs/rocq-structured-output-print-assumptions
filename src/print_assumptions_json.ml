open Names

type output_format = Compact | Pretty | Jsonl

type assumption_mode =
  | Assumptions
  | OpaqueOnly
  | Transparent
  | AllDeps

let json_escape s =
  let buf = Buffer.create (String.length s + 16) in
  String.iter (fun c ->
    match c with
    | '"'  -> Buffer.add_string buf "\\\""
    | '\\' -> Buffer.add_string buf "\\\\"
    | '\n' -> Buffer.add_string buf "\\n"
    | '\t' -> Buffer.add_string buf "\\t"
    | '\r' -> Buffer.add_string buf "\\r"
    | '\b' -> Buffer.add_string buf "\\b"
    | c when Char.code c < 0x20 ->
      Buffer.add_string buf (Printf.sprintf "\\u%04x" (Char.code c))
    | c -> Buffer.add_char buf c
  ) s;
  Buffer.contents buf

let json_string s = Printf.sprintf "\"%s\"" (json_escape s)

let pp_to_string pp = Pp.string_of_ppcmds pp

let gr_name gr =
  pp_to_string (Nametab.pr_global_env Id.Set.empty gr)

let constant_name kn =
  gr_name (GlobRef.ConstRef kn)

let mutind_name m =
  gr_name (GlobRef.IndRef (m, 0))

[%%if coq >= "9.3"]
let axiom_kind_and_name (ax : Printer.axiom) =
  match ax with
  | Constant kn -> ("axiom", constant_name kn)
  | Positive m -> ("positive", mutind_name m)
  | Guarded gr -> ("guarded", gr_name gr)
  | TypeInType gr -> ("type_in_type", gr_name gr)
  | UIP m -> ("uip", mutind_name m)
  | IndicesNotMattering m -> ("indices_not_mattering", mutind_name m)
[%%else]
let axiom_kind_and_name (ax : Printer.axiom) =
  match ax with
  | Constant kn -> ("axiom", constant_name kn)
  | Positive m -> ("positive", mutind_name m)
  | Guarded gr -> ("guarded", gr_name gr)
  | TypeInType gr -> ("type_in_type", gr_name gr)
  | UIP m -> ("uip", mutind_name m)
[%%endif]

let type_to_string env sigma typ =
  pp_to_string (Printer.pr_ltype_env env sigma typ)

let assumption_to_fields env sigma (obj : Printer.context_object) typ =
  match obj with
  | Variable id ->
    [("name", json_string (Id.to_string id));
     ("kind", json_string "variable");
     ("type", json_string (type_to_string env sigma typ))]
  | Axiom (ax, _inst) ->
    let (kind, name) = axiom_kind_and_name ax in
    [("name", json_string name);
     ("kind", json_string kind);
     ("type", json_string (type_to_string env sigma typ))]
  | Opaque kn ->
    [("name", json_string (constant_name kn));
     ("kind", json_string "opaque");
     ("type", json_string (type_to_string env sigma typ))]
  | Transparent kn ->
    [("name", json_string (constant_name kn));
     ("kind", json_string "transparent");
     ("type", json_string (type_to_string env sigma typ))]

let fields_to_json_oneline fields =
  let pairs = List.map (fun (k, v) -> Printf.sprintf "%s:%s" (json_string k) v) fields in
  Printf.sprintf "{%s}" (String.concat "," pairs)

let fields_to_json_pretty indent fields =
  let pad = String.make indent ' ' in
  let outer_pad = String.make (indent - 2) ' ' in
  let pairs = List.map (fun (k, v) ->
    Printf.sprintf "%s%s: %s" pad (json_string k) v
  ) fields in
  Printf.sprintf "%s{\n%s\n%s}" outer_pad (String.concat ",\n" pairs) outer_pad

let collect_assumptions ~opaque_access mode env grs =
  let st = Conv_oracle.get_transp_state (Environ.oracle env) in
  let add_opaque, add_transparent =
    match mode with
    | Assumptions  -> (false, false)
    | OpaqueOnly   -> (true, false)
    | Transparent  -> (false, true)
    | AllDeps      -> (true, true)
  in
  Compat.assumptions ~opaque_access st ~add_opaque ~add_transparent grs

let format_compact env sigma grs_names map =
  let assumptions = Printer.ContextObjectMap.fold (fun obj typ acc ->
    let fields = assumption_to_fields env sigma obj typ in
    fields_to_json_oneline fields :: acc
  ) map [] in
  let assumptions_str = Printf.sprintf "[%s]" (String.concat "," (List.rev assumptions)) in
  let terms_str = Printf.sprintf "[%s]" (String.concat "," (List.map json_string grs_names)) in
  Printf.sprintf "{\"terms\":%s,\"assumptions\":%s}" terms_str assumptions_str

let format_pretty env sigma grs_names map =
  let assumptions = Printer.ContextObjectMap.fold (fun obj typ acc ->
    let fields = assumption_to_fields env sigma obj typ in
    fields_to_json_pretty 6 fields :: acc
  ) map [] in
  let assumptions_str =
    if assumptions = [] then "[]"
    else Printf.sprintf "[\n%s\n  ]" (String.concat ",\n" (List.rev assumptions))
  in
  let terms_str =
    Printf.sprintf "[%s]" (String.concat ", " (List.map json_string grs_names))
  in
  Printf.sprintf "{\n  \"terms\": %s,\n  \"assumptions\": %s\n}" terms_str assumptions_str

let format_jsonl env sigma _grs_names map =
  let buf = Buffer.create 256 in
  Printer.ContextObjectMap.iter (fun obj typ ->
    let fields = assumption_to_fields env sigma obj typ in
    Buffer.add_string buf (fields_to_json_oneline fields);
    Buffer.add_char buf '\n'
  ) map;
  Buffer.contents buf

let print_structured ~opaque_access mode fmt refs =
  let env = Global.env () in
  let sigma = Evd.from_env env in
  let grs = List.map Smartlocate.smart_global refs in
  let grs_names = List.map gr_name grs in
  let map = collect_assumptions ~opaque_access mode env grs in
  let output =
    match fmt with
    | Compact -> format_compact env sigma grs_names map
    | Pretty  -> format_pretty env sigma grs_names map
    | Jsonl   -> format_jsonl env sigma grs_names map
  in
  Feedback.msg_info Pp.(str output)
