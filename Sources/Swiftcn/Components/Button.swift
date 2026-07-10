// ============================================================
// Button.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCButtonVariant: CaseIterable, Sendable {
    case `default`, destructive, outline, secondary, ghost, link
}

public enum SCButtonSize: CaseIterable, Sendable {
    case `default`, sm, lg, icon
}

// MARK: - Style

/// swiftcn's button appearance for native SwiftUI `Button`s — the cva
/// `buttonVariants` of this library. Behavior and accessibility stay native;
/// this supplies the style layer only.
///
///     Button("Continue") { … }.buttonStyle(.sc())
///     Button("Delete") { … }.buttonStyle(.sc(.destructive))
///     Button("Cancel") { … }.buttonStyle(.sc(.outline, size: .sm))
public struct SCButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var variant: SCButtonVariant
    var size: SCButtonSize

    public init(variant: SCButtonVariant = .default, size: SCButtonSize = .default) {
        self.variant = variant
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .lineLimit(1)
            .padding(padding)
            .frame(minWidth: size == .icon ? height : nil, minHeight: height)
            .background(background(pressed: configuration.isPressed), in: shape)
            .overlay {
                if variant == .outline {
                    shape.strokeBorder(theme.border)
                }
            }
            .foregroundStyle(foreground)
            .underline(variant == .link && configuration.isPressed)
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private func background(pressed: Bool) -> Color {
        switch variant {
        case .default:     pressed ? theme.primary.opacity(0.85) : theme.primary
        case .destructive: pressed ? theme.destructive.opacity(0.85) : theme.destructive
        case .secondary:   pressed ? theme.secondary.opacity(0.7) : theme.secondary
        case .outline:     pressed ? theme.accent : theme.background
        case .ghost:       pressed ? theme.accent : .clear
        case .link:        .clear
        }
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

    private var font: Font {
        switch size {
        case .sm: .footnote.weight(.medium)
        default:  .subheadline.weight(.medium)
        }
    }

    private var padding: EdgeInsets {
        switch size {
        case .default: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        case .sm:      EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        case .lg:      EdgeInsets(top: 10, leading: 32, bottom: 10, trailing: 32)
        case .icon:    EdgeInsets()
        }
    }

    private var height: CGFloat {
        switch size {
        case .default: 40
        case .sm:      36
        case .lg:      44
        case .icon:    40
        }
    }
}

public extension ButtonStyle where Self == SCButtonStyle {
    static func sc(_ variant: SCButtonVariant = .default, size: SCButtonSize = .default) -> SCButtonStyle {
        SCButtonStyle(variant: variant, size: size)
    }
}

// MARK: - Previews

#Preview("Button · variants") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Default") {}.buttonStyle(.sc())
            Button("Destructive") {}.buttonStyle(.sc(.destructive))
            Button("Outline") {}.buttonStyle(.sc(.outline))
            Button("Secondary") {}.buttonStyle(.sc(.secondary))
            Button("Ghost") {}.buttonStyle(.sc(.ghost))
            Button("Link") {}.buttonStyle(.sc(.link))
        }
    }
}

#Preview("Button · sizes") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Small") {}.buttonStyle(.sc(.outline, size: .sm))
            Button("Default") {}.buttonStyle(.sc(.outline))
            Button("Large") {}.buttonStyle(.sc(.outline, size: .lg))
            Button {} label: { Image(systemName: "chevron.right") }
                .buttonStyle(.sc(.outline, size: .icon))
        }
    }
}

#Preview("Button · states") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Disabled") {}.buttonStyle(.sc()).disabled(true)
            Button {} label: {
                Label("Sign in with Email", systemImage: "envelope")
            }
            .buttonStyle(.sc())
        }
    }
}
