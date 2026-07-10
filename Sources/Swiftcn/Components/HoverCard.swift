// ============================================================
// HoverCard.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Modifier

public extension View {
    /// Presents a rich preview card when the pointer hovers the view — the
    /// swiftcn port of shadcn/ui's HoverCard, for sighted users previewing
    /// content behind a link.
    ///
    /// Pointer platforms (macOS, iPadOS) open after `openDelay` seconds of
    /// hovering and close `closeDelay` seconds after the pointer leaves;
    /// moving the pointer onto the card keeps it open. On touch (iPhone) a
    /// long-press opens the card and tapping outside dismisses it. The card
    /// is a native popover, so anchoring, the arrow, and dismissal stay
    /// native; it is themed with `theme.popover` tokens, padded 16pt, and
    /// sized between 240 and 320pt wide.
    ///
    ///     Text("@swiftcn")
    ///         .scHoverCard {
    ///             VStack(alignment: .leading) {
    ///                 Text("@swiftcn").font(.subheadline.weight(.semibold))
    ///                 Text("shadcn/ui for SwiftUI.")
    ///             }
    ///         }
    func scHoverCard<Content: View>(
        openDelay: Double = 0.5,
        closeDelay: Double = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SCHoverCardModifier(
            openDelay: openDelay,
            closeDelay: closeDelay,
            cardContent: content
        ))
    }
}

// MARK: - Component

private struct SCHoverCardModifier<CardContent: View>: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var openDelay: Double
    var closeDelay: Double
    @ViewBuilder var cardContent: () -> CardContent

    @State private var isPresented = false
    @State private var openTask: Task<Void, Never>?
    @State private var closeTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                guard isEnabled else { return }
                if hovering {
                    scheduleOpen()
                } else {
                    scheduleClose()
                }
            }
            .scHoverCardTouchActivation {
                guard isEnabled else { return }
                openTask?.cancel()
                closeTask?.cancel()
                isPresented = true
            }
            .popover(isPresented: $isPresented, arrowEdge: .top) {
                card
            }
            .onDisappear {
                openTask?.cancel()
                closeTask?.cancel()
            }
    }

    private var card: some View {
        cardContent()
            .padding(16)
            .frame(minWidth: 240, maxWidth: 320, alignment: .leading)
            .foregroundStyle(theme.popoverForeground)
            .presentationBackground(theme.popover)
            .presentationCompactAdaptation(.popover)
            .onHover { hovering in
                // Keep the card open while the pointer is over it.
                if hovering {
                    closeTask?.cancel()
                } else {
                    scheduleClose()
                }
            }
    }

    // MARK: Scheduling

    private func scheduleOpen() {
        closeTask?.cancel()
        guard !isPresented else { return }
        openTask?.cancel()
        openTask = Task {
            try? await Task.sleep(for: .seconds(openDelay))
            guard !Task.isCancelled else { return }
            isPresented = true
        }
    }

    private func scheduleClose() {
        openTask?.cancel()
        guard isPresented else { return }
        closeTask?.cancel()
        closeTask = Task {
            try? await Task.sleep(for: .seconds(closeDelay))
            guard !Task.isCancelled else { return }
            isPresented = false
        }
    }
}

// MARK: - Platform helpers

private extension View {
    /// Touch activation: long-press opens the hover card on iPhone/iPad.
    @ViewBuilder
    func scHoverCardTouchActivation(perform action: @escaping () -> Void) -> some View {
        #if os(iOS)
        onLongPressGesture(minimumDuration: 0.35, perform: action)
        #else
        self
        #endif
    }
}

// MARK: - Previews

#Preview("HoverCard") {
    SCPreview {
        Text("@swiftcn")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Theme.default.primary)
            .underline()
            .scHoverCard {
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(Theme.default.muted)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("SC")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.default.mutedForeground)
                        }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("@swiftcn")
                            .font(.subheadline.weight(.semibold))
                        Text("shadcn/ui for SwiftUI — copy-paste components themed by design tokens.")
                            .font(.footnote)
                            .foregroundStyle(Theme.default.mutedForeground)
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("Joined July 2026")
                        }
                        .font(.caption)
                        .foregroundStyle(Theme.default.mutedForeground)
                        .padding(.top, 2)
                    }
                }
            }
    }
    .frame(height: 360)
}
