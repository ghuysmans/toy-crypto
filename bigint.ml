open Big_int
type t = big_int

type u = [`Big_int of string] [@@deriving yojson]
let to_yojson n =
  u_to_yojson (`Big_int (string_of_big_int n))
let of_yojson j =
  match  u_of_yojson j with
  | (Error _) as e -> e
  | Ok (`Big_int s) ->
    try
      Ok (big_int_of_string s)
    with Failure e ->
      Error e

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
