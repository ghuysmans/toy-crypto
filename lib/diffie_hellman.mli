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
      type private_set = {
        secret: M.N.t;
        plain: string array;
      } [@@deriving yojson]
      val hash : parameters -> string array -> private_set * M.N.t array
      val reveal : parameters -> private_set -> M.N.t array -> M.N.t list
      val intersection : private_set -> other:M.N.t list -> M.N.t list -> string list
    end
