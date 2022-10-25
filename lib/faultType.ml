(****************************************************************************)
(*                           the diy toolsuite                              *)
(*                                                                          *)
(* Jade Alglave, University College London, UK.                             *)
(* Luc Maranget, INRIA Paris-Rocquencourt, France.                          *)
(*                                                                          *)
(* Copyright 2021-present Institut National de Recherche en Informatique et *)
(* en Automatique and the authors. All rights reserved.                     *)
(*                                                                          *)
(* This software is governed by the CeCILL-B license under French law and   *)
(* abiding by the rules of distribution of free software. You can use,      *)
(* modify and/ or redistribute the software under the terms of the CeCILL-B *)
(* license as circulated by CEA, CNRS and INRIA at the following URL        *)
(* "http://www.cecill.info". We also give a copy in LICENSE.txt.            *)
(****************************************************************************)

(* Memory types of global variables *)
module type S = sig
  type t

  val sets : (t * string) list

  val pp : t -> string (* Pretty print *)
end

module type AArch64Sig = sig
  type t =
    | EXC_DATA_ABORT
    | EXC_TAG_CHECK

  include S with type t := t
end

module AArch64 = struct
  type t =
    | EXC_DATA_ABORT
    | EXC_TAG_CHECK

  let sets = [
      EXC_DATA_ABORT, "EXC-DATA-ABORT";
      EXC_TAG_CHECK, "EXC-TAG-CHECK";
    ]

  let pp ftype0 =
    let _,s = List.find (fun (ftype,_) -> ftype = ftype0) sets in
    s
end

module No = struct

  type t = unit

  let sets = []

  let pp () = "Default"
end
