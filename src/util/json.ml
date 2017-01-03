(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2016   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

open Format

let string fmt s =
  let b = Buffer.create (2 * String.length s) in
  Buffer.add_char b '"';
  for i = 0 to String.length s -1 do
    match s.[i] with
    | '"' -> Buffer.add_string b "\\\""
    | '\\' -> Buffer.add_string b "\\\\"
    | c -> Buffer.add_char b c
  done;
  Buffer.add_char b '"';
  fprintf fmt "%s" (Buffer.contents b)

let int fmt d = fprintf fmt "%d" d
let bool fmt b = fprintf fmt "%b" b
let float fmt f = fprintf fmt "%f" f
(* TODO check that you can print a floating point number like this in JSON *)

let print_json_field key value_pr fmt value =
  fprintf fmt "%a:%a" string key value_pr value

let list pr fmt l =
  if l = [] then fprintf fmt "[]"
  else
    Pp.print_list_delim ~start:Pp.lsquare ~stop:Pp.rsquare ~sep:Pp.comma
      pr fmt l

let print_map_binding key_to_str value_pr fmt binding =
  let (key, value) = binding in
  print_json_field (key_to_str key) value_pr fmt value

let map_bindings key_to_str value_pr fmt map_bindings =
  if map_bindings = [] then fprintf fmt "{}"
  else
    Pp.print_list_delim ~start:Pp.lbrace ~stop:Pp.rbrace ~sep:Pp.comma
      (print_map_binding key_to_str value_pr) fmt map_bindings

type value =
  | Obj of (string * value) list
  | Array of value list
  | String of string
  | Int of int
  | Float of float
  | Bool of bool
  | Null

let rec print fmt v =
  match v with
  | Obj l -> map_bindings (fun s -> s) print fmt l
  | Array l -> list print fmt l
  | String s -> string fmt s
  | Int i -> int fmt i
  | Float f -> float fmt f
  | Bool b -> bool fmt b
  | Null -> fprintf fmt "null"


let parse _s = failwith "Json.parse not yet implemented"
