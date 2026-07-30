(****************************************************************************)
(*                           the diy toolsuite                              *)
(*                                                                          *)
(* Jade Alglave, University College London, UK.                             *)
(* Luc Maranget, INRIA Paris, France.                                       *)
(*                                                                          *)
(* Copyright 2026-present Institut National de Recherche en Informatique et *)
(* en Automatique, ARM Ltd and the authors. All rights reserved.            *)
(*                                                                          *)
(* This software is governed by the CeCILL-B license under French law and   *)
(* abiding by the rules of distribution of free software. You can use,      *)
(* modify and/ or redistribute the software under the terms of the CeCILL-B *)
(* license as circulated by CEA, CNRS and INRIA at the following URL        *)
(* "http://www.cecill.info". We also give a copy in LICENSE.txt.            *)
(****************************************************************************)

type t =
  | AddrReg of AArch64AddrReg.t
  | TCR_EL1 of tcr

and tcr = {
  sh : string option;
  irgn : string option;
  orgn : string option;
}

let default = AddrReg AArch64AddrReg.default

let default_tcr = { sh=None; irgn=None; orgn=None; }

let has_tcr_field p =
  StringMap.exists
    (fun k _ -> String.equal k "SH" || String.equal k "IRGN" || String.equal k "ORGN")
    p.ParsedAddrReg.p_kv

let check_value field allowed v =
  if List.mem v allowed then v
  else
    Warn.user_error
      "TCR_EL1 field %s should be one of %s"
      field (String.concat ", " allowed)

let add_tcr_field k v p =
  match k with
  | "SH" -> { p with sh = Some (check_value k ["NSH"; "ISH"; "OSH"] v) }
  | "IRGN" -> { p with irgn = Some (check_value k ["WB"; "WT"; "NC"] v) }
  | "ORGN" -> { p with orgn = Some (check_value k ["WB"; "WT"; "NC"] v) }
  | _ -> Warn.user_error "Illegal TCR_EL1 property %s" k

let tr_tcr p =
  if Option.is_some p.ParsedAddrReg.p_oa then
    Warn.user_error "Illegal combination: TCR_EL1 fields and OA are present";
  StringMap.fold add_tcr_field p.ParsedAddrReg.p_kv default_tcr

let tr p =
  if has_tcr_field p then TCR_EL1 (tr_tcr p)
  else AddrReg (AArch64AddrReg.tr p)

let pp_tcr p =
  let field k = function
    | None -> ""
    | Some v -> Printf.sprintf "%s:%s" k v in
  let fields =
    List.filter (fun s -> s <> "")
      [ field "SH" p.sh;
        field "IRGN" p.irgn;
        field "ORGN" p.orgn; ] in
  Printf.sprintf "(tcr_el1_t:(%s))" (String.concat ", " fields)

let pp hexa = function
  | AddrReg r -> AArch64AddrReg.pp hexa r
  | TCR_EL1 r -> pp_tcr r

let pp_v = pp false

let pp_norm p =
  let n = tr p in
  pp_v n

let compare t1 t2 =
  match t1,t2 with
  | AddrReg r1, AddrReg r2 -> AArch64AddrReg.compare r1 r2
  | TCR_EL1 r1, TCR_EL1 r2 ->
      let cmp = Misc.opt_compare String.compare r1.sh r2.sh in
      if cmp <> 0 then cmp
      else
        let cmp = Misc.opt_compare String.compare r1.irgn r2.irgn in
        if cmp <> 0 then cmp
        else Misc.opt_compare String.compare r1.orgn r2.orgn
  | AddrReg _, TCR_EL1 _ -> -1
  | TCR_EL1 _, AddrReg _ -> 1

let eq t1 t2 =
  match t1,t2 with
  | AddrReg r1, AddrReg r2 -> AArch64AddrReg.eq r1 r2
  | TCR_EL1 r1, TCR_EL1 r2 ->
      Option.equal String.equal r1.sh r2.sh
      && Option.equal String.equal r1.irgn r2.irgn
      && Option.equal String.equal r1.orgn r2.orgn
  | (AddrReg _, TCR_EL1 _) | (TCR_EL1 _, AddrReg _) -> false

let dump_pack pp_oa = function
  | AddrReg r -> AArch64AddrReg.dump_pack pp_oa r
  | TCR_EL1 _ -> assert false

let fields = AArch64AddrReg.fields
and default_fields = AArch64AddrReg.default_fields

let tcr_attrs = function
  | TCR_EL1 r ->
      let cacheability prefix = function
        | None -> []
        | Some v -> [prefix ^ v] in
      let sh = match r.sh with None -> [] | Some v -> [v] in
      sh @ cacheability "i" r.irgn @ cacheability "o" r.orgn
  | AddrReg _ -> []
