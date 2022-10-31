(****************************************************************************)
(*                           the diy toolsuite                              *)
(*                                                                          *)
(* Jade Alglave, University College London, UK.                             *)
(* Luc Maranget, INRIA Paris-Rocquencourt, France.                          *)
(*                                                                          *)
(* Copyright 2019-present Institut National de Recherche en Informatique et *)
(* en Automatique and the authors. All rights reserved.                     *)
(*                                                                          *)
(* This software is governed by the CeCILL-B license under French law and   *)
(* abiding by the rules of distribution of free software. You can use,      *)
(* modify and/ or redistribute the software under the terms of the CeCILL-B *)
(* license as circulated by CEA, CNRS and INRIA at the following URL        *)
(* "http://www.cecill.info". We also give a copy in LICENSE.txt.            *)
(****************************************************************************)

(** External view of faults, which are part of final state *)
open Printf

module type I = sig
  type arch_global
  val pp_global : arch_global -> string
  val global_compare : arch_global -> arch_global -> int
  val same_id_fault : arch_global -> arch_global -> bool

  type fault_type
  val pp_fault_type : fault_type -> string
end

type ('loc, 'ftype) atom =  (Proc.t * Label.t option) * 'loc * 'ftype option

let pp_gen f pp_lbl pp_loc pp_ft (lbl,x,ft) =
  let ft = match ft with
    | Some ft -> sprintf ",%s" (pp_ft ft)
    | None -> "" in
  sprintf "%s(%s,%s%s)" f (pp_lbl lbl) (pp_loc x) ft

let pp_fatom pp_loc =
  pp_gen "fault"
    (fun (p,lbl) -> match lbl with
    | None -> Proc.pp p
    | Some lbl -> sprintf "%s:%s" (Proc.pp p) (Label.pp lbl))
    pp_loc

let atom_compare compare ((p1,lbl1),v1,_ft1) ((p2,lbl2),v2,_ft2) = match Proc.compare p1 p2 with
| 0 ->
    begin match Misc.opt_compare String.compare lbl1 lbl2 with
    | 0 -> compare v1 v2
    | r -> r
    end
| r -> r

let map_value f (p,v,ft) = (p,f v,ft)

module type S = sig

  type loc_global
  type fault_type

  type fault = (Proc.t * Label.Set.t) * loc_global * fault_type option * string option
  val pp_fault : fault -> string
  module FaultSet : MySet.S with type elt = fault

  type fatom = (loc_global,fault_type) atom
  val check_one_fatom : fault -> fatom -> bool
  val check_fatom : FaultSet.t -> fatom -> bool
  module FaultAtomSet : MySet.S with type elt = fatom
end

module Make(A:I) =
  struct

    type loc_global = A.arch_global
    type fault_type = A.fault_type
    type fault = (Proc.t * Label.Set.t) * loc_global * fault_type option * string option

    let pp_lbl (p,lbl) = match Label.Set.as_small 1 lbl with
    | Some [] ->  Proc.pp p
    | Some [lbl] -> sprintf "%s:%s" (Proc.pp p) (Label.pp lbl)
    | _ ->
        sprintf "%s:{%s}" (Proc.pp p)
          (Label.Set.pp_str "," Label.pp lbl)


    let pp_fault (lbl,x,ftype,msg) =
      let ftype = match ftype with
        | Some ftype -> sprintf ",%s" (A.pp_fault_type ftype)
        | None -> "" in
      match msg with
      | Some msg ->
         sprintf "Fault(%s,%s,%s%s)" (pp_lbl lbl) (A.pp_global x) msg ftype
      | None ->
         sprintf "Fault(%s,%s%s)" (pp_lbl lbl) (A.pp_global x) ftype


    let compare_lbl (p1,lbl1) (p2,lbl2) = match Proc.compare p1 p2 with
    | 0 -> Label.Set.compare lbl1 lbl2
    | r -> r

    let compare_fault_type ftype1 ftype2 = match ftype1, ftype2 with
      | Some ft1, Some ft2 when ft1 = ft2 -> 0
      | None, None -> 0
      | Some _ft1, Some _ft2 -> 1 (* TODO: fault priorities? *)
      | _, None -> 1
      | None, _ -> -1

    let compare (lbl1,x1,ftype1,msg1) (lbl2,x2,ftype2,msg2) = match compare_lbl lbl1 lbl2 with
    | 0 ->
      begin match A.global_compare x1 x2 with
      | 0 -> begin match compare_fault_type ftype1 ftype2 with
             | 0 -> Misc.opt_compare String.compare msg1 msg2
             | r -> r
             end
      | r -> r
      end
    | r -> r

    module FaultSet =
      MySet.Make
        (struct
          type t = fault
          let compare = compare
        end)

    type fatom = (loc_global,fault_type) atom

    let check_one_fatom ((p0,lbls0),x0,ftype0,_)  ((p,lblo),x,ftype) =
      Proc.compare p p0 = 0 &&
      A.same_id_fault x x0 &&
      begin match lblo with
      | None -> true
      | Some lbl -> Label.Set.mem lbl lbls0
      end &&
      begin match ftype0, ftype with
      | _, None -> true
      | Some ft0, Some ft when ft0 = ft -> true
      | _, _ -> false
      end

    let check_fatom flts a =
      FaultSet.exists
        (fun flt -> check_one_fatom flt a)
        flts

    module FaultAtomSet =
      MySet.Make
        (struct
          type t = fatom
          let compare ((p0,lbl0),x0,_ft0)  ((p1,lbl1),x1,_ft1) =
            match Proc.compare p0 p1 with
            | 0 ->
                begin match Misc.opt_compare Label.compare lbl0 lbl1 with
                | 0 -> A.global_compare x0 x1
                | r -> r
                end
            | r -> r
        end)
  end
