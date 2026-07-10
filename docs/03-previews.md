# Previews: seeing every component inside Xcode

shadcn's docs site renders a live demo of every component with a code tab next to it. The Xcode-native equivalent has two layers, and we should do both:

1. **`#Preview` blocks in every component file** — instant canvas feedback while developing or after copy-pasting a component.
2. **A Showcase app** — a browsable gallery of all components (itself built out of swiftcn components), runnable in the simulator *and* viewable in the canvas.

---

## 1. Per-file `#Preview` blocks (the baseline)

Every component file ends with previews using the modern `#Preview` macro — the existing `PreviewProvider` boilerplate goes away, including the awkward `PreviewWrapper` structs we currently write to hold `@State`. Xcode 16's `@Previewable` handles state inline:

```swift
#Preview("Input") {
    @Previewable @State var email = ""

    SCInput("Email", text: $email, icon: "envelope")
        .padding()
}
```

Conventions:

- **One named `#Preview` per meaningful state**, not one giant preview. Names show up in the canvas picker:

  ```swift
  #Preview("Button · variants") { … }   // all six variants stacked
  #Preview("Button · sizes")    { … }   // sm / default / lg / icon
  #Preview("Button · disabled") { … }
  #Preview("Button · loading")  { … }
  ```

- **Don't write light/dark previews by hand.** The canvas variants button (bottom bar → Color Scheme Variants) renders both automatically, and Dynamic Type variants catch text-scaling bugs. Reserve explicit `.preferredColorScheme(.dark)` previews for components with structural dark-mode differences.

- **Interactive canvas is real**: previews are live by default — toggles toggle, text fields type. That's our "preview thing" with zero extra infrastructure.

### The `SCPreview` wrapper

A tiny helper (lives in `Theme/SCPreview.swift`, dev-only) standardizes framing so every component's previews look consistent:

```swift
struct SCPreview<Content: View>: View {
    var title: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title { Text(title).font(.caption).foregroundStyle(.secondary) }
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.default.background)
        .theme(.default)
    }
}
```

Usage: `#Preview { SCPreview("Destructive") { Button("Delete"){}.buttonStyle(.sc(.destructive)) } }`. It guarantees the theme is injected (previews don't inherit app-level modifiers) — forgetting this is the #1 "why does my preview look unstyled" bug.

---

## 2. The Showcase app (the gallery)

A small Xcode app target at `Showcase/` that is the killer demo: **the component browser is built from the components it browses.** Sidebar = `SCSidebar`, search = `SCCommand` (later), the component pages use `SCTabs` to flip between Preview and Code.

### Structure

```
Showcase/
├── ShowcaseApp.swift
├── ComponentCatalog.swift        # the registry: one entry per component
├── ComponentDetailView.swift     # renders demos + code for a selected entry
└── Demos/
    ├── ButtonDemos.swift         # the same demo views the #Previews use
    ├── BadgeDemos.swift
    └── …
```

The catalog is data, not hardcoded views:

```swift
struct ComponentEntry: Identifiable {
    let id: String                 // "button"
    let name: String               // "Button"
    let category: Category         // .form, .layout, .feedback, .navigation, .display
    let status: Status             // .stable, .beta, .planned
    let demos: [Demo]
}

struct Demo: Identifiable {
    let id: String
    let title: String              // "Variants"
    let code: String               // the snippet shown in the Code tab
    let view: AnyView              // the live rendering
}
```

Root view is `NavigationSplitView` (sidebar on iPad/Mac, stack on iPhone), grouped by category with a search field, exactly like the shadcn docs sidebar:

```swift
NavigationSplitView {
    List(catalog.grouped, selection: $selection) { group in
        Section(group.category.title) {
            ForEach(group.entries) { entry in
                NavigationLink(value: entry.id) {
                    LabeledContent(entry.name) {
                        if entry.status == .beta { SCBadge("Beta", variant: .secondary) }
                    }
                }
            }
        }
    }
    .searchable(text: $query)
} detail: {
    ComponentDetailView(entry: selected)
}
```

Detail page per component: title, description, then each `Demo` as a card with a **Preview / Code** tab pair (code rendered in monospaced text with a copy button). This mirrors ui.shadcn.com one-to-one and doubles as living documentation — when the Mintlify docs and the code drift, the Showcase can't lie because it compiles.

### Reuse between `#Preview` and Showcase

Demo views are written once in `Showcase/Demos/` — no, better: **in the component file itself** as a `…Demos` enum of small static views, so they stay in the copy-paste unit's file *neighborhood* but excluded from the copy unit:

Pragmatic rule instead: each component file's `#Preview`s stay minimal and self-contained; richer multi-state demos live in `Showcase/Demos/`. Duplication between the two is acceptable and small (a few lines each), and it keeps component files clean for copy-paste.

### Why a separate app target instead of more previews?

- Previews are per-file; the Showcase answers "what does the *system* look like" — spacing rhythm, theme coherence, dark mode across everything at once.
- It's the manual QA surface for every PR ("run the Showcase, eyeball your component in both schemes").
- It's the future marketing asset: screenshots/screen-recordings for the README, and eventually a TestFlight demo anyone can install.
- The `.swiftpm` playground remains the zero-install taste-test; the Showcase is the full catalog. The playground's `ContentView` eventually just embeds the Showcase root.

---

## 3. Later: snapshot tests on top of previews

Once components stabilize, `swift-snapshot-testing` (Point-Free) can render every catalog entry to reference images in CI — light/dark × Dynamic Type sizes. The `ComponentCatalog` doubles as the test manifest: one parameterized test walks every `Demo` in the catalog, so adding a component to the Showcase automatically adds its snapshot coverage. Not phase-one work, but the catalog design above is what makes it nearly free later.
