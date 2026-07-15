// ============================================================
// Collapsible.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Composable primitives

private struct SCCollapsibleContext {
    var isOpen: Binding<Bool>
    var isDisabled: Bool
}

private struct SCCollapsibleContextKey: EnvironmentKey {
    static let defaultValue = SCCollapsibleContext(
        isOpen: .constant(false),
        isDisabled: true
    )
}

extension EnvironmentValues {
    fileprivate var scCollapsibleContext: SCCollapsibleContext {
        get { self[SCCollapsibleContextKey.self] }
        set { self[SCCollapsibleContextKey.self] = newValue }
    }
}

/// Provides controlled or uncontrolled state to collapsible trigger and content parts.
public struct SCCollapsibleRoot<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @State private var internalIsOpen: Bool

    private let externalIsOpen: Binding<Bool>?
    private let isDisabled: Bool
    private let onOpenChange: ((Bool) -> Void)?
    private let content: (Bool) -> Content

    public init(
        isOpen: Binding<Bool>? = nil,
        defaultOpen: Bool = false,
        isDisabled: Bool = false,
        onOpenChange: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        self.externalIsOpen = isOpen
        self._internalIsOpen = State(initialValue: defaultOpen)
        self.isDisabled = isDisabled
        self.onOpenChange = onOpenChange
        self.content = content
    }

    public init(
        isOpen: Binding<Bool>? = nil,
        defaultOpen: Bool = false,
        isDisabled: Bool = false,
        onOpenChange: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            isOpen: isOpen,
            defaultOpen: defaultOpen,
            isDisabled: isDisabled,
            onOpenChange: onOpenChange
        ) { _ in
            content()
        }
    }

    public var body: some View {
        content(currentIsOpen)
            .environment(
                \.scCollapsibleContext,
                SCCollapsibleContext(
                    isOpen: openBinding,
                    isDisabled: isDisabled || !isEnabled
                )
            )
    }

    private var currentIsOpen: Bool {
        externalIsOpen?.wrappedValue ?? internalIsOpen
    }

    private var openBinding: Binding<Bool> {
        Binding(
            get: { currentIsOpen },
            set: { newValue in
                guard newValue != currentIsOpen else { return }
                if let externalIsOpen {
                    externalIsOpen.wrappedValue = newValue
                } else {
                    internalIsOpen = newValue
                }
                onOpenChange?(newValue)
            }
        )
    }
}

/// A native button that toggles the nearest `SCCollapsibleRoot`.
public struct SCCollapsibleTrigger<Content: View>: View {
    @Environment(\.scCollapsibleContext) private var context
    private let content: (Bool) -> Content

    public init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.content = content
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = { _ in content() }
    }

    public var body: some View {
        Button {
            guard !context.isDisabled else { return }
            context.isOpen.wrappedValue.toggle()
        } label: {
            content(context.isOpen.wrappedValue)
        }
        .disabled(context.isDisabled)
        .accessibilityValue(Text(context.isOpen.wrappedValue ? "Expanded" : "Collapsed"))
    }
}

/// The state-aware panel controlled by the nearest `SCCollapsibleRoot`.
public struct SCCollapsibleContent<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scCollapsibleContext) private var context

    private let keepMounted: Bool
    private let animation: Animation
    private let content: (Bool) -> Content

    public init(
        keepMounted: Bool = false,
        animation: Animation = .snappy(duration: 0.25),
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        self.keepMounted = keepMounted
        self.animation = animation
        self.content = content
    }

    public init(
        keepMounted: Bool = false,
        animation: Animation = .snappy(duration: 0.25),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(keepMounted: keepMounted, animation: animation) { _ in content() }
    }

    public var body: some View {
        Group {
            if keepMounted {
                panel
                    .frame(height: context.isOpen.wrappedValue ? nil : 0)
                    .opacity(context.isOpen.wrappedValue ? 1 : 0)
                    .allowsHitTesting(context.isOpen.wrappedValue)
                    .accessibilityHidden(!context.isOpen.wrappedValue)
            } else if context.isOpen.wrappedValue {
                panel.transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(reduceMotion ? nil : animation, value: context.isOpen.wrappedValue)
    }

    private var panel: some View {
        content(context.isOpen.wrappedValue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
    }
}

// MARK: - Convenience composition

/// An interactive panel convenience that composes Root, Trigger, and Content.
public struct SCCollapsible<Trigger: View, Content: View>: View {
    @Environment(\.theme) private var theme

    private let externalIsOpen: Binding<Bool>?
    private let defaultOpen: Bool
    private let isDisabled: Bool
    private let showsChevron: Bool
    private let trigger: Trigger
    private let content: Content

    public init(
        isOpen: Binding<Bool>? = nil,
        defaultOpen: Bool = false,
        isDisabled: Bool = false,
        showsChevron: Bool = true,
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> Content
    ) {
        self.externalIsOpen = isOpen
        self.defaultOpen = defaultOpen
        self.isDisabled = isDisabled
        self.showsChevron = showsChevron
        self.trigger = trigger()
        self.content = content()
    }

    public var body: some View {
        SCCollapsibleRoot(
            isOpen: externalIsOpen,
            defaultOpen: defaultOpen,
            isDisabled: isDisabled
        ) {
            VStack(alignment: .leading, spacing: 0) {
                SCCollapsibleTrigger { isOpen in
                    HStack(spacing: 8) {
                        trigger.multilineTextAlignment(.leading)
                        if showsChevron {
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(theme.mutedForeground)
                                .rotationEffect(.degrees(isOpen ? 90 : 0))
                                .accessibilityHidden(true)
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.foreground)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                SCCollapsibleContent {
                    content
                        .font(.subheadline)
                        .foregroundStyle(theme.foreground)
                        .padding(.top, 8)
                }
            }
        }
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
