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
  type e = {r: N.t; u: N.t; v: N.t}
  val euclid: N.t -> N.t -> e
  val gcd: N.t -> N.t -> N.t
  val inv: N.t -> m:N.t -> N.t
  val crt: N.t * N.t -> N.t * N.t -> N.t
  val random: bits:int -> N.t
  val random_prime: bits:int -> N.t
  val of_string : string -> N.t
  val to_string : N.t -> string
end

module Make (N: Concrete) = struct
  module N = struct
    include N
    let (<) a b = N.(not (a = b) && a <= b)
  end


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
      not (modpow a (pred n) ~m:n = one)
    in
    let rec f = function
      | 0 -> true
      | _ when rejected () -> false
      | i -> f (i - 1)
    in
    f 200

  type e = {r: N.t; u: N.t; v: N.t}

  let euclid a b = (* taken from Wikipedia *)
    let open N in
    let rec f r u v r' u' v' =
      if r' = zero then
        {r; u; v}
      else
        let q = r / r' in
        f r' u' v' (r - q * r') (u - q * u') (v - q * v')
    in
    f a one zero b zero one

  let gcd a b =
    let {r; _} = euclid a b in
    r

  let inv x ~m =
    let open N in
    let {r; u = x'; _} = euclid x m in
    if r = one then
      if x' < zero then x' + m else x'
    else
      (* this should not happen *)
      failwith "non-invertible value"

  let crt (a, p) (b, q) =
    let open N in
    let p1, q1 = inv p ~m:q, inv q ~m:p in
    let n = (a * q1 * q + b * p1 * p) mod (p * q) in
    if n < zero then n + p * q else n

  let random ~bits =
    let rec f a = function
      | 0 -> a
      | n when n < 30 ->
        let useless = 30 - n in
        let small = N.(of_int (Random.bits ()) lsr useless) in
        N.((a lsl n) lor small)
      | n ->
        (* use all 30 bits *)
        let a = N.((a lsl 30) lor (of_int (Random.bits ()))) in
        f a (n - 30)
    in
    f N.zero bits

  let rec random_prime ~bits =
    assert (bits > 1);
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
