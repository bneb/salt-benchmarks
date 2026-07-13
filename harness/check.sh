#!/bin/bash
# Verify every Salt benchmark compiles and contracts pass.
# Only needs saltc. No LLVM required. CI-safe.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SALTC="${SALTC:-saltc}"
PASS=0; FAIL=0; SKIP=0

check_tool() { command -v "$1" >/dev/null 2>&1; }

if ! check_tool "$SALTC"; then
    echo "saltc not found. Set SALTC=/path/to/saltc"
    exit 1
fi

echo "saltc: $("$SALTC" --version 2>/dev/null || echo "unknown")"
echo ""

for d in "$ROOT"/problems/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    # Find first .salt file in directory (handles both foo/foo.salt and foo/foo_bar.salt)
    src=$(echo "$d"/*.salt 2>/dev/null | head -1)
    [ "$src" = "$d/*.salt" ] && src=""
    if [ -z "$src" ]; then
        printf "  %-30s %s\n" "$name" "no .salt file"
        SKIP=$((SKIP + 1))
        continue
    fi
    if "$SALTC" "$src" --lib --disable-alias-scopes -o /dev/null 2>/dev/null; then
        printf "  %-30s %s\n" "$name" "PASS"
        PASS=$((PASS + 1))
    else
        printf "  %-30s %s\n" "$name" "FAIL"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "$PASS passed, $FAIL failed, $SKIP skipped"

if [ "$FAIL" -gt 0 ]; then exit 1; fi
