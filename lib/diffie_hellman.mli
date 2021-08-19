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

      (* FIXME write about this *)
      val hash : parameters -> string array -> M.N.t * (string array * M.N.t array)
      val reveal : parameters -> secret:M.N.t -> M.N.t array -> M.N.t list
      val intersection : string array -> other:M.N.t list -> M.N.t list -> string list
    end
