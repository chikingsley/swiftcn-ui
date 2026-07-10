// ============================================================
// ButtonGroup.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCButtonGroupVariant: CaseIterable, Sendable {
    case outline, secondary
}

public enum SCButtonGroupSize: CaseIterable, Sendable {
    case `default`, sm
}

// MARK: - Item

/// One segment of an `SCButtonGroup`: a text and/or icon label plus an action.
public struct SCButtonGroupItem: Identifiable {
    public let id: UUID
    let label: String?
    let systemImage: String?
    let action: () -> Void

    public init(label: String, action: @escaping () -> Void = {}) {
        self.id = UUID()
        self.label = label
        self.systemImage = nil
        self.action = action
    }

    public init(systemImage: String, action: @escaping () -> Void = {}) {
        self.id = UUID()
        self.label = nil
        self.systemImage = systemImage
        self.action = action
    }

    public init(label: String, systemImage: String, action: @escaping () -> Void = {}) {
        self.id = UUID()
        self.label = label
        self.systemImage = systemImage
        self.action = action
    }
}

// MARK: - Component

/// A row of attached buttons sharing one container — shadcn's Button Group.
/// Segments are divided by 1pt border lines and clipped to a single
/// rounded-rectangle shape.
///
///     SCButtonGroup(items: [
///         .init(label: "Copy") { copy() },
///         .init(label: "Paste") { paste() },
///         .init(systemImage: "ellipsis") { showMenu() },
///     ])
///     SCButtonGroup(variant: .secondary, size: .sm, items: [
///         .init(systemImage: "minus") { decrement() },
///         .init(systemImage: "plus") { increment() },
///     ])
public struct SCButtonGroup: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var variant: SCButtonGroupVariant
    var size: SCButtonGroupSize
    let items: [SCButtonGroupItem]

    public init(
        variant: SCButtonGroupVariant = .outline,
        size: SCButtonGroupSize = .default,
        items: [SCButtonGroupItem]
    ) {
        self.variant = variant
        self.size = size
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                if item.id != items.first?.id {
                    Rectangle()
                        .fill(theme.border)
                        .frame(width: 1)
                }
                Button(action: item.action) {
                    HStack(spacing: 6) {
                        if let systemImage = item.systemImage {
                            Image(systemName: systemImage)
                        }
                        if let label = item.label {
                            Text(label)
                        }
                    }
                }
                .buttonStyle(SCButtonGroupCellStyle(variant: variant, size: size))
            }
        }
        .frame(height: height)
        .fixedSize(horizontal: true, vertical: false)
        .clipShape(shape)
        .overlay {
            if variant == .outline {
                shape.strokeBorder(theme.border, lineWidth: 1)
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private var height: CGFloat {
        switch size {
        case .default: 40
        case .sm:      36
        }
    }
}

// MARK: - Inner button style

/// Draws one segment and its pressed feedback, mirroring `SCButtonStyle`'s
/// outline/secondary looks.
private struct SCButtonGroupCellStyle: ButtonStyle {
    @Environment(\.theme) private var theme

    var variant: SCButtonGroupVariant
    var size: SCButtonGroupSize

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .lineLimit(1)
            .padding(.horizontal, hPadding)
            .frame(minWidth: minWidth, maxHeight: .infinity)
            .background(background(pressed: configuration.isPressed))
            .foregroundStyle(foreground)
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func background(pressed: Bool) -> Color {
        switch variant {
        case .outline:   pressed ? theme.accent : theme.background
        case .secondary: pressed ? theme.secondary.opacity(0.7) : theme.secondary
        }
    }

    private var foreground: Color {
        switch variant {
        case .outline:   theme.foreground
        case .secondary: theme.secondaryForeground
        }
    }

    private var font: Font {
        switch size {
        case .sm: .footnote.weight(.medium)
        default:  .subheadline.weight(.medium)
        }
    }

    private var hPadding: CGFloat {
        switch size {
        case .default: 16
        case .sm:      12
        }
    }

    private var minWidth: CGFloat {
        switch size {
        case .default: 40
        case .sm:      36
        }
    }
}

// MARK: - Previews

#Preview("ButtonGroup") {
    SCPreview {
        VStack(spacing: 16) {
            SCButtonGroup(items: [
                .init(label: "Copy"),
                .init(label: "Paste"),
                .init(label: "Cut"),
            ])
            SCButtonGroup(variant: .secondary, items: [
                .init(label: "Archive", systemImage: "archivebox"),
                .init(systemImage: "trash"),
            ])
        }
    }
}

#Preview("ButtonGroup · sizes & states") {
    @Previewable @State var count = 0
    SCPreview {
        VStack(spacing: 16) {
            SCButtonGroup(size: .sm, items: [
                .init(systemImage: "minus") { count -= 1 },
                .init(systemImage: "plus") { count += 1 },
            ])
            Text("Count: \(count)")
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
            SCButtonGroup(items: [
                .init(label: "Save"),
                .init(systemImage: "chevron.down"),
            ])
            .disabled(true)
        }
    }
}
