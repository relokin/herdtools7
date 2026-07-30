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

let default = AddrReg AArch64AddrReg.default

let tr p = AddrReg (AArch64AddrReg.tr p)

let pp hexa = function
  | AddrReg r -> AArch64AddrReg.pp hexa r

let pp_v = pp false

let pp_norm p =
  let n = tr p in
  pp_v n

let compare t1 t2 =
  match t1,t2 with
  | AddrReg r1, AddrReg r2 -> AArch64AddrReg.compare r1 r2

let eq t1 t2 =
  match t1,t2 with
  | AddrReg r1, AddrReg r2 -> AArch64AddrReg.eq r1 r2

let dump_pack pp_oa = function
  | AddrReg r -> AArch64AddrReg.dump_pack pp_oa r

let fields = AArch64AddrReg.fields
and default_fields = AArch64AddrReg.default_fields

let tcr_attrs _ = []
