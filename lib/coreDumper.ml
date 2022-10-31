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

(******************)
(* Core test dump *)
(******************)
module type I = sig

  val arch : Archs.t

  type prog
  val print_prog : out_channel -> prog -> unit
  val dump_prog_lines : prog -> string list

  type v
  val dump_v : v -> string

  type state
  val dump_state : state -> string list

  type prop
  val dump_prop : prop -> string
  val dump_constr : prop ConstrGen.constr -> string

  type location
  val dump_location : location -> string

  type fault_type
  val dump_fault_type : fault_type -> string
end

module type S = sig
  type test

  val dump : out_channel -> Name.t -> test -> unit
  val dump_info : out_channel -> Name.t -> test -> unit
  val lines : Name.t -> test -> string list
end

module Make(I:I) :
S with
  type test = (I.state, I.prog, I.prop, I.location,I.v,I.fault_type) MiscParser.result
= struct

  type test = (I.state, I.prog, I.prop, I.location,I.v,I.fault_type) MiscParser.result

  open Printf
  open I
  open MiscParser

  let dump_locations locs =
    DumpUtils.dump_locations I.dump_location I.dump_v I.dump_fault_type locs

  let do_dump withinfo chan doc t =
    fprintf chan "%s %s\n" (Archs.pp I.arch) doc.Name.name ;
    if withinfo then begin
      List.iter
        (fun (k,i) -> fprintf chan "%s=%s\n" k i)
        t.info
    end else begin
      List.iter
        (fun (k,i) ->
          if k = MiscParser.stable_key then fprintf chan "%s=%s\n" k i)
        t.info
    end ;
    begin match doc.Name.doc with
    | "" -> ()
    | doc -> fprintf chan "\"%s\"\n" doc
    end ;
    fprintf chan "\n{\n%s}\n"
      (String.concat ""
         (List.map (sprintf " %s\n") (dump_state  t.init))) ;
    I.print_prog chan t.prog ;
    fprintf chan "\n" ;
    begin match t.locations with
    | [] -> ()
    | locs ->
        fprintf chan "%s\n" (dump_locations locs)
    end ;
    fprintf chan "%s\n" (I.dump_constr t.condition) ;
    ()

  let dump = do_dump false
  let dump_info = do_dump true

  let (@@) f k = f k

  let lines doc t =
    begin fun k -> sprintf "%s %s" (Archs.pp I.arch) doc.Name.name :: k
    end @@
    begin fun k -> match doc.Name.doc with
    | "" -> k
    | doc -> sprintf "\"%s\"" doc :: k
    end @@
      begin
        fun k ->
        "{" ::
          List.fold_right
            (fun s k -> sprintf " %s" s::k)
            (dump_state  t.init) ("}":: k)
    end @@
    begin
      fun k ->
      let pp = I.dump_prog_lines t.prog in
      pp @ ""::k
    end @@
    begin fun k ->
      match t.locations with
      | [] -> k
      | locs ->
        dump_locations locs::k
    end @@
    [I.dump_constr t.condition]
end
