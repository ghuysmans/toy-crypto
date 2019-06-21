all:
	dune build
top:
	dune utop lib
clean:
	dune clean
doc:
	dune build @doc-private
