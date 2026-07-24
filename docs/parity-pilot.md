# Accordion and Alert parity pilot

This pilot replaces the earlier full-window Accordion and Alert comparisons
with deterministic, state-specific captures. It proves source provenance,
native runtime stability, and cross-runtime visual structure as separate gates.

## Canonical web reference

The reference checkout is `/home/simon/github/swiftcn-shadcn-ref` on
`gmk-server`. It was overwritten with the current shadcn CLI using this exact
configuration:

- primitive base: Base UI
- visual style: Vega
- base/theme/chart color: zinc
- font: Inter
- icons: Lucide
- radius: default

The CLI now reports `style: base-vega`, `base: base`, preset `bd1gAJJg`, and 60
installed component source files. The official catalog has 64 concepts because
Data Table, Date Picker, Toast, and Typography are composition/documentation
concepts rather than four additional files emitted by `shadcn add --all`.

The project has a pnpm lockfile, so its canonical runner is `pnpm dlx`; no
`npx` command is used.

## Theme capability boundary

Swiftcn can express arbitrary semantic color tokens, adaptive light/dark
values, chart/sidebar tokens, radius, and font design through the public
`Theme` initializer and `.theme(_:)` environment injection. Only the zinc
theme is shipped as a built-in preset today.

That does not make Vega, Nova, Maia, Lyra, and Mira interchangeable Swift
"themes." Those shadcn styles also change component geometry and composition,
which Swiftcn currently implements in component source. Adding named visual
styles would require an explicit component-metrics/style layer, not only new
color tokens.

## Fixture contract

The web and Swift fixtures share the same content, state names, component
widths, and 16-point capture stage:

- Accordion: 448-point component width; `expanded` opens only `item-1`;
  `collapsed` opens none.
- Alert: 672-point component width; separate `default` and `destructive`
  fixtures.
- Every fixture is captured in light and dark appearance, producing eight
  images per runtime.

The web capture asserts the Accordion `aria-expanded` vector or Alert role
before taking an element-only screenshot. The Swift capture launches the real
macOS Showcase executable in the named state and sizes its borderless window to
the fixture instead of the old 900x800 catalog canvas.

## Gates and commands

On `gmk-server`:

```sh
cd /home/simon/github/swiftcn-shadcn-ref
pnpm capture:pilot
pnpm check:gallery
pnpm test:gallery-server
```

On the Mac checkout:

```sh
Showcase/Scripts/capture-pilot.sh --verify
Showcase/Scripts/check-pilot-parity.sh
```

`capture-pilot.sh --record` is the explicit golden-update operation and should
only be run after reviewing intentional visual changes. Verification requires
the eight regenerated PNGs to match the checked-in Swift runtime goldens
exactly.

The cross-runtime checker is intentionally not pixel equality. It requires a
shared stage width, at least 0.80 aspect similarity, at least 0.35 ink-mask Dice
overlap, and at least 0.80 combined normalized color/edge/ink/aspect similarity.
It also writes red normalized diff heatmaps for review.

The persistent review UI is served from `http://gmk-server:4174/`. Accordion
and Alert now contain the state-specific pilot pairs. The remaining gallery
rows are explicitly marked as the older full-page wave and are not accepted
against the new Base UI/Vega reference until regenerated.

## Pilot evidence

On 2026-07-17:

- the Base UI/Vega reference build and all eight web state assertions passed;
- eight Swift runtime goldens repeated byte-for-byte;
- all eight cross-runtime pairs passed the structural/perceptual thresholds;
- eight targeted Accordion/Alert behavior and rendering UI tests passed;
- four targeted light/dark Apple accessibility audits passed.

The behavior run caught a real Alert defect: its decorative border overlay was
eligible for hit testing and swallowed clicks intended for `SCAlertAction`.
The border now opts out of hit testing.
