// ============================================================
// Menubar.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Configuration

public enum SCMenubarOrientation: CaseIterable, Equatable, Hashable, Sendable {
    case horizontal
    case vertical
}

public enum SCMenubarItemVariant: CaseIterable, Equatable, Hashable, Sendable {
    case `default`
    case destructive

    fileprivate var role: ButtonRole? {
        self == .destructive ? .destructive : nil
    }
}

/// A real keyboard shortcut attached to the native menu action that it
/// describes. This is intentionally a value, not decorative trailing text.
public struct SCMenubarShortcut: Sendable {
    public let key: KeyEquivalent
    public let modifiers: EventModifiers

    public init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command
    ) {
        self.key = key
        self.modifiers = modifiers
    }
}

// MARK: - Root

/// A native menu collection. SwiftUI owns each popup, its focus model,
/// dismissal, collision-safe placement, submenu direction, and accessibility.
public struct SCMenubar<Content: View>: View {
    @Environment(\.theme) private var theme

    private let orientation: SCMenubarOrientation
    private let isDisabled: Bool
    private let spacing: CGFloat
    private let content: Content

    public init(
        orientation: SCMenubarOrientation = .horizontal,
        isDisabled: Bool = false,
        spacing: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.orientation = orientation
        self.isDisabled = isDisabled
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal:
                HStack(spacing: spacing) { content }
            case .vertical:
                VStack(alignment: .leading, spacing: spacing) { content }
            }
        }
        .padding(4)
        .frame(minHeight: orientation == .horizontal ? 36 : nil)
        .background(theme.background, in: shape)
        .overlay { shape.strokeBorder(theme.border) }
        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
        .disabled(isDisabled)
        .accessibilityElement(children: .contain)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 2, 4), style: .continuous)
    }
}

// MARK: - Menu, trigger, and content

/// One real native Menu in a Menubar.
public struct SCMenubarMenu<Trigger: View, MenuContent: View>: View {
    private let isDisabled: Bool
    private let order: MenuOrder
    private let trigger: Trigger
    private let menuContent: MenuContent

    public init(
        isDisabled: Bool = false,
        order: MenuOrder = .automatic,
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> MenuContent
    ) {
        self.isDisabled = isDisabled
        self.order = order
        self.trigger = trigger()
        self.menuContent = content()
    }

    public var body: some View {
        Menu {
            menuContent
        } label: {
            trigger
        }
        .menuOrder(order)
        .menuIndicator(.hidden)
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

/// The arbitrary label used by a native top-level Menu trigger.
public struct SCMenubarTrigger<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    private let content: Content
    @State private var isHovered = false

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 6) { content }
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .frame(minHeight: 28)
            .foregroundStyle(theme.foreground)
            .background(isHovered && isEnabled ? theme.accent : .clear, in: shape)
            .overlay {
                if isFocused {
                    shape.strokeBorder(theme.ring.opacity(0.5), lineWidth: 2)
                }
            }
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.1), value: isHovered)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 3), style: .continuous)
    }
}

extension SCMenubarTrigger where Content == Text {
    public init(_ title: String) {
        self.init { Text(title) }
    }
}

/// The caller-composed contents of a native Menu. The Menu itself owns the
/// portal and popup surface, so there is no inert SwiftUI Portal part.
public struct SCMenubarContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View { content }
}

// MARK: - Groups and labels

/// A native menu Section with an arbitrary optional heading.
public struct SCMenubarGroup<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content

    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        Section {
            content
        } header: {
            label
        }
    }
}

extension SCMenubarGroup where Label == EmptyView {
    public init(@ViewBuilder content: () -> Content) {
        self.init(label: { EmptyView() }, content: content)
    }
}

extension SCMenubarGroup where Label == Text {
    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.init(label: { Text(title) }, content: content)
    }
}

/// An arbitrary heading view intended for SCMenubarGroup's label slot.
public struct SCMenubarLabel<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View { content }
}

extension SCMenubarLabel where Content == Text {
    public init(_ title: String) {
        self.init { Text(title) }
    }
}

// MARK: - Action items

/// A real native menu action with destructive, disabled, arbitrary-label, and
/// keyboard-shortcut behavior.
public struct SCMenubarItem<Label: View>: View {
    private let variant: SCMenubarItemVariant
    private let isDisabled: Bool
    private let shortcut: SCMenubarShortcut?
    private let action: () -> Void
    private let label: Label

    public init(
        variant: SCMenubarItemVariant = .default,
        isDisabled: Bool = false,
        shortcut: SCMenubarShortcut? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.isDisabled = isDisabled
        self.shortcut = shortcut
        self.action = action
        self.label = label()
    }

    @ViewBuilder
    public var body: some View {
        if let shortcut {
            button.keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        } else {
            button
        }
    }

    private var button: some View {
        Button(role: variant.role, action: action) {
            label
        }
        .disabled(isDisabled)
    }
}

extension SCMenubarItem where Label == Text {
    public init(
        _ title: String,
        variant: SCMenubarItemVariant = .default,
        isDisabled: Bool = false,
        shortcut: SCMenubarShortcut? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            isDisabled: isDisabled,
            shortcut: shortcut,
            action: action,
            label: { Text(title) }
        )
    }
}

// MARK: - Checkbox items

/// A caller-controlled native checkbox menu item.
public struct SCMenubarCheckboxItem<Label: View>: View {
    @Binding private var isChecked: Bool
    private let isDisabled: Bool
    private let shortcut: SCMenubarShortcut?
    private let label: Label

    public init(
        isChecked: Binding<Bool>,
        isDisabled: Bool = false,
        shortcut: SCMenubarShortcut? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self._isChecked = isChecked
        self.isDisabled = isDisabled
        self.shortcut = shortcut
        self.label = label()
    }

    @ViewBuilder
    public var body: some View {
        if let shortcut {
            toggle.keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        } else {
            toggle
        }
    }

    private var toggle: some View {
        Toggle(isOn: $isChecked) {
            label
        }
        .disabled(isDisabled)
    }
}

extension SCMenubarCheckboxItem where Label == Text {
    public init(
        _ title: String,
        isChecked: Binding<Bool>,
        isDisabled: Bool = false,
        shortcut: SCMenubarShortcut? = nil
    ) {
        self.init(
            isChecked: isChecked,
            isDisabled: isDisabled,
            shortcut: shortcut
        ) {
            Text(title)
        }
    }
}

// MARK: - Radio groups

/// A caller-controlled native single-selection menu group.
public struct SCMenubarRadioGroup<Value: Hashable, Content: View>: View {
    @Binding private var selection: Value
    private let title: String
    private let content: Content

    public init(
        _ title: String = "Options",
        selection: Binding<Value>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        Picker(title, selection: $selection) {
            content
        }
        .pickerStyle(.inline)
    }
}

/// One tagged, optionally disabled choice in SCMenubarRadioGroup.
public struct SCMenubarRadioItem<Value: Hashable, Content: View>: View {
    private let value: Value
    private let isDisabled: Bool
    private let content: Content

    public init(
        value: Value,
        isDisabled: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.value = value
        self.isDisabled = isDisabled
        self.content = content()
    }

    public var body: some View {
        content
            .tag(value)
            .disabled(isDisabled)
    }
}

extension SCMenubarRadioItem where Content == Text {
    public init(
        _ title: String,
        value: Value,
        isDisabled: Bool = false
    ) {
        self.init(value: value, isDisabled: isDisabled) {
            Text(title)
        }
    }
}

// MARK: - Submenus

/// A real native submenu. The platform owns hover timing, keyboard traversal,
/// placement, RTL direction, dismissal, and accessibility.
public struct SCMenubarSub<Trigger: View, Content: View>: View {
    private let isDisabled: Bool
    private let trigger: Trigger
    private let content: Content

    public init(
        isDisabled: Bool = false,
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> Content
    ) {
        self.isDisabled = isDisabled
        self.trigger = trigger()
        self.content = content()
    }

    public var body: some View {
        Menu {
            content
        } label: {
            trigger
        }
        .disabled(isDisabled)
    }
}

public struct SCMenubarSubTrigger<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View { content }
}

extension SCMenubarSubTrigger where Content == Text {
    public init(_ title: String) {
        self.init { Text(title) }
    }
}

public struct SCMenubarSubContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View { content }
}

// MARK: - Separator

public struct SCMenubarSeparator: View {
    public init() {}

    public var body: some View { Divider() }
}

// MARK: - Previews

private enum SCMenubarPreviewTheme: String, CaseIterable, Hashable {
    case light
    case dark
    case system
}

#Preview("Menubar · complete") {
    @Previewable @State var showBookmarks = true
    @Previewable @State var theme = SCMenubarPreviewTheme.system
    @Previewable @State var lastAction = "No action"

    SCPreview {
        VStack(spacing: 16) {
            SCMenubar {
                SCMenubarMenu {
                    SCMenubarTrigger("File")
                } content: {
                    SCMenubarContent {
                        SCMenubarGroup("File actions") {
                            SCMenubarItem(
                                shortcut: SCMenubarShortcut("n"),
                                action: { lastAction = "New file" },
                                label: { Label("New File", systemImage: "doc") }
                            )
                            SCMenubarItem(
                                "New Incognito Window",
                                isDisabled: true,
                                action: {}
                            )
                        }
                        SCMenubarSeparator()
                        SCMenubarSub {
                            SCMenubarSubTrigger("Share")
                        } content: {
                            SCMenubarSubContent {
                                SCMenubarItem("Email") { lastAction = "Email" }
                                SCMenubarItem("Messages") { lastAction = "Messages" }
                            }
                        }
                        SCMenubarSeparator()
                        SCMenubarItem(
                            "Delete File",
                            variant: .destructive,
                            shortcut: SCMenubarShortcut(.delete, modifiers: .command),
                            action: { lastAction = "Delete" }
                        )
                    }
                }
                SCMenubarMenu {
                    SCMenubarTrigger("View")
                } content: {
                    SCMenubarContent {
                        SCMenubarCheckboxItem(
                            "Show Bookmarks",
                            isChecked: $showBookmarks
                        )
                        SCMenubarSeparator()
                        SCMenubarRadioGroup("Theme", selection: $theme) {
                            ForEach(SCMenubarPreviewTheme.allCases, id: \.self) { value in
                                SCMenubarRadioItem(
                                    value.rawValue.capitalized,
                                    value: value
                                )
                            }
                        }
                    }
                }
                SCMenubarMenu(isDisabled: true) {
                    SCMenubarTrigger("Help")
                } content: {
                    SCMenubarContent { EmptyView() }
                }
            }

            Text(lastAction).scMuted()
        }
    }
}

#Preview("Menubar · vertical") {
    SCPreview {
        SCMenubar(orientation: .vertical) {
            SCMenubarMenu {
                SCMenubarTrigger("File")
            } content: {
                SCMenubarItem("New") {}
            }
            SCMenubarMenu {
                SCMenubarTrigger("Edit")
            } content: {
                SCMenubarItem("Undo") {}
            }
        }
    }
}
