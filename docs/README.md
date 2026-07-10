# swiftcn-ui 2.0 — design docs

Working documents for taking swiftcn-ui from "13 nice views" to a shadcn-grade system: one theme, one variant vocabulary, previews for everything, ~50 components, blocks, and eventually a `swiftcn add` CLI.

Read in order:

| Doc | What it covers |
|---|---|
| [01-principles.md](01-principles.md) | shadcn/ui's five principles (verified July 2026) and their SwiftUI translations; the two-layer split; where we deliberately diverge |
| [02-architecture.md](02-architecture.md) | The technical blueprint: `Theme` in the Environment (≙ CSS variables), enums + Style protocols (≙ cva), `@ViewBuilder` slots (≙ compound components), file anatomy, repo restructure, migration table for the existing 13 components |
| [03-previews.md](03-previews.md) | `#Preview` conventions per component file + the Showcase gallery app (a component browser built from the components it browses) |
| [04-roadmap.md](04-roadmap.md) | **The big list.** All 64 shadcn components mapped, sized, and prioritized into 5 phases, with a suggested 12-PR kill order |
| [05-registry-cli.md](05-registry-cli.md) | Future distribution: `registry.json` schema ported to Swift, the `swiftcn` CLI, GitHub-as-registry |

Status: docs drafted 2026-07-10. Nothing in `Sources/` exists yet — Phase 0 of the roadmap is the starting gun.
