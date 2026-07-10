# Principles: what shadcn/ui actually is, and what swiftcn should be

*(shadcn/ui facts below verified against ui.shadcn.com, July 2026.)*

## The core idea

shadcn/ui's opening line: **"This is not a component library. It is how you build your component library."** Nothing is installed from a package — code is distributed *into* your project and you own it from day one. swiftcn-ui's existing tagline ("No package install, no bs") is already this philosophy; 2.0 is about executing the rest of the system that makes it work at scale.

shadcn states five principles. Here is each one, and its swiftcn translation:

### 1. Open Code
> "The top layer of your component code is open for modification."

**swiftcn:** every component is one readable `.swift` file you copy into your app. Customization = editing Swift, not fighting a wrapper API with 15 optional color parameters. This is why we *remove* `backgroundColor:`/`foregroundColor:` params rather than add more — the file itself is the customization surface, and the theme handles the 95% case.

### 2. Composition
> "Every component uses a common, composable interface, making them predictable."

**swiftcn:** components expose `@ViewBuilder` slots and compound sub-views (`SCCard` + `SCCardHeader` + `SCCardFooter`), never `String` props for content regions. Consistency rules: same variant vocabulary everywhere (`default/secondary/destructive/outline/ghost`), same size vocabulary (`sm/default/lg/icon`), same theme tokens, same file anatomy.

### 3. Distribution
> A flat-file schema and CLI that distributes code to any project.

**swiftcn:** phased. Phase one: self-contained files + a `registry.json` index in the repo. Phase two: a `swiftcn` CLI (`swiftcn add button`) that resolves dependencies and copies files in. shadcn's June 2026 change — *any public GitHub repo containing a `registry.json` is a registry, no server needed* — is exactly the model to copy. See `05-registry-cli.md`.

### 4. Beautiful Defaults
> "Carefully chosen default styles... designed to work well together as a consistent system."

**swiftcn:** one default theme (a port of shadcn's zinc/neutral scale), one radius token, one spacing rhythm, defined once in `Theme/`. Every component drinks from it. Drop a Button next to a Card next to an Input with zero configuration and it looks like one product. This is the single biggest gap in the current codebase — today each component picks its own grays.

### 5. AI-Ready
> "Open code for LLMs to read, understand, and improve."

**swiftcn:** consistent file anatomy (see `02-architecture.md` §4) means a model — or Xcode's predictive completion — can read one component and correctly write the next. The `registry.json` gives agents a machine-readable catalog. Honestly, this repo will be *built* largely by AI following these docs, which is the same property.

## The two-layer split

shadcn's architecture is explicitly two layers:

1. **Structure & behavior layer** — Base UI / Radix primitives: accessibility, focus, keyboard handling, ARIA. shadcn does not write this layer; it rides on it.
2. **Style layer** — Tailwind classes over CSS-variable tokens. This is the layer you own and edit.

This maps to SwiftUI *better than to the web*, because SwiftUI ships the primitive layer in the OS: `Button`, `Toggle`, `ProgressView`, `DisclosureGroup`, `Menu`, `NavigationSplitView` already handle accessibility, focus, Dynamic Type, and platform conventions. **swiftcn's job is the style layer**: Style-protocol implementations and themed components over native primitives wherever one exists, custom structure only where the OS has no primitive (badge, toast, command palette, sidebar rail…).

Corollary: never rebuild behavior Apple gives us. `CustomToggle` wrapping `Toggle` with a hand-rolled tap gesture is the anti-pattern; `SCSwitchStyle: ToggleStyle` is the pattern.

## What we deliberately do differently from shadcn

- **No Tailwind analogy.** SwiftUI modifiers are already utility-composable; we don't need a class-string DSL. Variants are enums, tokens are a struct.
- **Dark mode is one theme, not two.** Adaptive `Color(light:dark:)` resolves per scheme; there is no `.dark {}` block to maintain.
- **Platform adaptivity is a feature dimension shadcn doesn't have.** Components should degrade across iPhone / iPad / Mac (e.g. Sidebar → sheet on compact width, exactly like shadcn's sidebar becomes a Sheet on mobile — but we get size classes natively).
- **Some shadcn components dissolve into one-line modifiers here** (aspect-ratio, scroll-area, direction/RTL). We document the mapping instead of shipping a file — the docs page *is* the component.
