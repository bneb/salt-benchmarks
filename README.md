# Salt Benchmarks

Salt, C, and Rust implementations of algorithm problems and micro-benchmarks.
Each problem has all three languages where possible for apples-to-apples comparison.

## Running

```bash
make bench          # compile + time C and Rust, verify Salt contracts
make check          # fast: verify only Salt contracts (no compilation needed)
```

`make bench` needs `clang` and `rustc`. `make check` only needs `saltc`.
The Salt column shows contract verification status — native Salt timing requires
LLVM 21 and the full `saltc --binary` pipeline (not yet available in the
standalone `make bench` flow).

## Results

Apple M4 Pro, clang -O3, rustc -O. Median of 5 runs after 2 warmup.

| Problem | C | Rust | Salt | Notes |
|---------|---|---|------|-------|
| [fib](problems/fib/) | 0.16s | 0.17s | ✓ | Recursive fib(40) |
| [sieve](problems/sieve/) | 0.13s | 0.13s | ✓ | 10M primes |
| [binary-trees](problems/binary-trees/) | — | — | ✓ | C/Rust need arena header |
| [lru-cache](problems/lru-cache/) | 0.01s | 0.01s | ✓ | LC 146 |
| [sudoku-solver](problems/sudoku-solver/) | 0.01s | 0.01s | ✓ | LC 37 |
| [merge-sorted-lists](problems/merge-sorted-lists/) | 0.01s | 0.01s | ✓ | LC 23 |
| [trapping-rain-water](problems/trapping-rain-water/) | 0.06s | 0.06s | ✓ | LC 42 |
| [longest-consecutive](problems/longest-consecutive/) | 0.76s | 0.30s | ✓ | LC 128, Rust 2.5x faster |
| [trie](problems/trie/) | 0.02s | 0.02s | ✓ | LC 208 |
| [matmul](problems/matmul/) | — | 0.13s | ✓ | C needs header, Rust 512×512 |
| [fannkuch](problems/fannkuch/) | 0.13s | 0.13s | ✓ | Classic, n=11 |
| [forest](problems/forest/) | 0.01s | 0.01s | ✓ | Union-find |
| [bitwise](problems/bitwise/) | 0.01s | 0.01s | ✓ | Micro-benchmark |
| [hashmap-bench](problems/hashmap-bench/) | 0.01s | 0.01s | ✓ | 10K inserts |
| [vector-add](problems/vector-add/) | 0.09s | 0.09s | ✓ | SIMD, 10M elements |
| [global-counter](problems/global-counter/) | 0.07s | 0.07s | ✓ | Atomic increment |
| [http-parser-bench](problems/http-parser-bench/) | 0.01s | 0.04s | ✓ | C 4x faster on parsing |
| [fstring-perf](problems/fstring-perf/) | 1.10s | 0.71s | ✓ | Rust 1.5x faster on fmt |
| [buffered-writer-perf](problems/buffered-writer-perf/) | 0.32s | 0.03s | ✓ | Rust 10x faster on I/O |
| [writer-perf](problems/writer-perf/) | 0.11s | 0.05s | ✓ | Rust 2x faster on writes |

19 problems where both C and Rust compile. C faster on 3, Rust faster on 6,
tied on 10. Salt contract verification passes on all 28 problems.

**Caveats.** Salt timing requires the full native pipeline (LLVM 21). The ✓
column means Z3 contract verification passes — bounds checks, division safety,
and loop invariants are proven at compile time. Five C files need arena allocator
headers from the original lattice project to compile. `dll-salt` has no C
baseline (C++ only in the original). `syntactic-chaos` is a compiler stress
test, not a performance benchmark.

## Problems

| Problem | Leetcode | Category |
|---------|----------|----------|
| [binary-tree-path](problems/binary-tree-path/) | LC 257 | Tree |
| [binary-trees](problems/binary-trees/) | LC 894 | Tree |
| [bitwise](problems/bitwise/) | — | Performance |
| [buffered-writer-perf](problems/buffered-writer-perf/) | — | Performance |
| [chase-lev-bench](problems/chase-lev-bench/) | Classic | Concurrency |
| [dll-salt](problems/dll-salt/) | LC 146 variant | Design |
| [fannkuch](problems/fannkuch/) | Classic | Algorithm |
| [fib](problems/fib/) | LC 509 | Math |
| [forest](problems/forest/) | Classic | Data Structure |
| [fstring-perf](problems/fstring-perf/) | — | Performance |
| [global-counter](problems/global-counter/) | — | Concurrency |
| [hashmap-bench](problems/hashmap-bench/) | — | Performance |
| [http-parser-bench](problems/http-parser-bench/) | — | Performance |
| [keuos-train](problems/keuos-train/) | — | ML (kernel) |
| [longest-consecutive](problems/longest-consecutive/) | LC 128 | Array |
| [lru-cache](problems/lru-cache/) | LC 146 | Design |
| [matmul](problems/matmul/) | Classic | Math |
| [merge-sorted-lists](problems/merge-sorted-lists/) | LC 23 | List |
| [sieve](problems/sieve/) | Classic | Math |
| [sliding-window-bench](problems/sliding-window-bench/) | LC 239 variant | Array |
| [string-hashmap-bench](problems/string-hashmap-bench/) | — | Performance |
| [sudoku-solver](problems/sudoku-solver/) | LC 37 | Backtracking |
| [syntactic-chaos](problems/syntactic-chaos/) | — | Compiler stress test |
| [trapping-rain-water](problems/trapping-rain-water/) | LC 42 | Array |
| [trapping-rain-water-u64](problems/trapping-rain-water-u64/) | LC 42 variant | Array |
| [trie](problems/trie/) | LC 208 | Trie |
| [vector-add](problems/vector-add/) | Classic | SIMD |
| [window-access](problems/window-access/) | — | Performance |
| [writer-perf](problems/writer-perf/) | — | Performance |

Kernel benchmarks (KeuOS-specific, skipped by `make bench`):
[epoch-reclaim](problems/bench-ecs-epoch-reclaim/),
[event-pipeline](problems/bench-ecs-event-pipeline/),
[ipc-resolve](problems/bench-ecs-ipc-resolve/),
[lookup](problems/bench-ecs-lookup/),
[scheduler](problems/bench-ecs-scheduler/),
[spawn](problems/bench-ecs-spawn/).

## See Also

- [Salt](https://github.com/bneb/salt) — the language
- [Basalt](https://github.com/bneb/basalt) — ML inference in Salt
- [Lettuce](https://github.com/bneb/lettuce) — Redis-compatible server in Salt
- [Facet](https://github.com/bneb/facet) — GPU 2D compositor in Salt
- [KeuOS](https://github.com/bneb/keuos) — Microkernel in Salt

## License

MIT
