// ============================================================
// Kbd.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A tiny keycap chip for displaying keyboard shortcuts — the swiftcn port
/// of shadcn/ui's Kbd.
///
///     SCKbd("⌘")
///     SCKbd("Ctrl+B")
public struct SCKbd: View {
    @Environment(\.theme) private var theme

    var key: String

    public init(_ key: String) {
        self.key = key
    }

    public var body: some View {
        Text(key)
            .font(.caption2.weight(.medium).monospaced())
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .foregroundStyle(theme.mutedForeground)
            .background(theme.muted, in: shape)
            .overlay { shape.strokeBorder(theme.border) }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(min(theme.radius - 4, 6), 4), style: .continuous)
    }
}

// MARK: - Subcomponents

/// A row of keycaps read as one shortcut.
///
///     SCKbdGroup(["⌘", "⇧", "P"])
public struct SCKbdGroup: View {
    var keys: [String]

    public init(_ keys: [String]) {
        self.keys = keys
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(keys.indices, id: \.self) { index in
                SCKbd(keys[index])
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#Preview("Kbd") {
    SCPreview {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                SCKbd("⌘")
                SCKbd("⇧")
                SCKbd("P")
            }
            SCKbd("Ctrl+B")
            SCKbdGroup(["⌥", "Space"])
        }
    }
}
