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
  | Error e -> prerr_endline e; exit 1
  | Ok n -> n

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
  | Error e -> prerr_endline e; exit 2
  | Ok key -> key

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
  | Error e -> prerr_endline e; exit 2
  | Ok p -> p

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
  Arg.(required & pos 0 (some file) None & info [] ~doc ~docv:"PARAMS")

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
  ])
