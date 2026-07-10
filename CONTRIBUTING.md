# Contributing

> swiftcn-ui is under active development. v2 lives in `Sources/Swiftcn/`; the design docs in [`docs/`](docs/README.md) explain the architecture — read them before contributing a component.

We welcome contributions from the community. For any bug reports or feature requests, please
[open an issue](https://github.com/Mobilecn-UI/swiftcn-ui/issues/new).

## Contributing a component

Pick an unclaimed item from the [roadmap](docs/04-roadmap.md) and open an issue to claim it, then:

1. Fork the repo, create a feature branch.
2. Add **one self-contained file** at `Sources/Swiftcn/Components/<Name>.swift` following the checklist below.
3. Verify `swift build` passes and previews render in Xcode (open the package directly).
4. Open a PR with a screenshot (light + dark) from the preview canvas.

### Component checklist

Every component file must have:

- [ ] Header banner comment (`// Name.swift — swiftcn-ui / Depends on: Theme/`) and `MARK:` sections: Variants → Component → Subcomponents → Convenience → Previews.
- [ ] `SC` prefix on all public types; variant enums are `SC<Name>Variant: CaseIterable, Sendable`.
- [ ] Colors read **only** from `@Environment(\.theme)` tokens — no `colorScheme` branching, no raw `.gray`/`.black`/`.white`.
- [ ] Content regions are `@ViewBuilder` slots; `String` convenience initializers are sugar, never the only API. No `AnyView` in public API.
- [ ] Corner radii derive from `theme.radius`.
- [ ] Native primitive + Style protocol where one exists (`ButtonStyle`, `ToggleStyle`, …) — never rebuild behavior the OS provides.
- [ ] `///` doc comments with a usage snippet on the main type.
- [ ] 1–3 named `#Preview` blocks wrapped in `SCPreview`, using `@Previewable @State` for state.
- [ ] Compiles for iOS 17 **and** macOS 14 (`#if os(iOS)` guards where needed).
- [ ] Accessibility: labels on icon-only controls, meaningful values on stateful ones, survives Dynamic Type.

The exemplars to copy: [`Button.swift`](Sources/Swiftcn/Components/Button.swift) and [`Badge.swift`](Sources/Swiftcn/Components/Badge.swift).

## Legacy v1

The `Swiftcn Playground.swiftpm` contains the original v1 `Custom*` components and remains as a zero-install demo until the v2 Showcase replaces it. New work targets `Sources/Swiftcn/` only.
