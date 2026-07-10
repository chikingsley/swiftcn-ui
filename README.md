# swiftcn-ui

Beautifully designed SwiftUI components you can copy and paste into your apps. A full port of the [shadcn/ui](https://ui.shadcn.com) system — design tokens, variants, composition, blocks, and a registry — for iOS 17+ and macOS 14+.

**This is not a component library. It is how you build your component library.**

|          Dark mode           |          Light mode           |
| :--------------------------: | :---------------------------: |
| ![](assets/example-dark.png) | ![](assets/example-light.png) |
|    ![](assets/X-dark.png)    |    ![](assets/X-light.png)    |

## How it works

Every component is **one self-contained Swift file** that depends only on the `Theme/` folder — copy the files you need into your project and you own the code. Colors come from a `Theme` token set injected through the SwiftUI environment (the analog of shadcn's CSS variables), so dark mode is automatic and re-theming your whole app is one struct:

```swift
// At your app root (optional — the default theme works with zero setup):
ContentView().theme(.default)

// Components style native SwiftUI primitives, shadcn-style:
Button("Continue") { … }.buttonStyle(.sc())
Button("Delete") { … }.buttonStyle(.sc(.destructive))
Toggle("Notifications", isOn: $on).toggleStyle(.scSwitch)

// And compose through slots, not string props:
SCCard {
    SCCardHeader {
        SCCardTitle("Accelerate UI")
        SCCardDescription("Enter a new development experience")
    }
    SCCardContent { SCInput("Email", text: $email, icon: "envelope") }
    SCCardFooter { Button("Deploy") { … }.buttonStyle(.sc()) }
}
```

## Getting started

**Copy-paste (the intended way):** grab `Sources/Swiftcn/Theme/` once, then copy any component file from `Sources/Swiftcn/Components/`. Each file's header lists its dependencies; [`registry.json`](registry.json) is the machine-readable index of every item and its dependency graph.

**Swift Package Manager (if you'd rather import):**

```swift
.package(url: "https://github.com/Mobilecn-UI/swiftcn-ui", branch: "main")
```

**Browse everything:** open `Showcase.swiftpm` in Xcode and run it — a gallery of every component and block, built out of the components it browses. Or open the package root in Xcode and use the `#Preview` canvas in any component file.

## Components (40)

Accordion · Alert · Alert Dialog · Avatar (+ Group) · Badge · Breadcrumb · Button · Button Group · Card · Chart · Checkbox · Collapsible · Dialog · Drawer · Empty · Field · Input · Input OTP · Item · Kbd · Label · Popover · Progress · Radio Group · Select · Separator · Sheet · Sidebar · Skeleton · Slider · Spinner · Switch · Tabs · Textarea · Toast · Toggle · Toggle Group · Typography
**Effects:** Dot Pattern · Shimmer (+ Shimmer Button)

## Blocks

Composed screens built from the components — copy one file, get a whole page:

- `SCLoginBlock` — login-01: card login form with social sign-in
- `SCSettingsBlock` — settings screen (profile, preferences, danger zone)
- `SCSidebarBlock` — sidebar-07: collapsible icon-rail sidebar app shell
- `SCDashboardBlock` — dashboard-01: stat cards, chart, recent sales

## Docs

- [Design docs & architecture](docs/README.md) — principles, the token system, variant conventions, previews, roadmap, registry/CLI plan
- [Contributing](CONTRIBUTING.md) — the component checklist
- Legacy v1 lives in `Swiftcn Playground.swiftpm` (the original `Custom*` components, unchanged)

## License

Distributed under the [MIT license](LICENSE).
