#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec /usr/bin/python3 "$repo_root/ops/gallery_server.py" \
  --repo-root "$repo_root" \
  --port "${PORT:-4174}" \
  --bind "${BIND:-0.0.0.0}"
