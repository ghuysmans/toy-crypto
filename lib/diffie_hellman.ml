module Make (M: Numbers.S) = struct
  type parameters = {
    modulus: M.N.t;
    generator: M.N.t;
    bits: int
  } [@@deriving yojson]

  let generate ~bits =
    let modulus = M.random_prime ~bits in
    let generator = M.random ~bits in
    {modulus; generator; bits}

  let challenge {modulus; generator; bits} =
    let secret = M.random ~bits in
    secret, M.modpow generator secret ~m:modulus

  let derive {modulus; _} ~secret received_challenge =
    (* on both sides, (g ^ remote) ^ local = g ^ (remote * local) *)
    M.modpow received_challenge secret ~m:modulus

  (* TODO upstream, see https://github.com/ocaml/ocaml/issues/5183 *)
  (* modern Fisher-Yates, REF??? *)
  let shuffle a =
    for i = Array.length a - 1 downto 1 do
      let j = Random.int (i + 1) in
      let tmp = a.(j) in
      a.(j) <- a.(i);
      a.(i) <- tmp
    done

  let split a =
    if Array.length a = 0 then
      [| |], [| |]
    else
      let snds = Array.(make (length a) (snd a.(0))) in
      Array.mapi (fun i (x, y) -> snds.(i) <- y; x) a, snds

  let hash ({bits; _} as p) plain =
    let secret = M.random ~bits in
    let a = Array.map (fun x -> x, Digest.string x |> M.of_string |> derive p ~secret) plain in
    shuffle a;
    secret, split a

  let reveal p ~secret a =
    Array.map (derive p ~secret) a |>
    Array.to_list

  (* FIXME move into Numbers? *)
  module S = Set.Make (struct
    type t = M.N.t
    let compare x y =
      let open M.N in
      if x = y then
        0
      else if x <= y then
        -1
      else
        1
  end)

  let intersection plain ~other back =
    let s = S.of_list other in
    List.combine (Array.to_list plain) back |>
    List.filter (fun (_, code) -> S.mem code s) |>
    List.map fst
end
