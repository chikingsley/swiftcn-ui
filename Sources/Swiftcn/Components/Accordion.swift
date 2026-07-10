// ============================================================
// Accordion.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCAccordionType: Sendable {
    /// Only one item may be open at a time; opening an item closes the rest.
    /// `collapsible` allows tapping the open item to close it.
    case single(collapsible: Bool)
    /// Any number of items may be open simultaneously.
    case multiple

    /// `.single(collapsible: true)` — the common case.
    public static var single: SCAccordionType { .single(collapsible: true) }
}

// MARK: - State plumbing (internal)

struct SCAccordionState {
    var expanded: Set<String> = []
    var toggle: (String) -> Void = { _ in }
}

private struct SCAccordionStateKey: EnvironmentKey {
    static let defaultValue = SCAccordionState()
}

extension EnvironmentValues {
    var scAccordionState: SCAccordionState {
        get { self[SCAccordionStateKey.self] }
        set { self[SCAccordionStateKey.self] = newValue }
    }
}

// MARK: - Component

/// A vertically stacked set of interactive headings that each reveal a
/// section of content.
///
///     SCAccordion {
///         SCAccordionItem("Is it accessible?") {
///             Text("Yes. It uses native buttons and traits.")
///         }
///         SCAccordionItem("Is it styled?", content: "Yes — theme tokens only.")
///     }
///
///     SCAccordion(type: .multiple) { … }
public struct SCAccordion<Content: View>: View {
    @State private var expanded: Set<String> = []

    var type: SCAccordionType
    @ViewBuilder var content: Content

    /// - Parameters:
    ///   - type: `.single` (default, one open item; tap again to close) or
    ///     `.multiple`.
    ///   - content: The `SCAccordionItem`s, in display order.
    public init(
        type: SCAccordionType = .single,
        @ViewBuilder content: () -> Content
    ) {
        self.type = type
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .environment(\.scAccordionState, SCAccordionState(expanded: expanded, toggle: toggle))
    }

    private func toggle(_ id: String) {
        withAnimation(.snappy(duration: 0.25)) {
            switch type {
            case .single(let collapsible):
                if expanded.contains(id) {
                    if collapsible { expanded.remove(id) }
                } else {
                    expanded = [id]
                }
            case .multiple:
                if expanded.contains(id) {
                    expanded.remove(id)
                } else {
                    expanded.insert(id)
                }
            }
        }
    }
}

// MARK: - Item

/// One heading plus its collapsible content inside an `SCAccordion`.
///
/// The item's identity defaults to its title; pass `id:` explicitly when two
/// items share a title. Content inherits `.subheadline` and the theme's
/// muted foreground as overridable defaults.
public struct SCAccordionItem<ItemContent: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAccordionState) private var accordion

    var title: String
    var id: String
    @ViewBuilder var content: ItemContent

    /// - Parameters:
    ///   - title: The always-visible heading.
    ///   - id: Stable identity within the accordion; defaults to `title`.
    ///   - content: Revealed while the item is expanded.
    public init(
        _ title: String,
        id: String? = nil,
        @ViewBuilder content: () -> ItemContent
    ) {
        self.title = title
        self.id = id ?? title
        self.content = content()
    }

    private var isExpanded: Bool { accordion.expanded.contains(id) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                accordion.toggle(id)
            } label: {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.foreground)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(theme.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(Text(isExpanded ? "Expanded" : "Collapsed"))

            VStack(alignment: .leading, spacing: 0) {
                if isExpanded {
                    content
                        .font(.subheadline)
                        .foregroundStyle(theme.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 14)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .clipped()

            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
        }
    }
}

public extension SCAccordionItem where ItemContent == Text {
    /// Convenience for plain-text content.
    ///
    ///     SCAccordionItem("Is it styled?", content: "Yes — theme tokens only.")
    init(_ title: String, id: String? = nil, content: String) {
        self.init(title, id: id) { Text(content) }
    }
}

// MARK: - Previews

#Preview("Accordion · single") {
    SCPreview {
        SCAccordion {
            SCAccordionItem(
                "Is it accessible?",
                content: "Yes. It uses native buttons, so focus and traits come for free."
            )
            SCAccordionItem(
                "Is it styled?",
                content: "Yes. It comes with default styles that match the other components' aesthetic."
            )
            SCAccordionItem(
                "Is it animated?",
                content: "Yes. It's animated by default with a snappy spring."
            )
        }
    }
}

#Preview("Accordion · multiple") {
    SCPreview {
        SCAccordion(type: .multiple) {
            SCAccordionItem("Shipping", content: "Free worldwide shipping on all orders.")
            SCAccordionItem("Returns", content: "Free returns within 30 days of purchase.")
            SCAccordionItem("Support") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reach us any time:")
                    Text("support@example.com")
                        .fontWeight(.medium)
                }
            }
        }
    }
}
