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
        plain: string list;
      } [@@deriving yojson]
      type transmitted
      type returned
      type _ codes = M.N.t list [@@deriving yojson]
      val hash : parameters -> string list -> private_set * transmitted codes
      val reveal : parameters -> private_set -> transmitted codes -> returned codes
      val intersection : private_set -> other:returned codes -> returned codes -> string list
    end
