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

module Make (N: Concrete) = struct
  module N = N

  let even n = N.(n land one = zero)
  let half n = N.(n lsr 1)
  let oddify n = N.(n lor one)

  let modpow a b ~m =
    let open N in
    let rec f a b r =
      if b = zero then
        (* a^0 * r = 1 * r = r *)
        r
      else if even b then
        (* a^(2k) = (a^2)^k *)
        f ((square a) mod m) (half b) r
      else
        (* a^(2k+1) = a * a^(2k) = a * (a^2)^c *)
        f ((square a) mod m) (half b) (r * a mod m)
    in
    if b < zero then
      failwith "negative exponent"
    else
      f (a mod m) b one

  let fermat n =
    let rejected () =
      let open N in
      let a = of_int (Random.bits ()) mod (n - one) + one in
      not (modpow a (pred n) n= one)
    in
    let rec f = function
      | 0 -> true
      | i when rejected () -> false
      | i -> f (i - 1)
    in
    f 200

  let euclid a b = (* taken from Wikipedia *)
    let open N in
    let rec f r u v r' u' v' =
      if r' = zero then
        r (* gcd *), u, v
      else
        let q = r / r' in
        f r' u' v' (r - q * r') (u - q * u') (v - q * v')
    in
    f a one zero b zero one

  let gcd a b =
    let r, _, _ = euclid a b in
    r

  let inv x ~m =
    let open N in
    let r, x', _ = euclid x m in
    if r = one then
      if x' < zero then x' + m else x'
    else
      (* this should not happen *)
      failwith "non-invertible value"

  let random ~bits =
    let step = 30 in
    let rec f blocks a =
      if blocks = 0 then
        a
      else
        let a =
          let open N in
          let small = Random.bits () in
          let shifted = a lsl step in
          shifted + (of_int small)
        in
        f (blocks - 1) a
    in
    if bits mod step = 0 then
      f (bits / step) N.zero
    else
      f (bits / step + 1) N.zero

  let rec random_prime ~bits =
    let n = oddify (random ~bits) in
    if fermat n then
      n
    else
      random_prime ~bits (* retry *)

  let to_string n =
    let open N in
    let rec f n a =
      if n = zero then
        a
      else
        let lsb = char_of_int (to_int (n land of_int 255)) in
        f (n lsr 8) (String.make 1 lsb ^ a)
    in
    f n ""

  let of_string s =
    let l = String.length s in
    let rec f i a =
      if i = l then
        a
      else
        let a =
          let open N in
          let c = of_int (int_of_char (String.get s i)) in
          a lsl 8 + c
        in
        f (i + 1) a
    in
    f 0 N.zero
end
