// ============================================================
// Collapsible.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// An interactive panel that expands and collapses.
///
/// Works controlled (pass an `isOpen` binding) or uncontrolled (omit it and
/// the component keeps its own state):
///
///     SCCollapsible {
///         Text("@peduarte starred 3 repositories")
///     } content: {
///         Text("@radix-ui/primitives")
///     }
///
///     SCCollapsible(isOpen: $showsDetails) { … } content: { … }
public struct SCCollapsible<Trigger: View, Content: View>: View {
    @Environment(\.theme) private var theme
    @State private var internalIsOpen = false

    private var externalIsOpen: Binding<Bool>?
    var showsChevron: Bool
    @ViewBuilder var trigger: Trigger
    @ViewBuilder var content: Content

    /// - Parameters:
    ///   - isOpen: Optional binding for controlled open state. Pass `nil`
    ///     (the default) to let the component manage its own state.
    ///   - showsChevron: Whether the trigger row shows a trailing
    ///     `chevron.up.chevron.down` indicator. Defaults to `true`.
    ///   - trigger: The always-visible, tappable row.
    ///   - content: Revealed while the panel is open.
    public init(
        isOpen: Binding<Bool>? = nil,
        showsChevron: Bool = true,
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> Content
    ) {
        self.externalIsOpen = isOpen
        self.showsChevron = showsChevron
        self.trigger = trigger()
        self.content = content()
    }

    private var isOpen: Bool {
        externalIsOpen?.wrappedValue ?? internalIsOpen
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if let externalIsOpen {
                    externalIsOpen.wrappedValue.toggle()
                } else {
                    internalIsOpen.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    trigger
                        .multilineTextAlignment(.leading)
                    if showsChevron {
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(theme.mutedForeground)
                            .accessibilityHidden(true)
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.foreground)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(Text(isOpen ? "Expanded" : "Collapsed"))

            VStack(alignment: .leading, spacing: 0) {
                if isOpen {
                    content
                        .font(.subheadline)
                        .foregroundStyle(theme.foreground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .clipped()
        }
        .animation(.snappy(duration: 0.25), value: isOpen)
    }
}

// MARK: - Previews

#Preview("Collapsible · controlled") {
    @Previewable @State var isOpen = true
    SCPreview {
        SCCollapsible(isOpen: $isOpen) {
            Text("@peduarte starred 3 repositories")
        } content: {
            VStack(alignment: .leading, spacing: 8) {
                Text("@radix-ui/primitives")
                Text("@radix-ui/colors")
                Text("@stitches/react")
            }
            .font(.footnote.monospaced())
        }
    }
}

#Preview("Collapsible · uncontrolled") {
    SCPreview {
        SCCollapsible {
            Text("Can I use this in my project?")
        } content: {
            Text("Yes. Free to use for personal and commercial projects.")
        }
    }
}

#Preview("Collapsible · no chevron") {
    SCPreview {
        SCCollapsible(showsChevron: false) {
            Text("Show details")
        } content: {
            Text("Details revealed without a chevron indicator.")
        }
    }
}
