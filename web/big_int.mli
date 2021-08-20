type t
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
val of_string : string -> t
val to_string : t -> string
