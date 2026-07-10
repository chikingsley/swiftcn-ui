// ============================================================
// Resizable.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A two-pane split view with a draggable divider — the swiftcn port of
/// shadcn/ui's Resizable. The divider is a hairline with a centered grip
/// inside an invisible 11pt drag strip; drag to resize (clamped to `range`),
/// double-tap the handle to reset to the initial fraction. VoiceOver users
/// can adjust the split with the standard increment/decrement gestures.
///
///     SCResizableSplit(fraction: 0.3, range: 0.2...0.6) {
///         SidebarPane()
///     } second: {
///         SCResizableSplit(.vertical) {
///             DetailPane()
///         } second: {
///             ConsolePane()
///         }
///     }
public struct SCResizableSplit<First: View, Second: View>: View {
    @Environment(\.theme) private var theme

    var axis: Axis
    var initialFraction: CGFloat
    var range: ClosedRange<CGFloat>
    var first: First
    var second: Second

    @State private var fraction: CGFloat
    /// The fraction captured when a drag began; non-nil while dragging.
    @State private var dragBase: CGFloat?

    private let handleThickness: CGFloat = 1
    private let dragStripThickness: CGFloat = 11

    /// - Parameters:
    ///   - axis: `.horizontal` splits side by side, `.vertical` stacks the
    ///     panes (the fraction then applies to height).
    ///   - initial: The first pane's initial share of the available length.
    ///   - range: The fraction is clamped to this range while resizing.
    ///   - first: The leading (or top) pane.
    ///   - second: The trailing (or bottom) pane.
    public init(
        _ axis: Axis = .horizontal,
        fraction initial: CGFloat = 0.5,
        range: ClosedRange<CGFloat> = 0.2...0.8,
        @ViewBuilder first: () -> First,
        @ViewBuilder second: () -> Second
    ) {
        self.axis = axis
        self.range = range
        let clamped = min(max(initial, range.lowerBound), range.upperBound)
        self.initialFraction = clamped
        self.first = first()
        self.second = second()
        self._fraction = State(initialValue: clamped)
    }

    public var body: some View {
        GeometryReader { proxy in
            let total = axis == .horizontal ? proxy.size.width : proxy.size.height
            let available = max(0, total - handleThickness)
            let stack = axis == .horizontal
                ? AnyLayout(HStackLayout(spacing: 0))
                : AnyLayout(VStackLayout(spacing: 0))
            stack {
                pane(first, length: available * fraction)
                handle(available: available)
                    .zIndex(1)
                pane(second, length: nil)
            }
        }
    }

    // MARK: Panes

    private func pane(_ content: some View, length: CGFloat?) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(
                width: axis == .horizontal ? length : nil,
                height: axis == .vertical ? length : nil
            )
            .clipped()
    }

    // MARK: Handle

    private func handle(available: CGFloat) -> some View {
        Rectangle()
            .fill(theme.border)
            .frame(
                width: axis == .horizontal ? handleThickness : nil,
                height: axis == .vertical ? handleThickness : nil
            )
            .overlay { grip }
            .overlay { dragStrip(available: available) }
    }

    /// The visible 3×24 grip capsule, centered on the divider.
    private var grip: some View {
        Capsule()
            .fill(dragBase == nil ? theme.border : theme.ring)
            .frame(
                width: axis == .horizontal ? 3 : 24,
                height: axis == .horizontal ? 24 : 3
            )
    }

    /// Invisible 11pt-wide strip that carries the drag gesture, double-tap
    /// reset, resize cursor (macOS), and accessibility adjustments.
    private func dragStrip(available: CGFloat) -> some View {
        Color.clear
            .frame(
                width: axis == .horizontal ? dragStripThickness : nil,
                height: axis == .vertical ? dragStripThickness : nil
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    fraction = initialFraction
                }
            }
            .gesture(dragGesture(available: available))
            .resizeCursor(axis)
            .accessibilityElement()
            .accessibilityLabel("Resize split")
            .accessibilityValue("\(Int((fraction * 100).rounded())) percent")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: fraction = clamp(fraction + 0.05)
                case .decrement: fraction = clamp(fraction - 0.05)
                @unknown default: break
                }
            }
    }

    private func dragGesture(available: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let base = dragBase ?? fraction
                if dragBase == nil { dragBase = fraction }
                guard available > 0 else { return }
                let translation = axis == .horizontal
                    ? value.translation.width
                    : value.translation.height
                fraction = clamp(base + translation / available)
            }
            .onEnded { _ in
                dragBase = nil
            }
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

// MARK: - Helpers

private extension View {
    /// Shows a resize cursor while hovering the drag strip (macOS only;
    /// a no-op elsewhere).
    @ViewBuilder
    func resizeCursor(_ axis: Axis) -> some View {
        #if os(macOS)
        onHover { hovering in
            if hovering {
                (axis == .horizontal ? NSCursor.resizeLeftRight : NSCursor.resizeUpDown).push()
            } else {
                NSCursor.pop()
            }
        }
        #else
        self
        #endif
    }
}

// MARK: - Previews

private struct PreviewPane: View {
    @Environment(\.theme) private var theme
    var label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
            .fill(theme.muted)
            .overlay {
                Text(label)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.foreground)
            }
            .padding(6)
    }
}

#Preview("Resizable") {
    SCPreview {
        SCResizableSplit {
            PreviewPane("One")
        } second: {
            PreviewPane("Two")
        }
        .frame(height: 220)
    }
}

#Preview("Resizable · nested") {
    SCPreview {
        SCResizableSplit(fraction: 0.35) {
            PreviewPane("One")
        } second: {
            SCResizableSplit(.vertical, fraction: 0.4) {
                PreviewPane("Two")
            } second: {
                PreviewPane("Three")
            }
        }
        .frame(height: 260)
    }
}
