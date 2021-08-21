module N = Toy_crypto.Numbers.Make (Toy_crypto.Bigint.Make (Big_int))
module Rsa = Toy_crypto.Rsa.Make (N)

let () =
  let pub, pri = Rsa.generate ~bits:1024 in
  print_endline "generated";
  let plain = N.of_string "hello world" in
  let signature = Rsa.sign pri plain in
  if Rsa.check pub ~signature plain then
    print_endline "ok"
  else
    print_endline "bad"
