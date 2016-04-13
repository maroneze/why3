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

open Model_parser

(** {1 Call provers and parse their outputs} *)

(** {2 data types for prover answers} *)

(** The reason why unknown was reported *)
type reason_unknown =
  | Resourceout
  (** Out of resources  *)
  | Other
  (** Other reason *)

type prover_answer =
  | Valid
      (** The task is valid according to the prover *)
  | Invalid
      (** The task is invalid *)
  | Timeout
      (** the task timeouts, ie it takes more time than specified *)
  | OutOfMemory
      (** the task runs out of memory *)
  | StepLimitExceeded
      (** the task required more steps than the limit provided *)
  | Unknown of (string * reason_unknown option)
      (** The prover can't determine if the task is valid *)
  | Failure of string
      (** The prover reports a failure *)
  | HighFailure
      (** An error occured during the call to the prover or none
          of the given regexps match the output of the prover *)

type prover_result = {
  pr_answer : prover_answer;
  (** The answer of the prover on the given task *)
  pr_status : Unix.process_status;
  (** The process exit status *)
  pr_output : string;
  (** The output of the prover currently stderr and stdout *)
  pr_time   : float;
  (** The time taken by the prover *)
  pr_steps  : int;
  (** The number of steps taken by the prover (-1 if not available) *)
  pr_model  : model;
  (** The model produced by a the solver *)
}

val print_prover_answer : Format.formatter -> prover_answer -> unit
(** Pretty-print a {! prover_answer} *)

val print_prover_result : Format.formatter -> prover_result -> unit
(** Pretty-print a prover_result. The answer and the time are output.
    The output of the prover is printed if and only if the answer is
    a [HighFailure] *)

val debug : Debug.flag
(** debug flag for the calling procedure (option "--debug call_prover")
    If set [call_on_buffer] prints on stderr the commandline called
    and the output of the prover. *)

type timeregexp
(** The type of precompiled regular expressions for time parsing *)

type stepregexp
(** The type of precompiled regular expressions for parsing of steps *)

val timeregexp : string -> timeregexp
(** Converts a regular expression with special markers '%h','%m',
    '%s','%i' (for milliseconds) into a value of type [timeregexp] *)

val stepregexp : string -> int -> stepregexp
(** [stepregexp s n] creates a regular expression to match the number of steps.
    [s] is a regular expression, [n] is the group number with steps number. *)

type prover_result_parser = {
  prp_regexps     : (Str.regexp * prover_answer) list;
  prp_timeregexps : timeregexp list;
  prp_stepregexps : stepregexp list;
  prp_exitcodes   : (int * prover_answer) list;
  (* The parser for a model returned by the solver. *)
  prp_model_parser : Model_parser.model_parser;
}
(*
    if the first field matches the prover output,
    the second field is the answer. Regexp groups present in
    the first field are substituted in the second field (\0,\1,...).
    The regexps are tested in the order of the list.

    @param timeregexps : a list of regular expressions with special
    markers '%h','%m','%s','%i' (for milliseconds), constructed with
    [timeregexp] function, and used to extract the time usage from
    the prover's output. If the list is empty, wallclock is used.
    The regexps are tested in the order of the list.

    @param exitcodes : if the first field is the exit code, then
    the second field is the answer. Exit codes are tested in the order
    of the list and before the regexps.
*)

(** {2 Functions for calling external provers} *)
type prover_call
(** Type that represents a single prover run *)

type pre_prover_call = unit -> prover_call
(** Thread-safe closure that launches the prover *)

type post_prover_call = unit -> prover_result
(** Thread-unsafe closure that interprets the prover's results *)

type resource_limit =
  {
    limit_time  : int option;
    limit_mem   : int option;
    limit_steps : int option;
  }
(* represents the three ways a prover run can be limited: in time, memory
   and/or steps *)

val empty_limit : resource_limit
(* the limit object which imposes no limits *)

val limit_max : resource_limit -> resource_limit -> resource_limit
(* return the limit object whose components represent the maximum of the
   corresponding components of the arguments *)

val get_time : resource_limit -> int
(* return time, return default value 0 if not set *)
val get_mem : resource_limit -> int
(* return time, return default value 0 if not set *)
val get_steps : resource_limit -> int
(* return time, return default value 0 if not set *)

val mk_limit : int -> int -> int -> resource_limit
(* build a limit object, transforming the default values into None on the fly
   *)

val call_editor : command : string -> string -> pre_prover_call

val call_on_file :
  command         : string ->
  limit           : resource_limit ->
  res_parser      : prover_result_parser ->
  printer_mapping : Printer.printer_mapping ->
  ?inplace        : bool ->
  string -> pre_prover_call

val call_on_buffer :
  command         : string ->
  limit           : resource_limit ->
  res_parser      : prover_result_parser ->
  filename        : string ->
  printer_mapping : Printer.printer_mapping ->
  ?inplace        : bool ->
  Buffer.t -> pre_prover_call
(** Call a prover on the task printed in the {!type: Buffer.t} given.

    @param limit : set the available time limit (def. 0 : unlimited), memory
    limit (def. 0 : unlimited) and step limit (def. -1 : unlimited)

    @param res_parser : prover result parser

    @param filename : the suffix of the proof task's file, if the prover
    doesn't accept stdin. *)

val query_call : prover_call -> post_prover_call option
(** non-blocking function that checks if the prover has finished. *)

val wait_on_call : prover_call -> post_prover_call
(** blocking function that waits until the prover finishes. *)

val set_socket_name : string -> unit
