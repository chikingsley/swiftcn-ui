// ============================================================
// Tooltip.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Modifier

public extension View {
    /// Shows a small text bubble beside the view — the swiftcn port of
    /// shadcn/ui's Tooltip.
    ///
    /// On pointer platforms (macOS, iPadOS) the bubble appears after
    /// hovering for 0.4s and hides on exit; macOS additionally attaches
    /// the system `.help(_:)` tooltip for VoiceOver and platform parity.
    /// On touch, a 0.35s long-press shows the bubble for 2 seconds.
    ///
    /// > Note: The bubble renders in an `overlay` on the anchor view, so a
    /// > tight or clipping parent (e.g. a small `clipShape`d container or a
    /// > `ScrollView` edge) can clip it. That matches shadcn parity for v1;
    /// > present content that must escape bounds with `scPopover` instead.
    ///
    ///     Button("Add to library") {}
    ///         .buttonStyle(.sc(.outline))
    ///         .scTooltip("Add to library")
    ///
    ///     Image(systemName: "info.circle")
    ///         .scTooltip("More information", edge: .trailing)
    func scTooltip(_ text: String, edge: Edge = .top) -> some View {
        modifier(SCTooltipModifier(text: text, edge: edge))
    }
}

// MARK: - Component

private struct SCTooltipModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var text: String
    var edge: Edge

    @State private var isVisible = false
    @State private var showTask: Task<Void, Never>?
    @State private var hideTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isVisible {
                    bubble
                        .allowsHitTesting(false)
                        .zIndex(1)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .onHover { hovering in
                guard isEnabled else { return }
                if hovering {
                    hideTask?.cancel()
                    showTask?.cancel()
                    showTask = Task {
                        try? await Task.sleep(for: .seconds(0.4))
                        guard !Task.isCancelled else { return }
                        isVisible = true
                    }
                } else {
                    showTask?.cancel()
                    isVisible = false
                }
            }
            .scTooltipTouchActivation {
                guard isEnabled else { return }
                showTask?.cancel()
                hideTask?.cancel()
                isVisible = true
                hideTask = Task {
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    isVisible = false
                }
            }
            .scTooltipSystemHelp(text)
            .onDisappear {
                showTask?.cancel()
                hideTask?.cancel()
            }
            .animation(.snappy(duration: 0.18), value: isVisible)
    }

    // MARK: Bubble

    /// The bubble, shifted 8pt beyond the anchor's `edge` via an alignment
    /// guide (size-independent, so no hardcoded offsets).
    @ViewBuilder
    private var bubble: some View {
        switch edge {
        case .top:      bubbleLabel.alignmentGuide(.top) { $0[.bottom] + 8 }
        case .bottom:   bubbleLabel.alignmentGuide(.bottom) { $0[.top] - 8 }
        case .leading:  bubbleLabel.alignmentGuide(.leading) { $0[.trailing] + 8 }
        case .trailing: bubbleLabel.alignmentGuide(.trailing) { $0[.leading] - 8 }
        }
    }

    private var bubbleLabel: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(theme.primaryForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(theme.primary, in: shape)
            .fixedSize()
            .shadow(color: theme.foreground.opacity(0.08), radius: 4, y: 2)
            .accessibilityHidden(true)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 4), style: .continuous)
    }

    private var alignment: Alignment {
        switch edge {
        case .top:      .top
        case .bottom:   .bottom
        case .leading:  .leading
        case .trailing: .trailing
        }
    }
}

// MARK: - Platform helpers

private extension View {
    /// iOS touch activation: long-press shows the tooltip.
    @ViewBuilder
    func scTooltipTouchActivation(perform action: @escaping () -> Void) -> some View {
        #if os(iOS)
        onLongPressGesture(minimumDuration: 0.35, perform: action)
        #else
        self
        #endif
    }

    /// macOS system tooltip for VoiceOver and platform parity.
    @ViewBuilder
    func scTooltipSystemHelp(_ text: String) -> some View {
        #if os(macOS)
        help(text)
        #else
        self
        #endif
    }
}

// MARK: - Previews

#Preview("Tooltip") {
    SCPreview {
        Button("Hover or long-press") {}
            .buttonStyle(.sc(.outline))
            .scTooltip("Add to library")
            .padding(.vertical, 40)
    }
}

#Preview("Tooltip · edges") {
    SCPreview {
        HStack(spacing: 24) {
            Button("Top") {}.buttonStyle(.sc(.outline, size: .sm))
                .scTooltip("Tooltip on top")
            Button("Bottom") {}.buttonStyle(.sc(.outline, size: .sm))
                .scTooltip("Tooltip on bottom", edge: .bottom)
            Button("Trailing") {}.buttonStyle(.sc(.outline, size: .sm))
                .scTooltip("Trailing", edge: .trailing)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
    }
}
