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

module Make : functor (Big_int : I) -> Numbers.Concrete with type t = Big_int.big_int
