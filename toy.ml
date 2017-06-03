module Crypto = Crypto.Make (Numbers.BigInt)

let () =
  Random.self_init ();
  let n_args = Array.length Sys.argv in
  let p = Sys.argv.(0) in
  let help ret =
    Printf.printf (
      "RSA:\n" ^^
      "%s generate bits\n" ^^
      "%s encrypt public.key\n" ^^
      "%s decrypt secret.key\n\n")
      p p p;
    (* TODO
    Printf.printf "%s sign secret.key\n" Sys.argv.(0);
    Printf.printf "%s check public.key signature\n" Sys.argv.(0);
    *)
    Printf.printf (
      "Diffie-Hellman:\n" ^^
      "%s parameters bits\n" ^^
      "%s challenge parameters.dat\n" ^^
      "%s derive1 parameters.dat\n" ^^
      "%s derive2 parameters.dat\n")
      p p p p;
    exit ret in
  if n_args = 1 then
    help 0
  else (
    let cmd = Sys.argv.(1) in
    if cmd = "help" then
      help 0
    else if cmd = "generate" && n_args = 3 then (
      let open Crypto.RSA in
      let bits = int_of_string Sys.argv.(2) in
      let public, secret = generate bits in
      print_endline "public key:";
      export_key public stdout;
      output_string stderr "secret key:";
      export_key secret stderr
    )
    else if (cmd = "encrypt" || cmd = "decrypt") && n_args = 3 then (
      let keyfile = open_in Sys.argv.(2) in
      let open Crypto.RSA in
      if cmd = "encrypt" then
        if input_line keyfile = "public key:" then
          let message = Crypto.of_string (read_line ()) in
          let public = import_key keyfile in
          Crypto.write (encrypt public message) stdout
        else
          failwith "expected a public key!"
      else
        if input_line keyfile = "secret key:" then
          let cipher = Crypto.read stdin in
          let secret = import_key keyfile in
          print_string (Crypto.to_string (decrypt secret cipher))
        else
          failwith "expected a secret key!"
    )
    else (
      let open Crypto.DH in
      if (cmd = "challenge" || cmd = "derive1" || cmd = "derive2") &&
          n_args = 3 then (
        let parameters =
          let chan = open_in Sys.argv.(2) in
          match import_parameters chan with
            | Some p -> p
            | None -> failwith "not DH parameters!" in
        let do_derive secret =
          if read_line () = "challenge:" then
            let received = Crypto.read stdin in
            let shared = derive parameters secret received in
            output_string stderr "shared:\n";
            Crypto.write shared stderr;
            shared
          else
            failwith "expected a challenge!" in
        let do_challenge () =
          let secret, challenge = challenge parameters in
          output_string stderr "secret:\n";
          Crypto.write secret stderr;
          print_endline "challenge:";
          Crypto.write challenge stdout;
          secret in
        if cmd = "challenge" then
          ignore (do_challenge ())
        else if cmd = "derive1" then (
          let secret = do_challenge () in
          ignore (do_derive secret)
        )
        else if read_line () = "secret:" then
          let secret = Crypto.read stdin in
          ignore (do_derive secret)
        else
          failwith "expected a secret key!"
      )
      else if cmd = "parameters" && n_args = 3 then
        let parameters = generate (int_of_string Sys.argv.(2)) in
        export_parameters parameters stdout
      else
        help 1
    )
  )
