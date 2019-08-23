open Toy_crypto
module M = Numbers.Make (Int) (* FIXME *)

open Printf


let () =
  let int_arg n = int_of_string Sys.argv.(n) in
  if Array.length Sys.argv = 5 then
    let a, p, b, q = int_arg 1, int_arg 2, int_arg 3, int_arg 4 in
    printf "Input problem:\n\tx = %d mod %d\n\tx = %d mod %d\n" a p b q;
    try
      let n = M.crt (a, p) (b, q) in
      printf "Solution:\n\tx = %d mod %d\n" n (p * q)
    with Failure _ ->
      printf "No solution:\n\t%d and %d aren't coprime.\n" p q
  else
    let p, q = int_arg 1, int_arg 2 in
    printf "(a, b) represents this:\n\tx = a mod %d\n\tx = b mod %d\n" p q;
    for a=0 to p-1 do
      for b=0 to q-1 do
        let n = M.crt (a, p) (b, q) in
        printf "(%d, %d) -> %d\n" a b n
      done
    done
