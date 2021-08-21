open Toy_crypto

let run (module B : Bigint.I) =
  let module N = Bigint.Make (B) in
  let module M = Numbers.Make (N) in
  let module DH = Diffie_hellman.Make (M) in
  let params = DH.generate ~bits:1024 in
  let s1, m1 = DH.challenge params in
  let s2, m2 = DH.challenge params in
  let sh = DH.derive params ~secret:s1 m2 in
  let sh' = DH.derive params ~secret:s2 m1 in
  assert N.(sh = sh');
  assert N.(not (s1 = s2))
