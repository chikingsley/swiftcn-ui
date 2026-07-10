import SwiftUI

public extension Theme {
    /// The default swiftcn theme — a direct port of shadcn/ui's default
    /// (zinc/neutral) theme. Light and dark values live in each token via
    /// `Color(light:dark:)`.
    static let `default` = Theme(
        background:            Color(light: .white,    dark: .zinc950),
        foreground:            Color(light: .zinc950,  dark: .zinc50),
        card:                  Color(light: .white,    dark: .zinc900),
        cardForeground:        Color(light: .zinc950,  dark: .zinc50),
        popover:               Color(light: .white,    dark: .zinc900),
        popoverForeground:     Color(light: .zinc950,  dark: .zinc50),
        primary:               Color(light: .zinc900,  dark: .zinc50),
        primaryForeground:     Color(light: .zinc50,   dark: .zinc900),
        secondary:             Color(light: .zinc100,  dark: .zinc800),
        secondaryForeground:   Color(light: .zinc900,  dark: .zinc50),
        muted:                 Color(light: .zinc100,  dark: .zinc800),
        mutedForeground:       Color(light: .zinc500,  dark: .zinc400),
        accent:                Color(light: .zinc100,  dark: .zinc800),
        accentForeground:      Color(light: .zinc900,  dark: .zinc50),
        destructive:           Color(light: .red600,   dark: .red700),
        destructiveForeground: Color(light: .white,    dark: .white),
        border:                Color(light: .zinc200,  dark: .zinc800),
        input:                 Color(light: .zinc200,  dark: .zinc800),
        ring:                  Color(light: .zinc400,  dark: .zinc500),
        // Chart series colors, ported from shadcn's default chart theme.
        chart1:                Color(light: Color(hex: 0xE8734A), dark: Color(hex: 0x2662D9)),
        chart2:                Color(light: Color(hex: 0x2A9D90), dark: Color(hex: 0x2EB88A)),
        chart3:                Color(light: Color(hex: 0x274754), dark: Color(hex: 0xE88C30)),
        chart4:                Color(light: Color(hex: 0xE8C468), dark: Color(hex: 0xAF57DB)),
        chart5:                Color(light: Color(hex: 0xF4A462), dark: Color(hex: 0xE23670)),
        sidebar:               Color(light: .zinc50,   dark: .zinc900),
        sidebarForeground:     Color(light: .zinc950,  dark: .zinc50),
        sidebarPrimary:        Color(light: .zinc900,  dark: .zinc50),
        sidebarPrimaryForeground: Color(light: .zinc50, dark: .zinc900),
        sidebarAccent:         Color(light: .zinc200,  dark: .zinc800),
        sidebarAccentForeground: Color(light: .zinc900, dark: .zinc50),
        sidebarBorder:         Color(light: .zinc200,  dark: .zinc800),
        sidebarRing:           Color(light: .zinc400,  dark: .zinc500)
    )
}
