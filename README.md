# swiftcn-ui

SwiftUI components and composed screens inspired by shadcn/ui, primarily for
macOS and iPadOS.

This working tree is the current source of truth. These uncommitted changes are
not a published release. All current and unfinished work lives in
[TODO.md](TODO.md).

## What is here

- `Sources/Swiftcn/Components/` — reusable controls and compound primitives.
- `Sources/Swiftcn/Blocks/` — complete screens composed from components.
- `Sources/Swiftcn/Effects/` — optional visual effects.
- `Sources/Swiftcn/Theme/` — design tokens, adaptive colors, palette, and preview framing.
- `Showcase/` — the macOS-only component gallery.
- `registry.json`, `schemas/swiftcn.schema.json`, and `cli/` — copy-owned source distribution.
- `parity/shadcn.json` — official inventory, source coverage, and machine structural maps; it is not code-review approval.
- `Archive/` — the original v1 iOS playground, retained only as historical reference.

## Consume it

The root package is a reusable library supporting macOS 14+ and iOS/iPadOS 17+:

```swift
.package(path: "/path/to/swiftcn-ui")
```

Then depend on the `Swiftcn` product and import it:

```swift
import Swiftcn
```

For shadcn-style source ownership, initialize a project and add only the
components it uses:

```console
swift run --package-path /path/to/swiftcn-ui/cli swiftcn init \
  --cwd /path/to/MyApp --registry /path/to/swiftcn-ui/registry.json
cd /path/to/MyApp
swift run --package-path /path/to/swiftcn-ui/cli swiftcn add sidebar tooltip kbd
swift run --package-path /path/to/swiftcn-ui/cli swiftcn check
```

See [cli/README.md](cli/README.md) for the consumer contract. The current work
has not been published as a versioned package or CLI binary release yet.

## Browse the macOS gallery

The gallery is deliberately a separate macOS-only package so Xcode does not
prepare an iPhone when you inspect it.

```console
swift run --package-path Showcase SwiftcnShowcase
```

In Xcode, open `Showcase/Package.swift`, select `SwiftcnShowcase` and `My Mac`,
then run it. Open `Showcase/Sources/RootView.swift` for the complete gallery
Canvas, or a file under `Showcase/Sources/Demos/` for focused named previews.

Opening the root `Package.swift` opens the reusable library. It is not an app
and therefore has nothing meaningful to run.

## Theme

`Theme.swift` owns semantic tokens, environment injection, and the built-in
zinc preset. `Palette.swift` owns raw reusable color scales.
`Color+Adaptive.swift` extends Apple's `SwiftUI.Color` with native light/dark
resolution; there is intentionally no local base `Color.swift`.
`SCPreview.swift` is development-only framing and is omitted for consumers with
`includePreviews: false`.

```swift
ContentView().theme(.default)
```

See the [Theme ownership table](docs/architecture.md#theme) for the complete
source-to-runtime flow and where an app-specific preset belongs.

## Format and validate

Apple's formatter ships with the Swift toolchain. No Mint installation or
version pin is required:

```console
swift format format --configuration .swift-format --recursive --parallel --in-place \
  Sources Showcase/Sources cli/Sources

swift format lint --configuration .swift-format --recursive --parallel --strict \
  Sources Showcase/Sources cli/Sources

swiftlint lint --strict --config .swiftlint.yml
```

SwiftLint is optional locally but required by CI. CI installs the current
Homebrew release rather than a repository-pinned version.

Build and registry validation are explicit:

```console
swift build --package-path Showcase --product SwiftcnShowcase
python3 scripts/generate_registry.py --check
npx shadcn@latest registry validate ./registry.json
python3 scripts/check_shadcn_parity.py
```

## Architecture

See [docs/architecture.md](docs/architecture.md) for the stable design rules.
Distribution details live with the tool in [cli/README.md](cli/README.md). Work
tracking belongs only in [TODO.md](TODO.md).
