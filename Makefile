CC ?= clang
RUSTC ?= rustc
SALTC ?= saltc
RUNS ?= 5

.PHONY: check bench clean

check:
	@bash harness/check.sh

bench:
	@bash harness/bench.sh $(PROBLEM)

clean:
	rm -rf build/
