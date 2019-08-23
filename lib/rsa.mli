module Make: functor (M: Numbers.S) -> sig
  type ('a, 'b) key

  type secret
  type public
  val derive: M.N.t -> M.N.t -> (public, _) key * (secret, _) key
  val generate: bits:int -> (public, _)  key * (secret, _) key
  val encrypt: (public, _) key -> M.N.t -> M.N.t
  val decrypt: (secret, _) key -> M.N.t -> M.N.t
  val sign: (secret, _) key -> M.N.t -> M.N.t
  val check: (public, _) key -> signature:M.N.t -> M.N.t -> bool

  type exportable
  type non_exportable
  val secure: (_, non_exportable) key -> unit
  val export: (_, exportable) key -> Yojson.Safe.t
  val import: Yojson.Safe.t -> (_,_) key Ppx_deriving_yojson_runtime.error_or
end
