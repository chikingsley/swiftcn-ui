# Architecture

Swiftcn translates shadcn's open-code and composition model into native SwiftUI.
The objective is predictable Swift source that can be copied into an app and
edited, while preserving Apple platform behavior wherever SwiftUI already
provides it.

## Principles

- **Open source units:** one readable Swift file is the normal copy unit.
- **Native behavior first:** style `Button`, `Toggle`, `ProgressView`, `Menu`,
  `DisclosureGroup`, and other system primitives instead of rebuilding them.
- **Composition:** content regions use `@ViewBuilder` slots. String initializers
  are convenience APIs, not the only API.
- **Shared vocabulary:** components reuse theme tokens, variant names, size
  names, accessibility conventions, and preview framing.
- **Platform adaptation:** macOS and iPadOS share a design system but may use
  different presentation, focus, pointer, keyboard, and compact-width behavior.

## Repository boundaries

```text
Sources/Swiftcn/
  Theme/       token model, default preset, palette, adaptive colors, preview frame
  Components/  reusable controls and compound primitives
  Blocks/      complete screens composed from components
  Effects/     optional visual effects
  Audio/       elevenlabs-ui audio ports and their engine seams

Showcase/      separate macOS-only executable package and demo catalog
cli/           separate Swift command-line package
Archive/       historical source that is not part of the current package
```

The root `Package.swift` exposes only the reusable `Swiftcn` library. It supports
macOS 14+ and iOS/iPadOS 17+. `Showcase/Package.swift` declares only macOS 14+.
This separation keeps the gallery off iPhone destinations without sacrificing
iPad support in the library.

## Theme

There is no local base `Color.swift`. `Color` is Apple's `SwiftUI.Color`,
imported from SwiftUI. `Color+Adaptive.swift` follows Swift's conventional
`Type+Capability.swift` naming and adds exactly one capability to that Apple
type: a light/dark initializer.

The four files in `Sources/Swiftcn/Theme/` have separate ownership:

| Source | Owns | Does not own |
| --- | --- | --- |
| `Palette.swift` | Raw reusable color scales and hex conversion | Component meaning or dark-mode choice |
| `Color+Adaptive.swift` | Native light/dark resolution for Apple's `Color` | Semantic tokens or a visual preset |
| `Theme.swift` | Semantic tokens, environment injection, and the built-in zinc preset | Preview-only framing |
| `SCPreview.swift` | Development framing for previews and Showcase demos | Production app theming; the CLI omits it when `includePreviews` is false |

The runtime path is deliberately one-way:

```text
Palette values -> Theme preset -> SwiftUI environment -> component token
                       |
                       +-> Color(light:dark:) resolves the current appearance
```

`Theme.swift` defines:

- semantic background/foreground pairs;
- border, input, and focus-ring colors;
- chart and sidebar token families;
- radius and font design;
- the SwiftUI environment key and `.theme(_:)` modifier;
- the built-in zinc/default preset.

Components read semantic theme tokens such as `theme.card` or
`theme.mutedForeground`. They do not select raw palette colors and they do not
branch on the current color scheme. A consumer-specific preset belongs in a
small `Theme` extension (for example, `Theme.timberVox`), while reusable
components continue to read the same semantic token names.

Additional presets should be extensions of `Theme`; they do not require new
component APIs.

## Package dependencies for engine wrappers

The library is dependency-free by default: components are open Swift source
over SwiftUI and the theme. The one sanctioned exception is a thin registry
component that wraps an established rendering engine, mirroring how upstream
registries declare npm package dependencies on their items. The precedent is
elevenlabs-ui's `response`, whose registry item declares the `streamdown`
package and whose component is a memoized wrapper around it; the Swift port
(`response` → `SCResponse`) wraps [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)
(exact upstream analog: Streamdown) and adds `swift-markdown-ui` (from 2.4.1)
to the root `Package.swift`.

Rules for such a dependency:

- the component stays a thin wrapper — theming, API shape, and adaptation
  live in the Swift file; the engine is not forked or patched;
- the registry item declares the package in its `dependencies` field the way
  shadcn items declare npm packages, and the component file header repeats the
  URL and version for consumers who vendor the file;
- `Showcase/Package.swift` needs no change: it consumes the root package by
  path, so SwiftPM resolves transitive package dependencies automatically.

## Variants and native styles

When SwiftUI has a style protocol, Swiftcn uses it:

```swift
Button("Delete") { delete() }
    .buttonStyle(.sc(.destructive, size: .sm))
```

Custom structures such as Badge, Card, Command, Sidebar, and Toast are ordinary
views. Public content regions use generic builders so callers can substitute
their own labels, rows, headers, actions, and empty states.

## Component source rules

- Public types use the `SC` prefix.
- Main types and initializers have doc comments and a usage example.
- Visible controls mutate state, navigate, or route a callback; unavailable
  actions are omitted.
- Component colors come from the theme.
- Meaningful states have named `#Preview` declarations using `SCPreview`.
- Platform-specific code is explicit with availability checks or `#if os(...)`.
- A source file may depend on other registry items, but the dependency must be
  recorded by the generated registry.

## macOS and iPadOS are not identical

They share SwiftUI source and design tokens, but validation must cover both:

- macOS: keyboard traversal, focus rings, hover, pointer cursors, menu commands,
  window resizing, sheets/popovers, and VoiceOver;
- iPadOS: size-class transitions, touch targets, hardware keyboard, pointer,
  sheet/popover adaptation, Dynamic Type, and VoiceOver.

An iPad-compatible source file is not proven merely because the macOS build
succeeds. The project needs separate compile and UI gates for both.

## Previews and Showcase

Every component file carries small, interactive previews. Richer demonstrations
live in `Showcase/Sources/Demos/`. `Showcase/Sources/RootView.swift` provides the
complete gallery preview and the runnable macOS gallery uses the same demos.

Previews are development surfaces, not automated proof. Snapshot checks and
XCUITest interaction flows provide visual and behavioral confidence.

The source registry lists `SCPreview.swift` as part of the theme development
surface, but `swiftcn add` excludes that file and strips `#Preview` blocks when
the consumer sets `includePreviews` to `false`. It is therefore absent from a
production-only consumer such as TimberVox by design.

## Distribution

The root package supports ordinary `import Swiftcn`. The registry/CLI path copies
source files and their dependencies into a consumer project so the app owns the
code. `swiftcn.json` records the consumer's registry, destination, platform,
preview policy, layout, and formatting policy. `.swiftcn.lock.json` records both
registry-source and installed hashes, allowing `swiftcn check` to distinguish a
local edit from an upstream update or a divergence of both.

The checked-in registry follows the official shadcn registry schema so standard
shadcn tooling can validate and address its items. The native Swift CLI owns the
Swift-specific installation contract: preview stripping, Apple formatting,
copy-owned update diffs, and safe overwrite behavior. A versioned package and
CLI release remain future distribution work.

## Parity evidence

“Port of shadcn” is not a single binary assertion across different UI runtimes.
The project keeps separate evidence layers:

1. `npx shadcn registry validate` proves the distribution document conforms to
   the official registry schema.
2. `parity/shadcn.json` accounts for every current official component and block,
   explicitly separates present and missing code, and stores machine mappings
   from selected upstream parts and behaviors to Swift symbols.
   `scripts/check_shadcn_parity.py` proves the inventory is fully classified and
   that every mapped production declaration and dependency still exists. It
   does not perform or approve the item-by-item `CODE` review in `TODO.md`.
   `parity/elevenlabs-ui.json` separately accounts for the adopted
   elevenlabs-ui components and native supporting items;
   `scripts/check_elevenlabs_parity.py` enforces the same source, symbol, and
   dependency contract for that named upstream.
3. macOS and iPadOS builds prove platform compilation.
4. XCUITest flows prove interaction and accessibility behavior.
5. snapshots prove selected visual states.

The registry and both parity-ledger checks are configured as CI gates. An
internally consistent ledger is not a claim that any source has passed `CODE`,
and neither layer substitutes for the `VALIDATION` gate.
