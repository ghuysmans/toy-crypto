module Make: functor (M: Numbers.S) -> sig
  type 'a key
  type secret
  type public
  val derive : M.N.t -> M.N.t -> public key * secret key
  val generate : bits:int -> public key * secret key
  val encrypt : public key -> M.N.t -> M.N.t
  val decrypt : secret key -> M.N.t -> M.N.t
  val sign : secret key -> M.N.t -> M.N.t
  val check : public key -> signature:M.N.t -> M.N.t -> bool
end
