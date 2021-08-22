The pure OCaml library is __unbearably slow__ when running on Node.js,
and modern JavaScript implementations provide big integers (`BigInt`),
so let's give [https://github.com/ghuysmans/num-jsoo](num-jsoo) a try!
```
$ dune build benchmark/{native_zarith.exe,native_pure.exe,byte_pure.bc,node_pure.bc.js,node_jsoo.bc.js}
$ time dune exec benchmark/native_zarith_2.exe #nextprime, powm
real    0m0.195s
user    0m0.140s
sys     0m0.055s
$ time dune exec benchmark/native_zarith_2.exe #nextprime
real    0m0.219s
user    0m0.161s
sys     0m0.059s
$ time dune exec benchmark/native_zarith.exe
real    0m4.426s
user    0m4.364s
sys     0m0.062s
$ time dune exec benchmark/native_pure.bc
real    0m12.757s
user    0m12.688s
sys     0m0.060s
$ time dune exec benchmark/byte_pure.bc
real    0m15.273s
user    0m15.184s
sys     0m0.089s
$ time node _build/default/benchmark/node_pure.bc.js
real    5m37.117s
user    5m44.823s
sys     0m3.629s
$ time node _build/default/benchmark/node_jsoo.bc.js
real    0m31.418s
user    0m31.355s
sys     0m0.158s
```
