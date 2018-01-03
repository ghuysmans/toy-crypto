module Make (M: Numbers.S) = struct
  open M.N

  type 'a key = {modulus: t; exponent: t} [@@deriving yojson]
  type secret
  type public

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
end
