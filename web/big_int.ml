open Js_of_ocaml
type t = < toString : Js.js_string Js.t Js.meth > Js.t
let of_int : int -> t = Js.Unsafe.global##._BigInt
let to_int = Js.Unsafe.global##._Number
let zero = of_int 0
let one = of_int 1
let (+) : t -> t -> t = Js.Unsafe.js_expr "function(a,b){return a+b}"
let (-) : t -> t -> t = Js.Unsafe.js_expr "function(a,b){return a-b}"
let ( * ) : t -> t -> t = Js.Unsafe.js_expr "function(a,b){return a*b}"
let succ x = x + one
let pred x = x - one
let square x = x * x
let (<=) = Js.Unsafe.js_expr "function(a,b){return +(a<=b)}"
let (=) : t -> t -> bool = Js.Unsafe.js_expr "function(a,b){return +(a==b)}"
let (/) : t -> t -> t = Js.Unsafe.js_expr "function(a,b){return a/b}"
let (/) a b = if b = zero then raise Division_by_zero; a / b
let (mod) : t -> t -> t = Js.Unsafe.js_expr "function(a,b){return a%b}"
let (mod) a b = if b = zero then raise Division_by_zero; a mod b
let (lsl) = Js.Unsafe.js_expr "function(a,b){return a<<BigInt(b)}"
let (lsr) = Js.Unsafe.js_expr "function(a,b){return a>>BigInt(b)}"
let (land) = Js.Unsafe.js_expr "function(a,b){return a&b}"
let (lor) = Js.Unsafe.js_expr "function(a,b){return a|b}"
let of_js_string : Js.js_string Js.t -> t = Js.Unsafe.global##._BigInt
let of_string s = of_js_string (Js.string s)
let to_string x = Js.to_string x##toString
