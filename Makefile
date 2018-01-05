all: toy.byte

OCAMLFLAGS=-use-ocamlfind -pkg num -pkg ppx_deriving_yojson -pkg cmdliner
clean:
	ocamlbuild -clean
%.byte: %.ml
	ocamlbuild $(OCAMLFLAGS) $@
%.native: %.ml
	ocamlbuild $(OCAMLFLAGS) $@
