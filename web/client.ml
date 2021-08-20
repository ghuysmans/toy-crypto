module N = Toy_crypto.Numbers.Make (struct
  include Big_int

  type u = [`Big_int of string] [@@deriving yojson]
  let to_yojson n =
    u_to_yojson (`Big_int (to_string n))
  let of_yojson j =
    match  u_of_yojson j with
    | (Result.Error _) as e -> e
    | Result.Ok (`Big_int s) ->
      try
        Result.Ok (of_string s)
      with Failure e ->
        Result.Error e
end)

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
