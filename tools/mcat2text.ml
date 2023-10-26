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

(** List files imported from a cat file *)

open Printf

let prog =
  if Array.length Sys.argv > 0 then
    Filename.basename Sys.argv.(0)
  else "cat2includes7"

module Make
    (O:sig
      val verbose : int
      val includes : string list
    end) =
  struct
    module ML =
      MyLib.Make
        (struct
          let includes = O.includes
          let env =  Some "HERDLIB"
          let libdir = Filename.concat Version.libdir "herd"
          let debug = O.verbose > 0
        end)

    module ParserConfig = struct
      let debug = O.verbose > 1
      let libfind = ML.find
    end

    module Parser = ParseModel.Make(ParserConfig)

    let rec get_ast fname =
        let _fname0,(_,_,ast)  = Parser.find_parse fname in
        get_imports ast

    and get_imports ast = List.iter get_ins ast

    and dict = [
      ("ca", "Coherence-after");
      ("fr", "From-read");
      ("co", "Coherence-order");
      ("obs", "Observed-by");
      ("dob", "Dependency-ordered-before");
      ("aob", "Atomic-ordered-before");
      ("bob", "Barrier-ordered-before");
      ("ob", "Ordered-before");
      ("tlbi-ob", "TLBI-ordered-before");
    ]

    and dict1 = [
      ("co", fun e1 e2 -> sprintf "E%i is Coherence-order-after E%i" e2 e1);
      ("fr", fun e1 e2 -> sprintf "E%i is From-read-after E%i" e2 e1);
      ("addr", sprintf "There is an Address Dependency from R%i to RW%i");
      ("data", sprintf "There is a Data Dependency from R%i to RW%i");
      ("ctrl", sprintf "There is a Control Dependency from R%i to RW%i");
      ("W", sprintf "RW%i is a Write Memory Effect W%i");
      ("hw-reqs", sprintf "E%i is Hardware-Required-before E%i");
    ]

    and pp_op1 =
      let open AST in
      function
      | Plus -> "plus"
      | Star -> "star"
      | Opt -> "opt"
      | Comp -> "comp"
      | Inv -> "inv"
      | ToId -> "toid"

    and get_ins ins =
      let open AST in
      match ins with
      | Rec (_,(_,Pvar (Some rel), def) :: _,_)
      | Let (_, (_,Pvar (Some rel), def) :: _) ->
        begin
          match List.assoc_opt rel dict with
          | Some headline ->
            printf "%s\n" headline ;
            printf "An effect E1 is %s another effect E2 if any of the following applies:\n" headline;
            let rec pp_exp e1 e2 = function
              | Op (_, Union, exps) ->
                "* " ^ String.concat "\n* " (List.map (pp_exp e1 e2) exps) ;
              | Op (_, Seq, exps) ->
                String.concat ", " (List.map (pp_exp e1 e2) exps) ;
              | Var (_, rel) ->
                begin
                  match List.assoc_opt rel dict1 with
                  | Some f -> f e1 e2
                  | None -> ""
                end
              | Op (_, Inter, exps) ->
                String.concat " and " (List.map (pp_exp e1 e2) exps)
              | Konst _ -> "Konst"
              | Tag _ -> "Tag"
              | Op _ -> "Op"
              | Op1 (_, op1, exp) -> sprintf "Op1-%s %s" (pp_op1 op1) (pp_exp e1 e2 exp)
              | App _ -> "App"
              | Bind _ -> "Bind"
              | _ ->
                assert false
            in
            printf "%s\n\n" (pp_exp 1 2 def)
          | None ->
            ()
        end
      | _ -> ()

    let zyva name =
      try
        get_ast name
      with
      | Misc.Fatal msg -> printf "ERROR %s\n%!" msg
      | Misc.Exit -> ()
  end

let verbose = ref 0
let includes = ref []
let arg = ref []

let setarg name = arg := !arg @ [name]

let opts =
  [
   "-v",Arg.Unit (fun () -> incr verbose), " be verbose";
   "-I",Arg.String (fun s -> includes := !includes @ [s]),
   "<dir> add <dir> to search path";
  ]

let () =
  Arg.parse opts setarg
    (sprintf "Usage: %s [options]* cats*" prog)


module Z =
  Make
    (struct
      let verbose = !verbose
      let includes = !includes
    end)

let () = List.iter Z.zyva !arg ; exit 0
