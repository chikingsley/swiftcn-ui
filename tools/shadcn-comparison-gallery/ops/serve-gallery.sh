#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
uv_bin=${UV_BIN:-/home/simon/.local/bin/uv}
exec "$uv_bin" run --no-project "$repo_root/ops/gallery_server.py" \
  --repo-root "$repo_root" \
  --port "${PORT:-4174}" \
  --bind "${BIND:-0.0.0.0}"
