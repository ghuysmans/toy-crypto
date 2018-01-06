all: toy.byte

OCAMLFLAGS=-use-ocamlfind -pkg num -pkg ppx_deriving_yojson -pkg cmdliner
clean:
	ocamlbuild -clean
%.byte:
	ocamlbuild $(OCAMLFLAGS) $@
%.native:
	ocamlbuild $(OCAMLFLAGS) $@
%.cma:
	ocamlbuild $(OCAMLFLAGS) $@
%.cmxa:
	ocamlbuild $(OCAMLFLAGS) $@
