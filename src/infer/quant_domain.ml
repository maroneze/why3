open Domain
open Term
open Ity

module Make(S:sig
    module A:TERM_DOMAIN
    val env: Env.env
    val th_known: Decl.known_map
    val mod_known: Pdecl.known_map
  end): TERM_DOMAIN = struct
  module A = S.A

  open Ai_logic
  module Ai_logic = Ai_logic.Make(struct
      let env = S.env
      let th_known = S.th_known
      let mod_known = S.mod_known
    end)
  open Ai_logic

  include A

  let quant_var, pv =
    let ident_ret = Ident.id_fresh "w" in
    let v = create_pvsymbol ident_ret ity_int in
    t_var v.pv_vs, v

  let create_manager () =
    let man = A.create_manager () in
    A.add_variable_to_env man pv;
    man

  let to_term man t =
    let t = A.to_term man t in
    descend_quantifier quant_var t

  let rec meet_term man term elt =
    match term.t_node with
    | Tbinop (Tor, a, b) ->
       join man (meet_term man a elt) (meet_term man b elt)
    | Tbinop (Tand, a, b) ->
       meet_term man b (meet_term man a elt)
    | Tbinop (Timplies, a, b) ->
       meet_term man (t_or (t_not a) b) elt
    | Tbinop (Tiff, a, b) ->
       meet_term man (t_and (t_implies a b) (t_implies b a)) elt
    | Tquant (Tforall, tq) ->
      begin
        match t_open_quant tq with
        | [a], _, t when (Ty.ty_equal a.vs_ty Ty.ty_int) ->
          let t = t_descend_nots t in
          let t = t_subst_single a quant_var t in
          meet_term man t elt
        | _ -> A.meet_term man term elt
      end
    | _ -> A.meet_term man term elt
end
