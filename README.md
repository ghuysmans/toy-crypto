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
