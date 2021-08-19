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

  let shuffle_list l =
    let a = Array.of_list l in
    shuffle a;
    Array.to_list a

  (* TODO write about Private Set Intersection *)
  module PSI = struct
    type t = {
      secret: M.N.t;
      plain: string list;
    } [@@deriving yojson]

    type transmitted
    type returned
    type ('a, _) codes = 'a list [@@deriving yojson]

    let request ({bits; _} as p) plain =
      let secret = M.random ~bits in
      let plain, codes =
        shuffle_list plain |>
        List.map (fun x -> x, Digest.string x |> M.of_string |> derive p ~secret) |>
        List.split
      in
      {secret; plain}, codes

    let reply p {secret; _} a =
      List.map (derive p ~secret) a

    let map = List.map

    (* FIXME move into Numbers? *)
    let compare x y =
      let open M.N in
      if x = y then
        0
      else if x <= y then
        -1
      else
        1

    type str = string [@@deriving yojson]

    let hash x =
      M.to_string x |> Digest.string |> Digest.to_hex

    let intersection (type t) {plain; _} ~compare ~other back =
      let module S = Set.Make (struct
        type nonrec t = t
        let compare = compare
      end) in
      let s = S.of_list other in
      List.combine plain back |>
      List.filter (fun (_, code) -> S.mem code s) |>
      List.map fst
  end
end
