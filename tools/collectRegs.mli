(****************************************************************************)
(*                           the diy toolsuite                              *)
(*                                                                          *)
(* Jade Alglave, University College London, UK.                             *)
(* Luc Maranget, INRIA Paris-Rocquencourt, France.                          *)
(*                                                                          *)
(* Copyright 2016-present Institut National de Recherche en Informatique et *)
(* en Automatique and the authors. All rights reserved.                     *)
(*                                                                          *)
(* This software is governed by the CeCILL-B license under French law and   *)
(* abiding by the rules of distribution of free software. You can use,      *)
(* modify and/ or redistribute the software under the terms of the CeCILL-B *)
(* license as circulated by CEA, CNRS and INRIA at the following URL        *)
(* "http://www.cecill.info". We also give a copy in LICENSE.txt.            *)
(****************************************************************************)

(* Collect registers from tests *)


module Make(A:Arch_tools.S) : sig
  val collect_constr : (A.location, A.v, A.fault_type) ConstrGen.prop ConstrGen.constr ->
                       A.RegSet.t A.ProcMap.t -> A.RegSet.t A.ProcMap.t

  val collect_locs : (A.location, A.v, A.fault_type) LocationsItem.t list ->
                     A.RegSet.t A.ProcMap.t -> A.RegSet.t A.ProcMap.t

  val collect_code : A.pseudo list -> A.RegSet.t
  val collect : A.test -> A.RegSet.t  A.ProcMap.t
end
