#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec /usr/bin/python3 -m http.server "${PORT:-4174}" \
  --bind "${BIND:-0.0.0.0}" \
  --directory "$repo_root/gallery"
