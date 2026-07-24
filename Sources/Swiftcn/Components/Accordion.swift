// ============================================================
// Accordion.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Selection

/// Whether an accordion permits one or multiple expanded items.
public enum SCAccordionType: Equatable, Sendable {
    /// Only one item may be open. Set `collapsible` to `false` when one item
    /// must always remain open after the first selection.
    case single(collapsible: Bool)
    /// Any number of items may be open simultaneously.
    case multiple

    /// The common single-item mode, which permits closing the open item.
    public static var single: SCAccordionType { .single(collapsible: true) }
}

// MARK: - State plumbing

struct SCAccordionState {
    var expanded: Set<String> = []
    var isDisabled = false
    var toggle: (String) -> Void = { _ in }
}

private struct SCAccordionStateKey: EnvironmentKey {
    static var defaultValue: SCAccordionState { SCAccordionState() }
}

extension EnvironmentValues {
    var scAccordionState: SCAccordionState {
        get { self[SCAccordionStateKey.self] }
        set { self[SCAccordionStateKey.self] = newValue }
    }
}

struct SCAccordionItemState {
    var id = ""
    var isDisabled = false
}

private struct SCAccordionItemStateKey: EnvironmentKey {
    static let defaultValue = SCAccordionItemState()
}

extension EnvironmentValues {
    var scAccordionItemState: SCAccordionItemState {
        get { self[SCAccordionItemStateKey.self] }
        set { self[SCAccordionItemStateKey.self] = newValue }
    }
}

// MARK: - Root

/// A vertically stacked set of headings that reveal sections of content.
///
/// Compose an accordion from `SCAccordionItem`, `SCAccordionTrigger`, and
/// `SCAccordionContent`:
///
///     SCAccordion(defaultExpanded: ["shipping"]) {
///         SCAccordionItem(id: "shipping") {
///             SCAccordionTrigger { Text("Shipping") }
///             SCAccordionContent { Text("Free worldwide shipping.") }
///         }
///     }
///
/// Pass `expanded:` when the owning application needs controlled state.
public struct SCAccordion<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var internalExpanded: Set<String>

    private let controlledExpanded: Binding<Set<String>>?
    private let type: SCAccordionType
    private let isDisabled: Bool
    private let onExpandedChange: (Set<String>) -> Void
    private let content: Content

    /// Creates an accordion that owns its expansion state.
    public init(
        type: SCAccordionType = .single,
        defaultExpanded: Set<String> = [],
        isDisabled: Bool = false,
        onExpandedChange: @escaping (Set<String>) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        _internalExpanded = State(initialValue: defaultExpanded)
        controlledExpanded = nil
        self.type = type
        self.isDisabled = isDisabled
        self.onExpandedChange = onExpandedChange
        self.content = content()
    }

    /// Creates an accordion whose expansion state is owned by the caller.
    /// In single mode, the binding should contain at most one item identifier.
    public init(
        type: SCAccordionType = .single,
        expanded: Binding<Set<String>>,
        isDisabled: Bool = false,
        onExpandedChange: @escaping (Set<String>) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        _internalExpanded = State(initialValue: expanded.wrappedValue)
        controlledExpanded = expanded
        self.type = type
        self.isDisabled = isDisabled
        self.onExpandedChange = onExpandedChange
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .environment(
            \.scAccordionState,
            SCAccordionState(
                expanded: expanded,
                isDisabled: isDisabled,
                toggle: toggle
            )
        )
    }

    private var expanded: Set<String> {
        controlledExpanded?.wrappedValue ?? internalExpanded
    }

    private func toggle(_ id: String) {
        guard !isDisabled else { return }

        var next = expanded
        switch type {
        case .single(let collapsible):
            if next.contains(id) {
                if collapsible { next.removeAll() }
            } else {
                next = [id]
            }
        case .multiple:
            if next.contains(id) {
                next.remove(id)
            } else {
                next.insert(id)
            }
        }

        // A non-collapsible single accordion re-pressing its open item is a
        // no-op: upstream notifies only on real changes.
        guard next != expanded else { return }

        let update = {
            if let controlledExpanded {
                controlledExpanded.wrappedValue = next
            } else {
                internalExpanded = next
            }
            onExpandedChange(next)
        }

        if reduceMotion {
            update()
        } else {
            withAnimation(.snappy(duration: 0.25), update)
        }
    }
}

// MARK: - Item

/// One identified item inside an `SCAccordion`.
///
/// The content normally contains one `SCAccordionTrigger` followed by one
/// `SCAccordionContent`. Set `isDisabled` to disable that item's trigger.
public struct SCAccordionItem<ItemContent: View>: View {
    @Environment(\.theme) private var theme

    private let id: String
    private let isDisabled: Bool
    private let showsSeparator: Bool
    private let content: ItemContent

    public init(
        id: String,
        isDisabled: Bool = false,
        showsSeparator: Bool = true,
        @ViewBuilder content: () -> ItemContent
    ) {
        self.id = id
        self.isDisabled = isDisabled
        self.showsSeparator = showsSeparator
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .environment(
            \.scAccordionItemState,
            SCAccordionItemState(id: id, isDisabled: isDisabled)
        )

        if showsSeparator {
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Trigger

/// The interactive heading for an `SCAccordionItem`.
public struct SCAccordionTrigger<Label: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAccordionState) private var accordion
    @Environment(\.scAccordionItemState) private var item

    private let label: Label

    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        Button {
            accordion.toggle(item.id)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                label
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
                    .accessibilityHidden(true)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(theme.foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(accordion.isDisabled || item.isDisabled)
        .accessibilityValue(Text(isExpanded ? "Expanded" : "Collapsed"))
    }

    private var isExpanded: Bool {
        accordion.expanded.contains(item.id)
    }
}

extension SCAccordionTrigger where Label == Text {
    public init(_ title: String) {
        self.init { Text(title) }
    }
}

// MARK: - Content

/// The collapsible content panel for an `SCAccordionItem`.
public struct SCAccordionContent<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAccordionState) private var accordion
    @Environment(\.scAccordionItemState) private var item

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        if accordion.expanded.contains(item.id) {
            content
                .font(.subheadline)
                .foregroundStyle(theme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

// MARK: - Convenience item composition

extension SCAccordionItem where ItemContent == AnyView {
    /// Convenience composition for a text trigger and arbitrary content.
    public init<Body: View>(
        _ title: String,
        id: String? = nil,
        isDisabled: Bool = false,
        showsSeparator: Bool = true,
        @ViewBuilder content: () -> Body
    ) {
        let itemID = id ?? title
        self.init(
            id: itemID,
            isDisabled: isDisabled,
            showsSeparator: showsSeparator
        ) {
            AnyView(
                Group {
                    SCAccordionTrigger(title)
                    SCAccordionContent(content: content)
                }
            )
        }
    }

    /// Convenience composition for plain-text content.
    public init(
        _ title: String,
        id: String? = nil,
        content: String,
        isDisabled: Bool = false,
        showsSeparator: Bool = true
    ) {
        self.init(
            title,
            id: id,
            isDisabled: isDisabled,
            showsSeparator: showsSeparator
        ) {
            Text(content)
        }
    }
}

// MARK: - Previews

#Preview("Accordion · composed and controlled") {
    @Previewable @State var expanded: Set<String> = ["shipping"]

    SCPreview {
        SCAccordion(type: .multiple, expanded: $expanded) {
            SCAccordionItem(id: "shipping") {
                SCAccordionTrigger { Text("Shipping") }
                SCAccordionContent {
                    Text("Free worldwide shipping on all orders.")
                }
            }
            SCAccordionItem(id: "returns", isDisabled: true) {
                SCAccordionTrigger { Text("Returns") }
                SCAccordionContent { Text("Free returns within 30 days.") }
            }
            SCAccordionItem("Support", content: "Reach us any time.")
        }
    }
}
