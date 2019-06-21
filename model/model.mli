module Symmetric : sig
  module Encryption : sig
    module type S = sig
      type 'k key
      (* Une astuce pour créer un nouveau type à chaque fois \o/ *)
      (* FIXME voir pq ça marche pas globalement, 'k ne devient pas 'a * 'b *)
      type gen = Gen: 'k key -> gen
      val generate: unit -> gen

      type ('content, 'k) e
      val encrypt: 'k key -> 'content -> ('content, 'k) e
      val decrypt: 'k key -> ('content, 'k) e -> 'content
    end

    (* FIXME "même" data que AsymEnc avec data pour contraindre l'entrée *)
    module RC4 : S
    module AES : S
  end

  module Hash : sig
    module type S = sig
      type 'content h
      val hash: 'content -> 'content h
    end

    type 'a hash_128
    module MD4 : S with type 'a h = 'a hash_128
    (*
    FIXME comment exprimer qu'en un sens (SEULEMENT) c'est la même chose ?
    définir des fonctions de passage ??
    *)
    module MD5 : S
    module SHA1 : S
    module SHA256 : S
  end

  module Signature : sig
    module type S = sig
      type 'k secret
      type gen = Gen: 'k secret -> gen
      val generate: unit -> gen

      type 'd data
      type ('d, 'k) s
      val sign: 'k secret -> 'd data -> ('d, 'k) s
      val verify: 'k secret -> 'd data -> ('d, 'k) s -> bool
    end

    module MD5 : S
    module SHA1 : S
  end
end

module Number : sig
  module type S = sig
    type 'a t
  end
end

module Asymmetric : sig
  module Encryption : sig
    module type S = sig
      type 'k public
      type 'k secret
      type gen = Gen: 'k public * 'k secret -> gen
      val generate: unit -> gen

      type 'd data
      type ('d, 'k) e
      (*
      [À la base j'utilisais un type block commun aux différents algos...]
      On ne peut pas tester la différence du coup on exige un truc bien emballé.
      On pouvait aussi exiger 'p key... dans les constructeurs de gen.
      *)
      val encrypt: 'k public -> 'd data -> ('d, 'k) e
      val decrypt: 'k secret -> ('d, 'k) e -> 'd data
    end

    (* FIXME comprendre s'il faut exposer les égalités *)
    module RSA : functor
      (N : Number.S)
      (SE : Symmetric.Encryption.S) ->
      S with type 'd data = 'd N.t
        (* FIXME faire rentrer un existentiel ??
        and type ('d, 'k) e = Enc: 'eph SE.key -> ('d, 'k) e
        *)
  end

  module Signature : sig
    module type S = sig
      type 'k public
      type 'k secret
      type gen = Gen: 'k public * 'k secret -> gen
      val generate: unit -> gen

      type 'd data
      type ('d, 'k) s
      val sign: 'k secret -> 'd data -> ('d, 'k) s
      (*
      Si les types sont tous différents, bool est inutile,
      la cohérence des types à elle seule prouve que la signature est valide.
      *)
      val verify: 'k public -> 'd data -> ('d, 'k) s -> bool
    end

    module RSA : functor
      (N : Number.S)
      (H : Symmetric.Hash.S (* with type 'a h = 'a N.t *)) ->
      S (* with type 'd data = 'd N.t *)
  end
end
