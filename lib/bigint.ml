module type I = sig
  type big_int
  val zero_big_int : big_int
  val unit_big_int : big_int
  val add_big_int : big_int -> big_int -> big_int
  val succ_big_int : big_int -> big_int
  val sub_big_int : big_int -> big_int -> big_int
  val pred_big_int : big_int -> big_int
  val mult_big_int : big_int -> big_int -> big_int
  val square_big_int: big_int -> big_int
  val div_big_int : big_int -> big_int -> big_int
  val mod_big_int : big_int -> big_int -> big_int
  (* val compare_big_int : big_int -> big_int -> int *)
  val eq_big_int : big_int -> big_int -> bool
  val le_big_int : big_int -> big_int -> bool
  val string_of_big_int : big_int -> string
  val big_int_of_string : string -> big_int
  val big_int_of_int : int -> big_int
  val int_of_big_int : big_int -> int
  val and_big_int : big_int -> big_int -> big_int
  val or_big_int : big_int -> big_int -> big_int
  val shift_left_big_int : big_int -> int -> big_int
  val shift_right_big_int : big_int -> int -> big_int
end

module Make (Big_int : I) = struct
  open Big_int
  type t = big_int

  type u = [`Big_int of string] [@@deriving yojson]
  let to_yojson n =
    u_to_yojson (`Big_int (string_of_big_int n))
  let of_yojson j =
    match  u_of_yojson j with
    | (Result.Error _) as e -> e
    | Result.Ok (`Big_int s) ->
      try
        Result.Ok (big_int_of_string s)
      with Failure e ->
        Result.Error e

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
end
