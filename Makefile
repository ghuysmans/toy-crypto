all: a-shared.dh

OCAMLFLAGS=-lib nums -use-ocamlfind -pkg ppx_deriving_yojson -pkg cmdliner
clean:
	rm a-to-b.dh b-to-a.dh a-shared.dh a-secret.dh
%.byte: %.ml
	ocamlbuild $(OCAMLFLAGS) $@
%.native: %.ml
	ocamlbuild $(OCAMLFLAGS) $@

TOOL=toy.byte
params.dh: $(TOOL)
	./$(TOOL) parameters 128 >$@
a-to-b.dh: params.dh
	./$(TOOL) challenge $< >$@ 2>a-secret.dh
b-to-a.dh: a-to-b.dh
	./$(TOOL) derive1 params.dh <$< >$@
a-shared.dh: b-to-a.dh
	cat a-secret.dh $< |./$(TOOL) derive2 params.dh 3>&2 |tee $@
