#!/bin/bash
# Compile and time C and Rust. Verify Salt contracts.
# Usage: make bench [PROBLEM=name]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build"; mkdir -p "$OUT"
CC="${CC:-clang}"; RUSTC="${RUSTC:-rustc}"; SALTC="${SALTC:-saltc}"
RUNS="${RUNS:-5}"; WARMUP="${WARMUP:-2}"

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; NC='\033[0m'
check_tool() { command -v "$1" >/dev/null 2>&1; }

time_c() {
    local src="$1" out="$2" runs="$3" total=0 t
    check_tool "$CC" || return 0
    "$CC" -O3 -o "$out" "$src" -lm 2>/dev/null || return 0
    for _ in $(seq 1 "$WARMUP"); do "$out" >/dev/null 2>&1 || true; done
    for _ in $(seq 1 "$runs"); do
        t=$( ( /usr/bin/time -p "$out" >/dev/null ) 2>&1 | grep real | awk '{print $2}' )
        total=$(echo "$total + ${t:-0}" | bc -l 2>/dev/null || echo 0)
    done
    echo "scale=4; $total / $runs" | bc -l 2>/dev/null
}

time_rs() {
    local src="$1" out="$2" runs="$3" total=0 t
    check_tool "$RUSTC" || return 0
    "$RUSTC" -C opt-level=3 -o "$out" "$src" 2>/dev/null || return 0
    for _ in $(seq 1 "$WARMUP"); do "$out" >/dev/null 2>&1 || true; done
    for _ in $(seq 1 "$runs"); do
        t=$( ( /usr/bin/time -p "$out" >/dev/null ) 2>&1 | grep real | awk '{print $2}' )
        total=$(echo "$total + ${t:-0}" | bc -l 2>/dev/null || echo 0)
    done
    echo "scale=4; $total / $runs" | bc -l 2>/dev/null
}

time_salt() {
    check_tool "$SALTC" || return 1
    "$SALTC" "$1" --lib --disable-alias-scopes -o /dev/null 2>/dev/null
}

bench_one() {
    local d="$1" name; name=$(basename "$d")
    local s="$d/${name}.salt" c="$d/${name}.c" r="$d/${name}.rs"
    # Fallback: try alternate naming (foo_bar.salt in foo-bar/)
    [ -f "$s" ] || s=$(echo "$d"/*.salt 2>/dev/null | head -1)
    [ -f "$c" ] || c=$(echo "$d"/*.c 2>/dev/null | head -1)
    [ -f "$r" ] || r=$(echo "$d"/*.rs 2>/dev/null | head -1)
    [ "$s" = "$d/*.salt" ] && s=""
    [ "$c" = "$d/*.c" ] && c=""
    [ "$r" = "$d/*.rs" ] && r=""

    printf "  %-26s" "$name"
    if [ -n "$c" ] && [ -f "$c" ]; then
        t=$(time_c "$c" "$OUT/${name}_c" "$RUNS" 2>/dev/null)
        [ -n "$t" ] && printf "  C=${t}s" || printf "  ${YELLOW}C✗${NC}"
    fi
    if [ -n "$r" ] && [ -f "$r" ]; then
        t=$(time_rs "$r" "$OUT/${name}_rs" "$RUNS" 2>/dev/null)
        [ -n "$t" ] && printf "  R=${t}s" || printf "  ${YELLOW}R✗${NC}"
    fi
    if [ -n "$s" ] && [ -f "$s" ]; then
        time_salt "$s" 2>/dev/null && printf "  ${GREEN}S✓${NC}" || printf "  ${RED}S✗${NC}"
    fi
    echo ""
}

echo "salt-benchmarks"
echo "cc:     $(command -v "$CC" 2>/dev/null || echo 'not found')"
echo "rustc:  $(command -v "$RUSTC" 2>/dev/null || echo 'not found')"
echo "saltc:  $(command -v "$SALTC" 2>/dev/null || echo 'not found')"
echo "runs:   $RUNS  (warmup: $WARMUP)"
echo ""

if [ $# -gt 0 ]; then
    for arg in "$@"; do
        bench_one "$ROOT/problems/$arg"
    done
else
    for d in "$ROOT"/problems/*/; do
        [ -d "$d" ] || continue
        bench_one "$d"
    done
fi
