#!/usr/bin/env bash
# Regression MP1 equipe 05 : CMP (Lab 4 + C1-C4, C6, C7), SHIFT (S1-S10 + C5), BL (B1-B8)
# Usage : depuis la racine du depot :  bash 03_TESTBENCH/regression/run_regression_ghdl.sh
# Prerequis : GHDL >= 3.0 (VHDL-2008).
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/04_RESULTS/REGRESSION"
WORK="$(mktemp -d)"
mkdir -p "$OUT"
status=0

run_suite () {   # $1 = nom, $2 = entite tb, $3... = fichiers de test (remplacent imem.vhd au besoin)
  local name="$1" tb="$2"; shift 2
  local dir="$WORK/$name"
  mkdir -p "$dir"
  cp "$ROOT"/02_HDL/final_design/*.vhd "$dir/"
  for f in "$@"; do cp "$f" "$dir/"; done
  ( cd "$dir" && ghdl -i --std=08 *.vhd >/dev/null 2>&1 && ghdl -m --std=08 "$tb" >/dev/null \
      && ghdl -r --std=08 "$tb" --stop-time=5us ) > "$OUT/${name}_console.txt" 2>&1
  if grep -q -E "SIMULATION CONFORME" "$OUT/${name}_console.txt" && ! grep -qi -E "non conforme|: FAIL" "$OUT/${name}_console.txt"; then
    echo "[PASS] $name"
  else
    echo "[FAIL] $name  (voir $OUT/${name}_console.txt)"; status=1
  fi
}

run_suite CMP   tb_arm_top "$ROOT/03_TESTBENCH/CMP/tb_arm_top.vhd" "$ROOT/02_HDL/baseline_lab4/ExpectedData.txt"
run_suite SHIFT tb_shift   "$ROOT"/03_TESTBENCH/SHIFT/*.vhd
run_suite BL    tb_bl      "$ROOT"/03_TESTBENCH/BL/*.vhd
rm -rf "$WORK"
exit $status
