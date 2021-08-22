open Toy_crypto

module N = Numbers.Make (struct
  include Z
  let (lsr) = Z.(asr)
  let (=) = Z.equal
  let (<=) = Z.leq
  let square x = x * x
  let of_yojson _ = failwith "TODO"
  let to_yojson _ = failwith "TODO"
end)

module DH = Diffie_hellman.Make (struct
  include N
  let random_prime ~bits = random ~bits |> Z.nextprime
  let modpow a b ~m = Z.powm a b m
end)

let () =
  let params = DH.generate ~bits:1024 in
  let s1, m1 = DH.challenge params in
  let s2, m2 = DH.challenge params in
  let sh = DH.derive params ~secret:s1 m2 in
  let sh' = DH.derive params ~secret:s2 m1 in
  assert N.N.(sh = sh');
  assert N.N.(not (s1 = s2))
