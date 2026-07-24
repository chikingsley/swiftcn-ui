#!/bin/zsh

set -euo pipefail

script_dir=${0:A:h}
showcase_root=${script_dir:h}
web_dir=${1:-"$showcase_root/.web-pilot-actual"}
swift_dir=${2:-"$showcase_root/.pilot-actual"}
report="$showcase_root/.pilot-parity-report.json"
diff_dir="$showcase_root/.pilot-diffs"
checker="$showcase_root/.build/check-pilot-parity"

if [[ ! -d "$web_dir" ]]; then
  print -u2 "missing web pilot directory: $web_dir"
  exit 2
fi
if [[ ! -d "$swift_dir" ]]; then
  print -u2 "missing Swift pilot directory: $swift_dir"
  exit 2
fi

mkdir -p "$showcase_root/.build" "$diff_dir"
rm -f "$diff_dir"/*.png(N)
xcrun swiftc -parse-as-library "$script_dir/compare-pilot.swift" -o "$checker"
"$checker" "$swift_dir" "$web_dir" "$report" "$diff_dir"
print "wrote parity report to $report"
print "wrote normalized heatmaps to $diff_dir"
