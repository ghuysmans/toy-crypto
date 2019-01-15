module Make (M: Numbers.S) = struct
  open M.N

  type ('a, 'b) key = {modulus: t; exponent: t} [@@deriving yojson]
  type secret
  type public
  type exportable
  type non_exportable

  let derive p q =
    let phi = (p - one) * (q - one) in
    let e =
      let two = of_int 2 in
      let valid n = M.gcd n phi = one in
      let rec f n =
        if valid n then
          n
        else
          (* 2 is even, phi too: skip all even numbers *)
          f (n + two)
      in
      f (of_int 3)
    in
    let d = M.inv e ~m:phi in
    let modulus = p * q in
    {modulus; exponent = e}, {modulus; exponent = d}

  let rsa {modulus; exponent} input =
    M.modpow input exponent modulus

  let generate ~bits =
    let p = M.random_prime ~bits in
    let q = M.random_prime ~bits in
    derive p q

  let encrypt = rsa
  let decrypt = rsa
  let sign = rsa

  let check public ~signature input =
    rsa public signature = input

  let secure = ignore

  exception Not_so_phantom_type

  let diverge _ =
    (* typing trick: phantom types don't need converters (hence _) since there
       aren't any associated data (by definition)... The type is universally
       quantified, though, so I guess this is an explicit way to produce 'a. *)
    raise Not_so_phantom_type

  let export k =
    key_to_yojson diverge diverge k

  let import j =
    key_of_yojson diverge diverge j
end
