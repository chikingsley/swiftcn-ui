#!/bin/zsh

set -euo pipefail

script_dir=${0:A:h}
showcase_root=${script_dir:h}
mode=${1:---verify}
actual_dir="$showcase_root/.pilot-actual"
golden_dir="$showcase_root/Tests/GoldenSnapshots/Pilot"

if [[ "$mode" != "--record" && "$mode" != "--verify" ]]; then
  print -u2 "usage: capture-pilot.sh [--record|--verify]"
  exit 2
fi

mkdir -p "$actual_dir" "$golden_dir"
rm -f "$actual_dir"/*.png(N) "$actual_dir"/.capture.log

swift build \
  --package-path "$showcase_root" \
  --configuration release \
  --product SwiftcnShowcase \
  -j 2

helper="$showcase_root/.build/capture-comparison-app"
xcrun swiftc -parse-as-library "$script_dir/capture-app.swift" -o "$helper"

app="$showcase_root/.build/release/SwiftcnShowcase"
fixtures=(
  "accordion expanded"
  "accordion collapsed"
  "alert default"
  "alert destructive"
)
current_pid=""

cleanup() {
  if [[ -n "$current_pid" ]]; then
    kill -TERM "$current_pid" 2>/dev/null || true
    wait "$current_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

for fixture in "${fixtures[@]}"; do
  component=${fixture%% *}
  state=${fixture#* }
  for appearance in light dark; do
    name="$component-$state-$appearance"
    "$app" \
      --capture-component "$component" \
      --capture-state "$state" \
      --capture-appearance "$appearance" \
      >>"$actual_dir/.capture.log" 2>&1 &
    current_pid=$!

    sleep 0.8
    "$helper" "$current_pid" "$appearance" "$actual_dir/$name.png"
    print "captured $name"

    kill -TERM "$current_pid" 2>/dev/null || true
    wait "$current_pid" 2>/dev/null || true
    current_pid=""
  done
done

if [[ "$mode" == "--record" ]]; then
  rsync -a --delete "$actual_dir"/ "$golden_dir"/
  rm -f "$golden_dir/.capture.log"
  print "recorded 8 Swift runtime goldens in $golden_dir"
  exit 0
fi

for actual in "$actual_dir"/*.png(N); do
  golden="$golden_dir/${actual:t}"
  if [[ ! -f "$golden" ]]; then
    print -u2 "missing golden: $golden (run with --record after review)"
    exit 1
  fi
  if ! cmp -s "$golden" "$actual"; then
    print -u2 "golden mismatch: ${actual:t}"
    exit 1
  fi
done

print "verified 8 exact Swift runtime goldens"
