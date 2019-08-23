module Make (M: Numbers.S) = struct
  type parameters = {
    modulus: M.N.t;
    generator: M.N.t;
    bits: int
  } [@@deriving yojson]

  let generate ~bits =
    let modulus = M.random_prime ~bits in
    let generator = M.random ~bits in
    {modulus; generator; bits}

  let challenge {modulus; generator; bits} =
    let secret = M.random ~bits in
    secret, M.modpow generator secret ~m:modulus

  let derive {modulus; _} ~secret received_challenge =
    (* on both sides, (g ^ remote) ^ local = g ^ (remote * local) *)
    M.modpow received_challenge secret ~m:modulus
end
