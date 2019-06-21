module Symmetric_encryption (C: Model.Symmetric.Encryption.S) = struct
  open C

  (* preuve pour tous 'k 'c que decrypt défait encrypt *)
  let sym: 'k 'c. 'k key -> 'c -> 'c = fun key c ->
    let block = encrypt key c in
    decrypt key block

  let twice: 'k 'c. 'k key -> 'c -> 'c = fun key c ->
    (* avec Merlin, on exécute un programme en étendant la sélection ! *)
    encrypt key c |> encrypt key |> decrypt key |> decrypt key
end

module Symmetric_encryption'
  (* ça évite de créer plein de constructeurs dans la belle interface *)
  (C : Model.Symmetric.Encryption.S with type 'a key = 'a) =
struct
  open C

  (* pas possible d'exporter une valeur d'un type sorti d'un existentiel... *)
  type k1 = K1
  type k2 = K2

  let b = encrypt K1 42 |> encrypt K2
  let d1 = decrypt K2 b
  let d2 = decrypt K1 d1
end

module Symmetric_signature (C: Model.Symmetric.Signature.S) = struct
  open C

  let sign: 'c. 'c data -> bool = fun c ->
    let Gen key = generate () in
    sign key c = sign key c
end

module Asymmetric_encryption (C : Model.Asymmetric.Encryption.S) = struct
  open C

  let gen: 'c. 'c data -> 'c data = fun content ->
    let Gen (pub, sec) = generate () in
    encrypt pub content |> decrypt sec
end

module Asymmetric_signature (C : Model.Asymmetric.Signature.S) = struct
  open C

  let sign: 'c. 'c data -> bool = fun c ->
    let Gen (pub, sec) = generate () in
    sign sec c |> verify pub c
end

module Both_encryptions
  (S : Model.Symmetric.Encryption.S)
  (A : Model.Asymmetric.Encryption.S with type 'a data = 'a) =
struct
  let multi c =
    let S.Gen sym = S.generate () in
    let A.Gen (pub, sec) = A.generate () in
    S.encrypt sym c |> A.encrypt pub |> A.decrypt sec |> S.decrypt sym
end
