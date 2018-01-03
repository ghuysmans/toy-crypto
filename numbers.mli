module type Concrete = sig
  type t [@@deriving yojson]
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
end

module type S = sig
  module N : Concrete
  val modpow: N.t -> N.t -> m:N.t -> N.t
  val fermat: N.t -> bool
  val euclid: N.t -> N.t -> N.t * N.t * N.t
  val gcd: N.t -> N.t -> N.t
  val inv: N.t -> m:N.t -> N.t
  val random: bits:int -> N.t
  val random_prime: bits:int -> N.t
  val of_string : string -> N.t
  val to_string : N.t -> string
end

module Make: functor (N: Concrete) -> S with module N = N
