open Toy_crypto
module M = Numbers.Make (Bigint)

let write_n ?(ch=stdout) n =
  M.N.to_yojson n |>
  Yojson.Safe.to_channel ch

let encode () =
  read_line () |>
  M.of_string |>
  write_n

let read_n ?f () =
  let j =
    match f with
    | None -> Yojson.Safe.from_channel stdin
    | Some fn -> Yojson.Safe.from_file fn
  in
  match M.N.of_yojson j with
  | Result.Error e -> prerr_endline e; exit 1
  | Result.Ok n -> n

let decode () =
  read_n () |>
  M.to_string |>
  print_endline


module RSA = Rsa.Make (M)

let write_key ?(ch=stdout) k =
  RSA.export k |>
  Yojson.Safe.to_channel ch

let generate bits =
  let pub, priv = RSA.generate ~bits in
  write_key pub;
  write_key ~ch:stderr priv

let read_key k =
  match RSA.import @@ Yojson.Safe.from_file k with
  | Result.Error e -> prerr_endline e; exit 2
  | Result.Ok key -> key

let encrypt key =
  let pub = read_key key in
  read_n () |>
  RSA.encrypt pub |>
  write_n

let verify key f =
  let pub = read_key key in
  let signature = read_n ~f () in
  match read_n () |> RSA.check pub ~signature with
  | true -> print_endline "valid"
  | false -> print_endline "INVALID"

let decrypt key =
  let priv = read_key key in
  read_n () |>
  RSA.decrypt priv |>
  write_n

let sign key =
  let priv = read_key key in
  read_n () |>
  RSA.sign priv |>
  write_n


module DH = Diffie_hellman.Make (M)

let parameters bits =
  DH.generate ~bits |>
  DH.parameters_to_yojson |>
  Yojson.Safe.to_channel stdout

let read_params f =
  match DH.parameters_of_yojson @@ Yojson.Safe.from_file f with
  | Result.Error e -> prerr_endline e; exit 2
  | Result.Ok p -> p

let challenge params =
  let p = read_params params in
  let secret, chall = DH.challenge p in
  write_n ~ch:stderr secret;
  write_n ~ch:stdout chall

let derive params f =
  let p = read_params params in
  let secret = read_n ~f () in
  read_n () |>
  DH.derive p ~secret |>
  write_n

let read_codes ?f conv () =
  let j =
    match f with
    | None -> Yojson.Safe.from_channel stdin
    | Some fn -> Yojson.Safe.from_file fn
  in
  match DH.PSI.codes_of_yojson conv j with
  | Result.Error e -> prerr_endline e; exit 4
  | Result.Ok c -> c

let write_codes conv codes =
  DH.PSI.codes_to_yojson conv codes |>
  Yojson.Safe.to_channel stdout

let request params private_set =
  let params = read_params params in
  let plain =
    let l = ref [] in
    try
      while true do
        l := read_line () :: !l
      done;
      []
    with End_of_file ->
      !l
  in
  let ps, codes =
    let f x = Digest.string x |> M.of_string in
    DH.PSI.request params f plain
  in
  DH.PSI.to_yojson DH.PSI.str_to_yojson ps |> Yojson.Safe.to_file private_set;
  write_codes M.N.to_yojson codes

let read_private_set f =
  match Yojson.Safe.from_file f |> DH.PSI.of_yojson DH.PSI.str_of_yojson with
  | Result.Error e -> prerr_endline e; exit 3
  | Result.Ok ps -> ps

let reply params private_set =
  let params = read_params params in
  let private_set = read_private_set private_set in
  read_codes M.N.of_yojson () |>
  DH.PSI.reply params private_set |>
  DH.PSI.(map hash) |>
  write_codes DH.PSI.str_to_yojson

let inter params private_set other returned =
  let params = read_params params in
  let private_set = read_private_set private_set in
  let other =
    read_codes ~f:other M.N.of_yojson () |>
    DH.PSI.reply params private_set |>
    DH.PSI.(map hash)
  in
  let returned = read_codes ~f:returned DH.PSI.str_of_yojson () in
  DH.PSI.intersection private_set ~compare:compare ~other returned |>
  List.iter print_endline


open Cmdliner

let bits =
  let doc = "key size (in bits)" in
  Arg.(value & opt int 1024 & info ~doc ["b"; "bits"])

let generate_cmd =
  let doc = "generate an RSA keypair" in
  Term.(const generate $ bits),
  Term.info "rsa-keygen" ~doc

let public_key =
  let doc = "public key file" in
  Arg.(required & pos 0 (some file) None & info [] ~doc ~docv:"PUBKEY")

let encrypt_cmd =
  let doc = "encrypt the standard input's first line" in
  Term.(const encrypt $ public_key),
  Term.info "rsa-encrypt" ~doc

let verify_cmd =
  let signature_file =
    let doc = "signature file" in
    Arg.(required & pos 1 (some file) None & info [] ~doc ~docv:"SIG")
  in
  let doc = "verify the signature of the standard input's first line" in
  Term.(const verify $ public_key $ signature_file),
  Term.info "rsa-verify" ~doc

let private_key =
  let doc = "private key file" in
  Arg.(required & pos 0 (some file) None & info [] ~doc ~docv:"SECKEY")

let decrypt_cmd =
  let doc = "decrypt the standard input" in
  Term.(const decrypt $ private_key),
  Term.info "rsa-decrypt" ~doc

let sign_cmd =
  let doc = "sign one line of the standard input" in
  Term.(const sign $ private_key),
  Term.info "rsa-sign" ~doc

let parameters_cmd =
  let doc = "generate reusable Diffie-Hellman parameters" in
  Term.(const parameters $ bits),
  Term.info "dh-parameters" ~doc

let parameters_arg =
  let doc = "Diffie-Hellman parameter file" in
  Arg.(required & pos 0 (some file) None & info [] ~doc ~docv:"DH-PARAMS")

let challenge_cmd =
  let doc = "generate a Diffie-Hellman challenge" in
  Term.(const challenge $ parameters_arg),
  Term.info "dh-challenge" ~doc

let derive_cmd =
  let secret_arg =
    let doc = "Diffie-Hellman secret file" in
    Arg.(required & pos 1 (some file) None & info [] ~doc ~docv:"SECRET")
  in
  let doc = "derive a shared key in a Diffie-Hellman challenge" in
  Term.(const derive $ parameters_arg $ secret_arg),
  Term.info "dh-derive" ~doc

let private_set_arg t =
  let doc = "Diffie-Hellman private set file" in
  Arg.(required & opt (some t) None & info ~doc ["s"])

let request_cmd =
  let doc = "request Private Set Intersection" in
  Term.(const request $ parameters_arg $ private_set_arg Arg.string),
  Term.info "psi-request" ~doc

let reply_cmd =
  let doc = "reply to Private Set Intersection request" in
  Term.(const reply $ parameters_arg $ private_set_arg Arg.file),
  Term.info "psi-reply" ~doc

let intersect_cmd =
  let codes doc l = Arg.(required & opt (some file) None & info ~doc l) in
  let doc = "compute Private Set Intersection" in
  Term.(const inter $ parameters_arg
                    $ private_set_arg Arg.file
                    $ codes "codes sent by the other participant" ["o"; "other"]
                    $ codes "our codes that have returned" ["r"; "returned"]),
  Term.info "psi-intersect" ~doc

let encode_cmd =
  let doc = "encode the standard input's first line" in
  Term.(const encode $ const ()),
  Term.info "text-encode" ~doc

let decode_cmd =
  let doc = "decode the standard input" in
  Term.(const decode $ const ()),
  Term.info "text-decode" ~doc


let () =
  Random.self_init ();
  let toy =
    let doc = "a cryptographic toy" in
    Term.(ret @@ const @@ `Help (`Pager, None)),
    Term.info "toy-crypto" ~doc
  in
  Term.(exit @@ eval_choice toy [
    (* Text *)
    encode_cmd;
    decode_cmd;
    (* RSA *)
    generate_cmd;
    encrypt_cmd;
    decrypt_cmd;
    sign_cmd;
    verify_cmd;
    (* Diffie-Hellman *)
    parameters_cmd;
    challenge_cmd;
    derive_cmd;
    (* PSI *)
    request_cmd;
    reply_cmd;
    intersect_cmd;
  ])
