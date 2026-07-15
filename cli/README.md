# swiftcn CLI

`swiftcn` installs selected SwiftUI source files into an application so the
consumer owns and can edit them, following shadcn's open-code distribution
model. The CLI is a separate native Swift package built with
`swift-argument-parser`.

## Consumer contract

Initialize a consumer from the registry checkout:

```console
swift run --package-path /path/to/swiftcn-ui/cli swiftcn init \
  --cwd /path/to/MyApp \
  --registry /path/to/swiftcn-ui/registry.json \
  --target MyApp/Features/Components/UI \
  --platform macOS
```

This writes:

- `swiftcn.json`, the reviewable consumer configuration;
- `.swiftcn.lock.json`, source and installed hashes used to distinguish local
  edits from upstream updates;
- the production theme sources in the configured target.

`swiftcn.json` is described by
[`schemas/swiftcn.schema.json`](../schemas/swiftcn.schema.json). The CLI decodes
and version-checks the file; it does not run a JSON Schema validator itself. The
file controls the registry, destination, Apple platform, preview inclusion,
file layout, and use of Apple `swift format`.

## Commands

```console
swiftcn list
swiftcn view sidebar
swiftcn add sidebar tooltip kbd
swiftcn add sidebar --diff
swiftcn add sidebar --overwrite
swiftcn check
```

- `add` resolves transitive dependencies and strips preview-only source and
  dependencies unless the consumer opted into previews.
- `add --diff` shows the exact update without writing.
- `add` preserves locally changed files by default; `--overwrite` is explicit.
- `check` classifies each tracked file as current, locally modified, update
  available, diverged, or missing and exits nonzero when action is needed.
- source and destination paths are containment-checked, symlink escapes are
  rejected, and dependency cycles are errors.

## shadcn registry compatibility

`registry.json` uses the official shadcn registry schema. Regenerate and check
it with:

```console
python3 scripts/generate_registry.py
python3 scripts/generate_registry.py --check
bunx --bun shadcn@latest registry validate ./registry.json
```

The official CLI validates the source-registry document shape. The native
`swiftcn` CLI remains responsible for Swift-specific behavior such as
`swiftcn.json`, preview stripping, Apple formatting, and the local-modification
lock contract.
