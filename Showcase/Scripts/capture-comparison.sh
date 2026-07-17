#!/bin/zsh

set -euo pipefail

script_dir=${0:A:h}
showcase_root=${script_dir:h}
output_dir=${1:-"$showcase_root/.comparison-shots"}
shift || true

all_components=(
  accordion alert alert-dialog aspect-ratio avatar badge breadcrumb button
  button-group calendar card chart checkbox collapsible combobox command
  context-menu dialog drawer dropdown-menu empty field hover-card input
  input-group input-otp item kbd label menubar navigation-menu pagination
  popover progress radio-group resizable scroll-area select separator sheet
  sidebar skeleton slider sonner switch table tabs textarea toggle toggle-group
  tooltip
)

if (( $# > 0 )); then
  components=("$@")
else
  components=("${all_components[@]}")
fi

mkdir -p "$output_dir"
rm -f "$output_dir"/*.png(N) "$output_dir"/.capture.log

swift build \
  --package-path "$showcase_root" \
  --configuration release \
  --product SwiftcnShowcase \
  -j 2

helper="$showcase_root/.build/capture-comparison-app"
xcrun swiftc -parse-as-library "$script_dir/capture-app.swift" -o "$helper"

app="$showcase_root/.build/release/SwiftcnShowcase"
current_pid=""

cleanup() {
  if [[ -n "$current_pid" ]]; then
    kill -TERM "$current_pid" 2>/dev/null || true
    wait "$current_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

for component in "${components[@]}"; do
  for appearance in light dark; do
    name="$component-$appearance"
    "$app" \
      --capture-component "$component" \
      --capture-appearance "$appearance" \
      >>"$output_dir/.capture.log" 2>&1 &
    current_pid=$!

    sleep 0.6
    "$helper" "$current_pid" "$appearance" "$output_dir/$name.png"
    print "captured $name"

    kill -TERM "$current_pid" 2>/dev/null || true
    wait "$current_pid" 2>/dev/null || true
    current_pid=""
  done
done

print "wrote ${#components} components x 2 appearances to $output_dir"
