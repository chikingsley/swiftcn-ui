# Architecture: how swiftcn-ui 2.0 fits together

This is the technical blueprint. It translates shadcn/ui's architecture — CSS variables, cva variants, Radix primitives, copy-paste files — into their idiomatic SwiftUI equivalents.

The four pillars:

| shadcn/ui concept | swiftcn equivalent |
| --- | --- |
| CSS variables (`--primary`, `--radius`, …) | `Theme` struct injected via SwiftUI `Environment` |
| cva variants (`variant`, `size` props) | Swift enums + SwiftUI *Style* protocols (`ButtonStyle`, `ToggleStyle`, …) |
| Radix primitives styled with Tailwind | Native SwiftUI primitives styled with our Style types |
| Copy-paste `components/ui/*.tsx` files | Self-contained `.swift` files, one component per file |

---

## 1. Theming: `Theme` in the Environment

SwiftUI's `Environment` **is** the CSS cascade. A value set high in the view tree flows down to every descendant and can be overridden for any subtree — exactly how shadcn's CSS variables work. So the theme is a plain struct in the environment:

```swift
// Theme/Theme.swift
import SwiftUI

public struct Theme: Sendable {
    // Token pairs follow shadcn's background/foreground convention:
    // `x` is a surface color, `xForeground` is the color of content on it.
    public var background: Color
    public var foreground: Color

    public var card: Color
    public var cardForeground: Color

    public var popover: Color
    public var popoverForeground: Color

    public var primary: Color
    public var primaryForeground: Color

    public var secondary: Color
    public var secondaryForeground: Color

    public var muted: Color
    public var mutedForeground: Color

    public var accent: Color
    public var accentForeground: Color

    public var destructive: Color
    public var destructiveForeground: Color

    public var border: Color
    public var input: Color
    public var ring: Color

    // Non-color tokens
    public var radius: CGFloat

    // Added when the corresponding components land (shadcn defines these
    // as separate token families so they're independently themeable):
    // - chart1…chart5            (Chart)
    // - sidebar, sidebarForeground, sidebarPrimary, sidebarPrimaryForeground,
    //   sidebarAccent, sidebarAccentForeground, sidebarBorder, sidebarRing  (Sidebar)

    // Font tokens (optional but powerful — SwiftUI Dynamic Type still applies)
    public var fontDesign: Font.Design = .default
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.default
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {
    /// The swiftcn equivalent of wrapping your app in a themed root element.
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
```

### Dark mode for free: adaptive `Color`

shadcn defines two blocks of CSS variables (`:root` and `.dark`). In SwiftUI we don't need two themes — each token is a *single* `Color` that resolves per color scheme, using a dynamic provider:

```swift
// Theme/Color+Adaptive.swift
import SwiftUI

public extension Color {
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark) : NSColor(light)
        })
        #endif
    }
}
```

Then the default theme is a direct port of shadcn's `zinc` palette:

```swift
// Theme/Theme+Default.swift
public extension Theme {
    static let `default` = Theme(
        background:            Color(light: .white,          dark: .zinc950),
        foreground:            Color(light: .zinc950,        dark: .zinc50),
        card:                  Color(light: .white,          dark: .zinc950),
        cardForeground:        Color(light: .zinc950,        dark: .zinc50),
        popover:               Color(light: .white,          dark: .zinc950),
        popoverForeground:     Color(light: .zinc950,        dark: .zinc50),
        primary:               Color(light: .zinc900,        dark: .zinc50),
        primaryForeground:     Color(light: .zinc50,         dark: .zinc900),
        secondary:             Color(light: .zinc100,        dark: .zinc800),
        secondaryForeground:   Color(light: .zinc900,        dark: .zinc50),
        muted:                 Color(light: .zinc100,        dark: .zinc800),
        mutedForeground:       Color(light: .zinc500,        dark: .zinc400),
        accent:                Color(light: .zinc100,        dark: .zinc800),
        accentForeground:      Color(light: .zinc900,        dark: .zinc50),
        destructive:           Color(light: .red600,         dark: .red900),
        destructiveForeground: Color(light: .zinc50,         dark: .zinc50),
        border:                Color(light: .zinc200,        dark: .zinc800),
        input:                 Color(light: .zinc200,        dark: .zinc800),
        ring:                  Color(light: .zinc900,        dark: .zinc300),
        radius: 10
    )
}
```

(`.zinc950` etc. are static `Color` constants we define once in `Theme/Palette.swift` — a straight port of the Tailwind palette. That file is ~100 lines of hex constants and gives every component the same vocabulary shadcn has.)

**Why both Environment + adaptive colors?** Adaptive colors make dark mode automatic with zero plumbing. The Environment makes the theme *swappable* — a user can define `Theme.brand` and apply `.theme(.brand)` at the app root, or override `radius` for one screen. That's the "themes are a config file, not a rewrite" property shadcn has.

### Usage inside components

```swift
struct SCBadge: View {
    @Environment(\.theme) private var theme
    // ...
    var body: some View {
        Text(label)
            .foregroundStyle(theme.primaryForeground)
            .background(theme.primary, in: Capsule())
    }
}
```

No component ever reads `colorScheme` for colors again. (`colorScheme` checks remain valid for *structural* changes only, which is rare.)

---

## 2. Variants: enums + Style protocols (the cva of SwiftUI)

shadcn's Button:

```tsx
const buttonVariants = cva(base, {
  variants: {
    variant: { default, destructive, outline, secondary, ghost, link },
    size: { default, sm, lg, icon },
  },
})
```

The idiomatic SwiftUI translation is **not** a wrapper view — it's a `ButtonStyle`. SwiftUI already has the "unstyled primitive + pluggable style" architecture that shadcn builds on Radix to get. Native `Button` handles tap targets, accessibility, keyboard, focus; we supply appearance:

```swift
// Components/Button.swift
import SwiftUI

public enum SCButtonVariant { case `default`, destructive, outline, secondary, ghost, link }
public enum SCButtonSize { case `default`, sm, lg, icon }

public struct SCButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var variant: SCButtonVariant = .default
    var size: SCButtonSize = .default

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .padding(padding)
            .frame(minHeight: height)
            .background(background(pressed: configuration.isPressed), in: shape)
            .overlay { if variant == .outline { shape.strokeBorder(theme.border) } }
            .foregroundStyle(foreground)
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private func background(pressed: Bool) -> Color {
        let base: Color = switch variant {
        case .default:     theme.primary
        case .destructive: theme.destructive
        case .secondary:   theme.secondary
        case .outline, .ghost, .link: .clear
        }
        return pressed ? base.opacity(0.85) : base   // hover:bg-primary/90 equivalent
    }

    private var foreground: Color {
        switch variant {
        case .default:     theme.primaryForeground
        case .destructive: theme.destructiveForeground
        case .secondary:   theme.secondaryForeground
        case .outline, .ghost: theme.foreground
        case .link:        theme.primary
        }
    }

    private var padding: EdgeInsets {
        switch size {
        case .default: EdgeInsets(top: 8,  leading: 16, bottom: 8,  trailing: 16)
        case .sm:      EdgeInsets(top: 6,  leading: 12, bottom: 6,  trailing: 12)
        case .lg:      EdgeInsets(top: 10, leading: 32, bottom: 10, trailing: 32)
        case .icon:    EdgeInsets(top: 8,  leading: 8,  bottom: 8,  trailing: 8)
        }
    }

    private var height: CGFloat {
        switch size { case .default: 40; case .sm: 36; case .lg: 44; case .icon: 40 }
    }
}

public extension ButtonStyle where Self == SCButtonStyle {
    /// `Button("Delete") { … }.buttonStyle(.sc(.destructive))`
    static func sc(_ variant: SCButtonVariant = .default, size: SCButtonSize = .default) -> SCButtonStyle {
        SCButtonStyle(variant: variant, size: size)
    }
}
```

Call sites read like shadcn:

```swift
Button("Continue") { … }.buttonStyle(.sc())
Button("Delete") { … }.buttonStyle(.sc(.destructive))
Button("Cancel") { … }.buttonStyle(.sc(.outline, size: .sm))
Button { … } label: { Image(systemName: "chevron.right") }.buttonStyle(.sc(.ghost, size: .icon))
```

### Which Style protocol per component

Use the native primitive + Style protocol whenever one exists — that's the Radix layer we get for free:

| Component | Primitive kept | Style protocol |
| --- | --- | --- |
| Button | `Button` | `ButtonStyle` / `PrimitiveButtonStyle` |
| Switch (Toggle) | `Toggle` | `ToggleStyle` |
| Checkbox | `Toggle` | `ToggleStyle` (checkbox appearance) |
| Progress | `ProgressView` | `ProgressViewStyle` |
| Input / Textarea | `TextField` / `TextEditor` | `TextFieldStyle` + custom modifier |
| Label / Field row | `LabeledContent` | `LabeledContentStyle` |
| Accordion item | `DisclosureGroup` | `DisclosureGroupStyle` |
| Toggle group | `Picker` or custom | `PickerStyle` is closed — custom component |
| Menu / Dropdown | `Menu` | `MenuStyle` (limited) or custom popover |

Components with no SwiftUI primitive (Badge, Avatar, Card, Skeleton, Sidebar, Toast, Command…) are structs with `SC` prefix. **Naming rule:** `SC` prefix everywhere (`SCBadge`, `SCCard`) — unprefixed names like `Card` are fine until a user copy-pastes into an app that already has a `Card`, and `Button` would shadow SwiftUI's. Two characters buys zero collisions. The old `Custom*` names migrate to `SC*`.

---

## 3. Composition: `@ViewBuilder` slots, not string props

shadcn's Card is not `<Card title description content footer>` — it's compound components. Today's `CustomCard(title:description:content:footer:)` can only ever render text. The 2.0 pattern:

```swift
// Components/Card.swift
public struct SCCard<Content: View>: View {
    @Environment(\.theme) private var theme
    @ViewBuilder var content: Content

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.card, in: RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous).strokeBorder(theme.border))
    }
}

public struct SCCardHeader<Content: View>: View { /* VStack(alignment: .leading, spacing: 6) */ }
public struct SCCardTitle: View     { /* Text, .headline, theme.cardForeground */ }
public struct SCCardDescription: View { /* Text, .subheadline, theme.mutedForeground */ }
public struct SCCardContent<Content: View>: View { /* plain slot */ }
public struct SCCardFooter<Content: View>: View  { /* HStack slot */ }
```

```swift
SCCard {
    SCCardHeader {
        SCCardTitle("Accelerate UI")
        SCCardDescription("Enter a new development experience")
    }
    SCCardContent {
        // ANY view, not just a string
        SCInput("Email", text: $email)
    }
    SCCardFooter {
        Button("Deploy") { … }.buttonStyle(.sc())
    }
}
```

Rules of thumb:

- Any place a component currently takes a `String` for a *region*, it becomes a `@ViewBuilder` slot. Convenience `String` initializers can stay as sugar.
- Any place a component currently takes `backgroundColor:`/`foregroundColor:` params, those disappear — the theme owns color. Escape hatch = environment override (`.theme(…)` on a subtree), matching how you'd override a CSS variable.
- Avoid `AnyView` in public APIs (today's `CustomTabs` takes `[(String, AnyView)]`). Use generics + `@ViewBuilder`, or for tabs specifically, a result-builder API with a `.tag()`-style value.

---

## 4. Component file anatomy (the template)

Every component ships as **one self-contained file** — the copy-paste unit, same as a shadcn `.tsx` file. Only permitted dependency: the `Theme/` folder.

```swift
// ============================================================
// SCBadge.swift — swiftcn-ui
// Depends on: Theme.swift, Palette.swift
// ============================================================
import SwiftUI

// MARK: - Variants
public enum SCBadgeVariant { case `default`, secondary, destructive, outline }

// MARK: - Component
public struct SCBadge: View {
    @Environment(\.theme) private var theme
    let label: String
    var variant: SCBadgeVariant = .default

    public init(_ label: String, variant: SCBadgeVariant = .default) { … }

    public var body: some View { … }
}

// MARK: - Previews
#Preview("Badge") {
    HStack {
        SCBadge("Badge")
        SCBadge("Secondary", variant: .secondary)
        SCBadge("Destructive", variant: .destructive)
        SCBadge("Outline", variant: .outline)
    }
    .padding()
}
```

Checklist for every component file:

1. `// MARK:` sections: Variants → Component → Subcomponents → Style → Previews.
2. `public` API with doc comments (`///`) on the type and each initializer.
3. No raw colors, no `colorScheme` conditionals — theme tokens only.
4. A `#Preview` per meaningful state (variants, disabled, dark handled by canvas).
5. Accessibility pass: labels on icon-only controls, `accessibilityValue` on stateful ones, Dynamic Type survives (test at `.accessibility3`).
6. Works on iOS and iPadOS; macOS where feasible (guard with `#if os`).

**Platform floor: iOS 17.** Raising from 15.2 buys: `#Preview` macro + `@Previewable`, `Observation`, `ContentUnavailableView`, keyframe/phase animators, `containerRelativeFrame`, `.scrollPosition`, sensory feedback, and `NavigationSplitView` refinements (16+) that the Sidebar work needs. In 2026 an iOS 17 floor covers effectively the whole installed base.

---

## 5. Repo restructure

The Swift Playground stays — it's a great demo vehicle — but it becomes a *consumer* of the library rather than the source of truth:

```
swiftcn-ui/
├── Sources/
│   └── Swiftcn/
│       ├── Theme/
│       │   ├── Theme.swift            # tokens + EnvironmentKey
│       │   ├── Theme+Default.swift    # default (zinc) theme
│       │   ├── Palette.swift          # Tailwind color constants
│       │   └── Color+Adaptive.swift   # light/dark dynamic Color
│       ├── Components/                # one file per component
│       │   ├── Button.swift
│       │   ├── Badge.swift
│       │   └── …
│       └── Blocks/                    # composed screens (login, settings, dashboard)
├── Showcase/                          # Xcode app: the component gallery (see 03-previews.md)
├── Swiftcn Playground.swiftpm/        # kept as the zero-install entry point
├── registry.json                      # machine-readable component index (see 05-registry-cli.md)
├── docs/                              # these documents
└── Package.swift                      # SPM manifest (library product)
```

Distribution is **both/and**, mirroring where shadcn ended up:

- **Copy-paste** (the brand promise: "no package install, no bs") — every file under `Sources/Swiftcn/Components/` is self-contained modulo `Theme/`.
- **SPM package** for people who just want `import Swiftcn`.
- Later, a **CLI** (`swiftcn add button`) that copies files into your project — doc `05-registry-cli.md`.

---

## 6. Migration of the existing 13 components

| Today | Becomes | Change |
| --- | --- | --- |
| `CustomButton` | `SCButtonStyle` on native `Button` | rewrite as ButtonStyle + variants |
| `CustomBadge` | `SCBadge` | variants replace color params |
| `CustomCard` | `SCCard` + Header/Title/Description/Content/Footer | slots replace strings |
| `CustomInput` | `SCInput` | theme tokens; keep `InputConvertible` sugar |
| `CustomTextEditor` | `SCTextarea` | rename to shadcn vocabulary |
| `CustomAvatar` | `SCAvatar` | size presets (`.sm/.default/.lg`) replace w/h params |
| `CustomToggle` | `SCSwitchStyle: ToggleStyle` | style, not wrapper; rename → Switch |
| `CustomTabs` | `SCTabs` | kill `AnyView`; animated underline via `matchedGeometryEffect` |
| `CustomSlider` | `SCSliderStyle`/`SCSlider` | theme-tinted |
| `CustomProgress` | `SCProgressStyle: ProgressViewStyle` | style, not wrapper |
| `ShimmerButton` | `SCButtonStyle` variant or effects extra | move to an `Effects/` group |
| `DotPattern` | `SCDotPattern` (Canvas-based) | rewrite with `Canvas` — the ForEach grid is O(n²) views |
| `InputBoxModifier` | absorbed into `SCInput` | delete |

Note on `DotPattern`: the nested `ForEach` creates hundreds of `Circle` views; a single `Canvas` draw call renders the same pattern at a fraction of the cost and unlocks `MagicUI`-style animated backgrounds later.
