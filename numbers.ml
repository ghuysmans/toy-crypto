module type S = sig
  type t
  val zero : t
  val one : t
  val pred : t -> t
  val succ : t -> t
  val (+) : t -> t -> t
  val (-) : t -> t -> t
  val ( * ) : t -> t -> t
  val (/) : t -> t -> t
  val (mod) : t -> t -> t
  val square : t -> t
  val (<=) : t -> t -> bool
  val (=) : t -> t -> bool
  val of_int : int -> t
  val to_int : t -> int
  val (lsl) : t -> int -> t
  val (lsr) : t -> int -> t
  val (land) : t -> t -> t
  val (lor) : t -> t -> t
  val of_string : string -> t
  val to_string : t -> string
end

module Int : S = struct
  type t = int
  let zero = 0
  let one = 1
  let pred = pred
  let succ = succ
  let (+) = (+)
  let (-) = (-)
  let ( * ) = ( * )
  let (/) = (/)
  let (mod) = (mod)
  let square n = n * n
  let (<=) = (<=)
  let (=) = (=)
  let of_int n = n
  let to_int n = n
  let (lsl) = (lsl)
  let (lsr) = (lsr)
  let (land) = (land)
  let (lor) = (lor)
  let of_string = int_of_string
  let to_string = string_of_int
end

module BigInt : S = struct
  open Big_int
  type t = big_int
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
  let of_string = big_int_of_string
  let to_string = string_of_big_int
end
