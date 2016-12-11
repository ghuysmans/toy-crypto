module type Num = sig
    type t
    val zero : t
    val one : t
    val pred : t -> t
    val succ : t -> t
    val (+) : t -> t -> t
    val (-) : t -> t -> t
    val ( * ) : t -> t -> t
    val (/) : t -> t -> t
    val (mod) : t -> t -> t
    val square : t -> t
    val (<=) : t -> t -> bool
    val (=) : t -> t -> bool
    val of_int : int -> t
    val to_int : t -> int
    val (lsl) : t -> int -> t
    val (lsr) : t -> int -> t
    val (land) : t -> t -> t
    val (lor) : t -> t -> t
    val of_string : string -> t
    val to_string : t -> string
end

module Int : Num = struct
    type t = int
    let zero = 0
    let one = 1
    let pred = pred
    let succ = succ
    let (+) = (+)
    let (-) = (-)
    let ( * ) = ( * )
    let (/) = (/)
    let (mod) = (mod)
    let square n = n * n
    let (<=) = (<=)
    let (=) = (=)
    let of_int n = n
    let to_int n = n
    let (lsl) = (lsl)
    let (lsr) = (lsr)
    let (land) = (land)
    let (lor) = (lor)
    let of_string = int_of_string
    let to_string = string_of_int
end

module BigInt : Num = struct
    open Big_int
    type t = big_int
    let zero = zero_big_int
    let one = unit_big_int
    let pred = pred_big_int
    let succ = succ_big_int
    let (+) = add_big_int
    let (-) = sub_big_int
    let ( * ) = mult_big_int
    let (/) = div_big_int
    let (mod) = mod_big_int
    let square = square_big_int
    let (<=) = le_big_int
    let (=) = eq_big_int
    let of_int = big_int_of_int
    let to_int = int_of_big_int
    let (lsl) = shift_left_big_int
    let (lsr) = shift_right_big_int
    let (land) = and_big_int
    let (lor) = or_big_int
    let of_string = big_int_of_string
    let to_string = string_of_big_int
end

module Crypto (N : Num) = struct
    let even n = N.(n land one = zero)
    let half n = N.(n lsr 1)
    let oddify n = N.(n lor one)
    let modpow a b n =
        let open N in
        let rec f a b r =
            if b = zero then
                (* a^0 * r = 1 * r = r *)
                r
            else if even b then
                (* a^(2k) = (a^2)^k *)
                f ((square a) mod n) (half b) r
            else
                (* a^(2k+1) = a * a^(2k) = a * (a^2)^c *)
                f ((square a) mod n) (half b) (r * a mod n) in
        if b < zero then
            failwith "negative exponent"
        else
            f (a mod n) b one
    let fermat_test n =
        let rejected n =
            let open N in
            let a = of_int (Random.bits ()) mod (n - one) + one in
            not (modpow a (pred n) n = one) in
        let rec f i =
            if i = 0 then
                true
            else
                if rejected n then
                    false
                else
                    f (i - 1) in
        f 200
    let euclid a b = (* taken from Wikipedia *)
        let open N in
        let rec f r u v r' u' v' =
            if r' = zero then
                r (* gcd *), u, v
            else
                let q = r / r' in
                f r' u' v' (r - q * r') (u - q * u') (v - q * v') in
        f a one zero b zero one
    let gcd a b =
        let r, _, _ = euclid a b in
        r
    let inv x n =
        let open N in
        let r, x', _ = euclid x n in
        if r = one then
            if x' < zero then x' + n else x'
        else
            (* this should not happen *)
            failwith "non-invertible value"
    let random n_bits =
        let step = 30 in
        let rec f blocks a =
            if blocks = 0 then
                a
            else
                let a =
                    let open N in
                    let small = Random.bits () in
                    let shifted = a lsl step in
                    shifted + (of_int small) in
                f (blocks - 1) a in
        if n_bits mod step = 0 then
            f (n_bits / step) N.zero
        else
            f (n_bits / step + 1) N.zero
    let rec generate_prime n_bits =
        let n = oddify (random n_bits) in
        if fermat_test n then
            n
        else
            generate_prime n_bits (* retry *)
    let read chan =
        N.of_string (input_line chan)
    let write n chan =
        output_string chan (N.to_string n);
        output_char chan '\n'
    let to_string n =
        let open N in
        let rec f n a =
            if n = zero then
                a
            else
                let lsb = char_of_int (to_int (n land of_int 255)) in
                f (n lsr 8) (String.make 1 lsb ^ a) in
        f n ""
    let of_string s =
        let l = String.length s in
        let rec f i a =
            if i = l then
                a
            else
                let a =
                    let open N in
                    let c = of_int (int_of_char (String.get s i)) in
                    a lsl 8 + c in
                f (i + 1) a in
        f 0 N.zero
    module RSA : sig
        type 'a key
        type secret
        type public
        val derive : N.t -> N.t -> public key * secret key
        val generate : int -> public key * secret key
        val encrypt : public key -> N.t -> N.t
        val decrypt : secret key -> N.t -> N.t
        val sign : secret key -> N.t -> N.t
        val check : public key * N.t -> N.t -> bool
        val import_key : in_channel -> 'a key
        val export_key : 'a key -> out_channel -> unit
    end = struct
        type 'a key = {modulus: N.t; exponent: N.t}
        type secret
        type public
        let derive p q =
            let open N in
            let phi = (p - one) * (q - one) in
            let e =
                let two = of_int 2 in
                let valid n = gcd n phi = one in
                let rec f n =
                    if valid n then
                        n
                    else
                        (* 2 is even, phi too: skip all even numbers *)
                        f (n + two) in
                f (of_int 3) in
            let d = inv e phi in
            let modulus = N.(p * q) in
            {modulus; exponent = e}, {modulus; exponent = d}
        let rsa {modulus; exponent} input = modpow input exponent modulus
        let import_key chan =
            let modulus = read chan in
            let exponent = read chan in
            {modulus; exponent}
        let export_key {modulus; exponent} chan =
            write modulus chan;
            write exponent chan
        (* convenience functions *)
        let generate n_bits =
            let p = generate_prime n_bits in
            let q = generate_prime n_bits in
            derive p q
        let encrypt = rsa
        let decrypt = rsa
        let sign = rsa
        let check (public, signature) input =
            N.(rsa public signature = input)
    end
    module DH = struct
        type parameters = {modulus: N.t; generator: N.t; n_bits: int}
        let generate n_bits =
            let modulus = generate_prime n_bits in
            let generator = random n_bits in
            {modulus; generator; n_bits}
        let challenge {modulus; generator; n_bits} =
            let secret = random n_bits in
            secret, modpow generator secret modulus
        let derive {modulus; _} secret received_challenge =
            (* on both sides, (g ^ remote) ^ local = g ^ (remote * local) *)
            modpow received_challenge secret modulus
        let import_parameters chan =
            if input_line chan = "parameters:" then
                let modulus = read chan in
                let generator = read chan in
                let n_bits = int_of_string (input_line chan) in
                Some {modulus; generator; n_bits}
            else
                None
        let export_parameters {modulus; generator; n_bits} chan =
            output_string chan "parameters:\n";
            write modulus chan;
            write generator chan;
            output_string chan (string_of_int n_bits);
            output_char chan '\n'
    end
end

let () =
    let module Crypto = Crypto (BigInt) in
    let open Crypto.RSA in
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
        if cmd = "generate" && n_args = 3 then (
            Random.self_init ();
            let bits = int_of_string Sys.argv.(2) in
            let public, secret = generate bits in
            print_endline "public key:";
            export_key public stdout;
            print_endline "secret key:";
            export_key secret stdout
        )
        else if (cmd = "encrypt" || cmd = "decrypt") && n_args = 3 then (
            let keyfile = open_in Sys.argv.(2) in
            if cmd = "encrypt" then
                if input_line keyfile = "public key:" then
                    let message = Crypto.of_string (read_line ()) in
                    let public = import_key keyfile in
                    Crypto.write (encrypt public message) stdout
                else
                    failwith "not a public key!"
            else
                if input_line keyfile = "secret key:" then
                    let cipher = Crypto.read stdin in
                    let secret = import_key keyfile in
                    print_string (Crypto.to_string (decrypt secret cipher))
                else
                    failwith "not a secret key!"
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
