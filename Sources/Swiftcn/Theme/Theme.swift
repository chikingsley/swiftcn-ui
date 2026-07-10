import SwiftUI

/// The design-token set for swiftcn — the SwiftUI analog of shadcn/ui's CSS
/// variables. Inject it once at the root with `.theme(_:)`; every component
/// reads it via `@Environment(\.theme)`.
///
/// Tokens follow shadcn's background/foreground convention: `x` is a surface
/// color, `xForeground` is the color of content placed on that surface.
/// Dark mode needs no second theme — token colors are adaptive
/// (see `Color(light:dark:)`).
public struct Theme: Sendable {
    // MARK: Base
    public var background: Color
    public var foreground: Color

    // MARK: Surfaces
    public var card: Color
    public var cardForeground: Color
    public var popover: Color
    public var popoverForeground: Color

    // MARK: Semantic pairs
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

    // MARK: Chrome
    public var border: Color
    public var input: Color
    public var ring: Color

    // MARK: Charts
    public var chart1: Color
    public var chart2: Color
    public var chart3: Color
    public var chart4: Color
    public var chart5: Color

    // MARK: Sidebar (independently themeable, mirroring shadcn's --sidebar-* family)
    public var sidebar: Color
    public var sidebarForeground: Color
    public var sidebarPrimary: Color
    public var sidebarPrimaryForeground: Color
    public var sidebarAccent: Color
    public var sidebarAccentForeground: Color
    public var sidebarBorder: Color
    public var sidebarRing: Color

    // MARK: Shape & type
    /// Base corner radius in points (shadcn `--radius: 0.625rem` ≙ 10pt).
    public var radius: CGFloat
    public var fontDesign: Font.Design

    public init(
        background: Color,
        foreground: Color,
        card: Color,
        cardForeground: Color,
        popover: Color,
        popoverForeground: Color,
        primary: Color,
        primaryForeground: Color,
        secondary: Color,
        secondaryForeground: Color,
        muted: Color,
        mutedForeground: Color,
        accent: Color,
        accentForeground: Color,
        destructive: Color,
        destructiveForeground: Color,
        border: Color,
        input: Color,
        ring: Color,
        chart1: Color,
        chart2: Color,
        chart3: Color,
        chart4: Color,
        chart5: Color,
        sidebar: Color,
        sidebarForeground: Color,
        sidebarPrimary: Color,
        sidebarPrimaryForeground: Color,
        sidebarAccent: Color,
        sidebarAccentForeground: Color,
        sidebarBorder: Color,
        sidebarRing: Color,
        radius: CGFloat = 10,
        fontDesign: Font.Design = .default
    ) {
        self.background = background
        self.foreground = foreground
        self.card = card
        self.cardForeground = cardForeground
        self.popover = popover
        self.popoverForeground = popoverForeground
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.secondary = secondary
        self.secondaryForeground = secondaryForeground
        self.muted = muted
        self.mutedForeground = mutedForeground
        self.accent = accent
        self.accentForeground = accentForeground
        self.destructive = destructive
        self.destructiveForeground = destructiveForeground
        self.border = border
        self.input = input
        self.ring = ring
        self.chart1 = chart1
        self.chart2 = chart2
        self.chart3 = chart3
        self.chart4 = chart4
        self.chart5 = chart5
        self.sidebar = sidebar
        self.sidebarForeground = sidebarForeground
        self.sidebarPrimary = sidebarPrimary
        self.sidebarPrimaryForeground = sidebarPrimaryForeground
        self.sidebarAccent = sidebarAccent
        self.sidebarAccentForeground = sidebarAccentForeground
        self.sidebarBorder = sidebarBorder
        self.sidebarRing = sidebarRing
        self.radius = radius
        self.fontDesign = fontDesign
    }
}

// MARK: - Environment

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
    /// Applies a swiftcn theme to this view hierarchy — the equivalent of
    /// setting shadcn's CSS variables on a root element. Because the
    /// environment cascades, themes can be overridden per subtree.
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
            .fontDesign(theme.fontDesign)
    }
}
