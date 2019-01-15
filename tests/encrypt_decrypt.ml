module M = Numbers.Make (Bigint)
module RSA = Rsa.Make (M)

let compare_before_after (pub, priv) s =
  let out =
    M.of_string s |>
    RSA.encrypt pub |>
    RSA.decrypt priv |>
    M.to_string
  in
  print_endline @@ "before: " ^ s;
  print_endline @@ "after: " ^ out;
  s = out

let load_pair pub priv =
  match
    RSA.import (Yojson.Safe.from_file pub),
    RSA.import (Yojson.Safe.from_file priv)
  with
  | Ok pub, Ok priv -> pub, priv
  | Error e, _ | _, Error e -> failwith e

let dump_pair (pub, priv) =
  Yojson.Safe.to_channel stdout (RSA.export pub);
  Yojson.Safe.to_channel stdout (RSA.export priv);
  print_endline ""

let generate bits =
  let pair = RSA.generate ~bits in
  dump_pair pair;
  pair


open Cmdliner

let bits =
  let doc = "key size (in bits)" in
  Arg.(required & pos 0 (some int) None & info [] ~doc ~docv:"BITS")

let generate_cmd =
  let doc = "generate an RSA keypair" in
  Term.(const generate $ bits),
  Term.info "generate" ~doc

let public_key =
  let doc = "public key file" in
  Arg.(required & pos 0 (some file) None & info [] ~doc ~docv:"PUBKEY")

let private_key =
  let doc = "private key file" in
  Arg.(required & pos 1 (some file) None & info [] ~doc ~docv:"SECKEY")

let load_cmd =
  let doc = "load existing keys" in
  Term.(const load_pair $ public_key $ private_key),
  Term.info "load" ~doc

let () =
  Random.self_init ();
  let test =
    let doc = "a toy tester" in
    Term.(ret @@ const @@ `Help (`Pager, None)),
    Term.info "encrypt_decrypt" ~doc
  in
  let r = Term.(eval_choice test [generate_cmd; load_cmd]) in
  (match r with
  | `Ok pair ->
    if compare_before_after pair (read_line ()) then
      print_endline "ok"
    else
      print_endline "fail"
  | _ ->
    ());
  Term.exit r
