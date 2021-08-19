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
        type ('a, _) codes [@@deriving yojson]
        val request : parameters -> string list -> t * (M.N.t, transmitted) codes
        val reply : parameters -> t -> (M.N.t, transmitted) codes -> (M.N.t, returned) codes
        val map : ('a -> 'b) -> ('a, 'c) codes -> ('b, 'c) codes
        val compare : M.N.t -> M.N.t -> int
        type str = string [@@deriving yojson]
        val hash : M.N.t -> string
        val intersection : t -> compare:('a -> 'a -> int) -> other:('a, returned) codes -> ('a, returned) codes -> string list
      end
    end
