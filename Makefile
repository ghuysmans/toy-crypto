all: toy.byte

OCAMLFLAGS=-lib nums -use-ocamlfind -pkg ppx_deriving_yojson -pkg cmdliner
clean:
	ocamlbuild -clean
%.byte: %.ml
	ocamlbuild $(OCAMLFLAGS) $@
%.native: %.ml
	ocamlbuild $(OCAMLFLAGS) $@
