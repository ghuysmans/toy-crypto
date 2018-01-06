module Make :
  functor (M : Numbers.S) ->
    sig
      type parameters = {
        modulus: M.N.t;
        generator: M.N.t;
        bits: int
      } [@@deriving yojson]
      val generate : bits:int -> parameters
      val challenge : parameters -> M.N.t * M.N.t
      val derive : parameters -> secret:M.N.t -> M.N.t -> M.N.t
    end
