(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2023 --  Inria - CNRS - Paris-Saclay University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

(** {2 User-defined strategies} *)

type instruction =
  | Icall_prover of Whyconf.prover * float option * int option * int option
    (** timelimit (if none use default timelimit),
        memlimit (if none use default memlimit)
        steplimit (if none use no step limit)
     *)
  | Itransform of string * int (** successor state on success *)
  | Igoto of int (** goto state *)

type t = instruction array
