# Toy Asymmetric Cryptography
This is a simple (and insecure) implementation of RSA and Diffie-Hellman.
Most algorithms are proven (in French) in a LaTeX document.

## Implementation
A functor allows using different number representations:
- `int`
- `Big_int`

Phantom types allow statically differentiating public and private keys.

## Structure
- `crypto.ml` contains the library
- `toy.ml` is a simple CLI tool
- `rsa.tex` contains proofs in French

## How to build
```
ocamlbuild -lib nums toy.byte
```
