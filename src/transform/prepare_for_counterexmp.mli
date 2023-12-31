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

val prepare_for_counterexmp :  Env.env -> Task.task Trans.trans
 (**
    Transformation that prepares the task for querying for
    the counter-example model.
    This transformation does so only when the solver will be asked
    for the counter-example.
 *)
