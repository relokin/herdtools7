(****************************************************************************)
(*                           the diy toolsuite                              *)
(*                                                                          *)
(* Jade Alglave, University College London, UK.                             *)
(* Luc Maranget, INRIA Paris-Rocquencourt, France.                          *)
(*                                                                          *)
(* Copyright 2020-present Institut National de Recherche en Informatique et *)
(* en Automatique and the authors. All rights reserved.                     *)
(*                                                                          *)
(* This software is governed by the CeCILL-B license under French law and   *)
(* abiding by the rules of distribution of free software. You can use,      *)
(* modify and/ or redistribute the software under the terms of the CeCILL-B *)
(* license as circulated by CEA, CNRS and INRIA at the following URL        *)
(* "http://www.cecill.info". We also give a copy in LICENSE.txt.            *)
(****************************************************************************)

type t = ((Proc.t * string option) * string * string option)

let equal ((p1,lab1),x1,ft1) ((p2,lab2),x2,ft2) =
  Proc.equal p1 p2 &&
  Misc.opt_eq Misc.string_eq lab1 lab2 &&
  Misc.string_eq x1 x2 &&
  begin match ft1, ft2 with
  | None, _ | _, None -> true
  | Some ft1, Some ft2 when Misc.string_eq ft1 ft2 -> true
  | _, _ -> false
  end

let pp ((p,lab),v,ft) =
  Printf.sprintf "fault(%s%s,%s%s)"
    (Proc.pp p) (match lab with None -> "" | Some lab -> ":"^lab) v
    (match ft with None -> "" | Some ft -> ","^ft)
