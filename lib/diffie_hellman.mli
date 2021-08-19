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

      module PSI : sig
        type t = {
          secret: M.N.t;
          plain: string list;
        } [@@deriving yojson]
        type transmitted
        type returned
        type _ codes [@@deriving yojson]
        val request : parameters -> string list -> t * transmitted codes
        val reply : parameters -> t -> transmitted codes -> returned codes
        val intersection : t -> other:returned codes -> returned codes -> string list
      end
    end
