OCAMLFLAGS=-use-ocamlfind -pkg num -pkg ppx_deriving_yojson -pkg cmdliner \
			-plugin-tag "package(js_of_ocaml.ocamlbuild)"
all:
	ocamlbuild $(OCAMLFLAGS) toy.native toy_crypto.cma toy_crypto.cmxa
top:
	ocamlbuild $(OCAMLFLAGS) int.byte rsa.byte diffie_hellman.byte
	ocaml

clean:
	ocamlbuild -clean
