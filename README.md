# Toy Asymmetric Cryptography
This is a simple (and insecure) implementation of RSA and Diffie-Hellman.
Most algorithms are proven (in French) in a LaTeX document.

## Implementation
The `Numbers.Make` functor allows using any `Concrete` number representation:
- `Int` (31- or 63-bit OCaml integer, nice for testing purpose)
- `Bigint` (values are tagged, not directly saved as strings)

Phantom types allow statically differentiating `public` and `private` keys.

## Structure
- `numbers.ml`, `rsa.ml`, and `diffie_hellman.ml` contain the library
- `toy.ml` is a simple CLI tool
- `rsa.tex` contains proofs in French

## How to...

### Install through opam
```
opam pin add toy-crypto https://github.com/ghuysmans/toy-crypto.git
```

### Build from source (manually)
```
opam pin add -n .
opam install --deps-only toy-crypto
make
```

### Compute Private Set Intersection
```
$ dune exec -- bin/main.exe psi-request -s s1 dh.params >q1
poire
pomme
fraise
banane
cerise
^D
$ dune exec -- bin/main.exe psi-request -s s2 dh.params >q2
poire
banane
clémentine
^D
$ dune exec -- bin/main.exe psi-reply -s s2 dh.params <q1 >r2
$ dune exec -- bin/main.exe psi-intersect -s s1 dh.params --other q2 --returned r2
poire
banane
$ dune exec -- bin/main.exe psi-reply -s s1 dh.params <q2 >r1
$ dune exec -- bin/main.exe psi-intersect -s s2 dh.params --other q1 --returned r1
poire
banane
```
