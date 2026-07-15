// ============================================================
// NavigationMenu.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Configuration

public enum SCNavigationMenuOrientation: CaseIterable, Hashable, Sendable {
    case horizontal
    case vertical
}

public enum SCNavigationMenuAlignment: CaseIterable, Hashable, Sendable {
    case start
    case center
    case end
}

public enum SCNavigationMenuSide: CaseIterable, Hashable, Sendable {
    case top
    case bottom
    case leading
    case trailing
}

public enum SCNavigationMenuChangeReason: Hashable, Sendable {
    case triggerPress
    case triggerHover
    case outsidePress
    case listNavigation
    case focusOut
    case escapeKey
    case linkPress
    case programmatic
}

/// Native popover placement used by `SCNavigationMenu`.
///
/// SwiftUI's popover owns collision avoidance and window-edge adaptation. The
/// logical leading and trailing cases follow the current layout direction.
public struct SCNavigationMenuPositioner: Hashable, Sendable {
    public var side: SCNavigationMenuSide
    public var alignment: SCNavigationMenuAlignment

    public init(
        side: SCNavigationMenuSide = .bottom,
        alignment: SCNavigationMenuAlignment = .start
    ) {
        self.side = side
        self.alignment = alignment
    }

    fileprivate func arrowEdge(layoutDirection: LayoutDirection) -> Edge {
        switch side {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leading:
            return layoutDirection == .leftToRight ? .trailing : .leading
        case .trailing:
            return layoutDirection == .leftToRight ? .leading : .trailing
        }
    }

    fileprivate func attachmentAnchor(
        layoutDirection: LayoutDirection
    ) -> PopoverAttachmentAnchor {
        .point(attachmentPoint(layoutDirection: layoutDirection))
    }

    private func attachmentPoint(layoutDirection: LayoutDirection) -> UnitPoint {
        let startX: CGFloat = layoutDirection == .leftToRight ? 0 : 1
        let endX: CGFloat = layoutDirection == .leftToRight ? 1 : 0

        switch side {
        case .top:
            return UnitPoint(x: horizontalCoordinate(start: startX, end: endX), y: 0)
        case .bottom:
            return UnitPoint(x: horizontalCoordinate(start: startX, end: endX), y: 1)
        case .leading:
            return UnitPoint(
                x: layoutDirection == .leftToRight ? 0 : 1,
                y: verticalCoordinate
            )
        case .trailing:
            return UnitPoint(
                x: layoutDirection == .leftToRight ? 1 : 0,
                y: verticalCoordinate
            )
        }
    }

    private func horizontalCoordinate(start: CGFloat, end: CGFloat) -> CGFloat {
        switch alignment {
        case .start: start
        case .center: 0.5
        case .end: end
        }
    }

    private var verticalCoordinate: CGFloat {
        switch alignment {
        case .start: 0
        case .center: 0.5
        case .end: 1
        }
    }
}

public enum SCNavigationMenuLinkPresentation: CaseIterable, Hashable, Sendable {
    /// A link inside popup content.
    case content
    /// A direct link alongside popup triggers.
    case trigger
}

// MARK: - Shared contexts

private enum SCNavigationMenuMove {
    case left
    case right
    case up
    case down
}

private struct SCNavigationMenuRegistration: Equatable {
    let value: AnyHashable
    let hasContent: Bool
}

private struct SCNavigationMenuContext {
    var value: AnyHashable?
    var orientation: SCNavigationMenuOrientation
    var positioner: SCNavigationMenuPositioner
    var focus: FocusState<AnyHashable?>.Binding?
    var setValue: (AnyHashable?, SCNavigationMenuChangeReason) -> Void
    var scheduleOpen: (AnyHashable) -> Void
    var scheduleClose: () -> Void
    var cancelScheduledClose: () -> Void
    var register: (SCNavigationMenuRegistration) -> Void
    var unregister: (AnyHashable) -> Void
    var moveFocus: (SCNavigationMenuMove) -> Bool

    static let inactive = SCNavigationMenuContext(
        value: nil,
        orientation: .horizontal,
        positioner: SCNavigationMenuPositioner(),
        focus: nil,
        setValue: { _, _ in },
        scheduleOpen: { _ in },
        scheduleClose: {},
        cancelScheduledClose: {},
        register: { _ in },
        unregister: { _ in },
        moveFocus: { _ in false }
    )
}

private struct SCNavigationMenuContextKey: EnvironmentKey {
    static let defaultValue = SCNavigationMenuContext.inactive
}

private struct SCNavigationMenuItemContext {
    var value: AnyHashable?
    var hasContent = false
}

private struct SCNavigationMenuItemContextKey: EnvironmentKey {
    static let defaultValue = SCNavigationMenuItemContext()
}

private struct SCNavigationMenuDismissAction {
    var callAsFunction: () -> Void = {}
}

private struct SCNavigationMenuDismissActionKey: EnvironmentKey {
    static let defaultValue = SCNavigationMenuDismissAction()
}

extension EnvironmentValues {
    fileprivate var scNavigationMenuContext: SCNavigationMenuContext {
        get { self[SCNavigationMenuContextKey.self] }
        set { self[SCNavigationMenuContextKey.self] = newValue }
    }

    fileprivate var scNavigationMenuItemContext: SCNavigationMenuItemContext {
        get { self[SCNavigationMenuItemContextKey.self] }
        set { self[SCNavigationMenuItemContextKey.self] = newValue }
    }

    /// Dismisses the nearest open navigation menu popup.
    public var scDismissNavigationMenu: () -> Void {
        get { self[SCNavigationMenuDismissActionKey.self].callAsFunction }
        set {
            self[SCNavigationMenuDismissActionKey.self] = SCNavigationMenuDismissAction(
                callAsFunction: newValue
            )
        }
    }
}

// MARK: - Root

/// A controlled or internally managed collection of navigation links and
/// rich popup menus.
///
/// Each item uses a real native popover. SwiftUI therefore owns anchoring,
/// collision avoidance, outside-click and Escape dismissal, focus containment,
/// compact-width presentation, and assistive-technology behavior.
public struct SCNavigationMenu<Content: View>: View {
    private let externalValue: Binding<AnyHashable?>?
    private let defaultValue: AnyHashable?
    private let orientation: SCNavigationMenuOrientation
    private let positioner: SCNavigationMenuPositioner
    private let openDelay: Duration
    private let closeDelay: Duration
    private let isDisabled: Bool
    private let onValueChange: ((AnyHashable?, SCNavigationMenuChangeReason) -> Void)?
    private let content: Content

    public init(
        orientation: SCNavigationMenuOrientation = .horizontal,
        positioner: SCNavigationMenuPositioner = SCNavigationMenuPositioner(),
        openDelay: Duration = .milliseconds(50),
        closeDelay: Duration = .milliseconds(50),
        isDisabled: Bool = false,
        onValueChange: ((AnyHashable?, SCNavigationMenuChangeReason) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.externalValue = nil
        self.defaultValue = nil
        self.orientation = orientation
        self.positioner = positioner
        self.openDelay = openDelay
        self.closeDelay = closeDelay
        self.isDisabled = isDisabled
        self.onValueChange = onValueChange
        self.content = content()
    }

    public init<Value: Hashable>(
        value: Binding<Value?>,
        orientation: SCNavigationMenuOrientation = .horizontal,
        positioner: SCNavigationMenuPositioner = SCNavigationMenuPositioner(),
        openDelay: Duration = .milliseconds(50),
        closeDelay: Duration = .milliseconds(50),
        isDisabled: Bool = false,
        onValueChange: ((Value?, SCNavigationMenuChangeReason) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.externalValue = Binding(
            get: { value.wrappedValue.map(AnyHashable.init) },
            set: { nextValue in value.wrappedValue = nextValue?.base as? Value }
        )
        self.defaultValue = value.wrappedValue.map(AnyHashable.init)
        self.orientation = orientation
        self.positioner = positioner
        self.openDelay = openDelay
        self.closeDelay = closeDelay
        self.isDisabled = isDisabled
        self.onValueChange = { nextValue, reason in
            onValueChange?(nextValue?.base as? Value, reason)
        }
        self.content = content()
    }

    public init<Value: Hashable>(
        defaultValue: Value,
        orientation: SCNavigationMenuOrientation = .horizontal,
        positioner: SCNavigationMenuPositioner = SCNavigationMenuPositioner(),
        openDelay: Duration = .milliseconds(50),
        closeDelay: Duration = .milliseconds(50),
        isDisabled: Bool = false,
        onValueChange: ((Value?, SCNavigationMenuChangeReason) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.externalValue = nil
        self.defaultValue = AnyHashable(defaultValue)
        self.orientation = orientation
        self.positioner = positioner
        self.openDelay = openDelay
        self.closeDelay = closeDelay
        self.isDisabled = isDisabled
        self.onValueChange = { nextValue, reason in
            onValueChange?(nextValue?.base as? Value, reason)
        }
        self.content = content()
    }

    public var body: some View {
        SCNavigationMenuStateContainer(
            externalValue: externalValue,
            defaultValue: defaultValue,
            orientation: orientation,
            positioner: positioner,
            openDelay: openDelay,
            closeDelay: closeDelay,
            isDisabled: isDisabled,
            onValueChange: onValueChange,
            content: content
        )
    }
}

private struct SCNavigationMenuStateContainer<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection

    @State private var internalValue: AnyHashable?
    @State private var registrations: [SCNavigationMenuRegistration] = []
    @State private var openTask: Task<Void, Never>?
    @State private var closeTask: Task<Void, Never>?
    @FocusState private var focusedValue: AnyHashable?

    let externalValue: Binding<AnyHashable?>?
    let orientation: SCNavigationMenuOrientation
    let positioner: SCNavigationMenuPositioner
    let openDelay: Duration
    let closeDelay: Duration
    let isDisabled: Bool
    let onValueChange: ((AnyHashable?, SCNavigationMenuChangeReason) -> Void)?
    let content: Content

    init(
        externalValue: Binding<AnyHashable?>?,
        defaultValue: AnyHashable?,
        orientation: SCNavigationMenuOrientation,
        positioner: SCNavigationMenuPositioner,
        openDelay: Duration,
        closeDelay: Duration,
        isDisabled: Bool,
        onValueChange: ((AnyHashable?, SCNavigationMenuChangeReason) -> Void)?,
        content: Content
    ) {
        self.externalValue = externalValue
        self.orientation = orientation
        self.positioner = positioner
        self.openDelay = openDelay
        self.closeDelay = closeDelay
        self.isDisabled = isDisabled
        self.onValueChange = onValueChange
        self.content = content
        self._internalValue = State(initialValue: defaultValue)
    }

    var body: some View {
        content
            .environment(\.scNavigationMenuContext, context)
            .disabled(isDisabled)
            .accessibilityElement(children: .contain)
            .onDisappear {
                openTask?.cancel()
                closeTask?.cancel()
            }
    }

    private var currentValue: AnyHashable? {
        externalValue?.wrappedValue ?? internalValue
    }

    private var context: SCNavigationMenuContext {
        SCNavigationMenuContext(
            value: currentValue,
            orientation: orientation,
            positioner: positioner,
            focus: $focusedValue,
            setValue: setValue,
            scheduleOpen: scheduleOpen,
            scheduleClose: scheduleClose,
            cancelScheduledClose: cancelScheduledClose,
            register: register,
            unregister: unregister,
            moveFocus: moveFocus
        )
    }

    private func setValue(
        _ nextValue: AnyHashable?,
        reason: SCNavigationMenuChangeReason
    ) {
        openTask?.cancel()
        closeTask?.cancel()
        guard currentValue != nextValue else { return }

        if let externalValue {
            externalValue.wrappedValue = nextValue
        } else {
            internalValue = nextValue
        }
        onValueChange?(nextValue, reason)
    }

    private func scheduleOpen(_ value: AnyHashable) {
        closeTask?.cancel()
        openTask?.cancel()
        openTask = Task { @MainActor in
            do {
                try await Task.sleep(for: openDelay)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            setValue(value, reason: .triggerHover)
        }
    }

    private func scheduleClose() {
        openTask?.cancel()
        closeTask?.cancel()
        closeTask = Task { @MainActor in
            do {
                try await Task.sleep(for: closeDelay)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            setValue(nil, reason: .focusOut)
        }
    }

    private func cancelScheduledClose() {
        closeTask?.cancel()
    }

    private func register(_ registration: SCNavigationMenuRegistration) {
        guard !registrations.contains(where: { $0.value == registration.value }) else { return }
        registrations.append(registration)
    }

    private func unregister(_ value: AnyHashable) {
        registrations.removeAll { $0.value == value }
    }

    private func moveFocus(_ move: SCNavigationMenuMove) -> Bool {
        guard !registrations.isEmpty else { return false }

        if shouldOpen(move) {
            guard
                let focusedValue,
                registrations.first(where: { $0.value == focusedValue })?.hasContent == true
            else { return false }
            setValue(focusedValue, reason: .listNavigation)
            return true
        }

        if shouldClose(move) {
            guard currentValue != nil else { return false }
            setValue(nil, reason: .listNavigation)
            return true
        }

        guard let offset = traversalOffset(move) else { return false }
        let currentIndex = focusedValue.flatMap { value in
            registrations.firstIndex(where: { $0.value == value })
        }
        let start = currentIndex ?? (offset > 0 ? -1 : registrations.count)
        let targetIndex = (start + offset + registrations.count) % registrations.count
        let target = registrations[targetIndex]
        focusedValue = target.value

        if currentValue != nil {
            setValue(target.hasContent ? target.value : nil, reason: .listNavigation)
        }
        return true
    }

    private func traversalOffset(_ move: SCNavigationMenuMove) -> Int? {
        switch (orientation, move) {
        case (.horizontal, .left):
            return layoutDirection == .leftToRight ? -1 : 1
        case (.horizontal, .right):
            return layoutDirection == .leftToRight ? 1 : -1
        case (.vertical, .up):
            return -1
        case (.vertical, .down):
            return 1
        default:
            return nil
        }
    }

    private func shouldOpen(_ move: SCNavigationMenuMove) -> Bool {
        switch orientation {
        case .horizontal:
            return move == .down
        case .vertical:
            return layoutDirection == .leftToRight ? move == .right : move == .left
        }
    }

    private func shouldClose(_ move: SCNavigationMenuMove) -> Bool {
        switch orientation {
        case .horizontal:
            return move == .up
        case .vertical:
            return layoutDirection == .leftToRight ? move == .left : move == .right
        }
    }
}

// MARK: - List and item

/// Arranges navigation items along the root's declared orientation and owns
/// arrow-key traversal between their real focusable controls.
public struct SCNavigationMenuList<Content: View>: View {
    @Environment(\.scNavigationMenuContext) private var context

    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.spacing = max(spacing, 0)
        self.content = content()
    }

    public var body: some View {
        Group {
            switch context.orientation {
            case .horizontal:
                HStack(spacing: spacing) { content }
            case .vertical:
                VStack(alignment: .leading, spacing: spacing) { content }
            }
        }
        .onKeyPress(.leftArrow) { keyResult(.left) }
        .onKeyPress(.rightArrow) { keyResult(.right) }
        .onKeyPress(.upArrow) { keyResult(.up) }
        .onKeyPress(.downArrow) { keyResult(.down) }
        .onKeyPress(.escape) {
            guard context.value != nil else { return .ignored }
            context.setValue(nil, .escapeKey)
            return .handled
        }
        .accessibilityElement(children: .contain)
    }

    private func keyResult(_ move: SCNavigationMenuMove) -> KeyPress.Result {
        context.moveFocus(move) ? .handled : .ignored
    }
}

/// Pairs one real trigger or direct link with its optional rich popup content.
/// The `value` is the stable controlled-state and focus-navigation identity.
public struct SCNavigationMenuItem<Trigger: View, MenuContent: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.scNavigationMenuContext) private var context

    private let value: AnyHashable
    private let hasContent: Bool
    private let trigger: Trigger
    private let menuContent: MenuContent

    public init<Value: Hashable>(
        value: Value,
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> MenuContent
    ) {
        self.value = AnyHashable(value)
        self.hasContent = true
        self.trigger = trigger()
        self.menuContent = content()
    }

    fileprivate init(
        value: AnyHashable,
        hasContent: Bool,
        trigger: Trigger,
        menuContent: MenuContent
    ) {
        self.value = value
        self.hasContent = hasContent
        self.trigger = trigger
        self.menuContent = menuContent
    }

    public var body: some View {
        trigger
            .environment(
                \.scNavigationMenuItemContext,
                SCNavigationMenuItemContext(value: value, hasContent: hasContent)
            )
            .modifier(SCNavigationMenuFocusModifier(focus: context.focus, value: value))
            .popover(
                isPresented: presentation,
                attachmentAnchor: context.positioner.attachmentAnchor(
                    layoutDirection: layoutDirection
                ),
                arrowEdge: context.positioner.arrowEdge(layoutDirection: layoutDirection)
            ) {
                menuContent
                    .environment(
                        \.scNavigationMenuItemContext,
                        SCNavigationMenuItemContext(value: value, hasContent: hasContent)
                    )
                    .environment(\.scNavigationMenuContext, context)
                    .environment(\.scDismissNavigationMenu) {
                        context.setValue(nil, .programmatic)
                    }
                    .presentationCompactAdaptation(.popover)
            }
            .onAppear {
                context.register(
                    SCNavigationMenuRegistration(value: value, hasContent: hasContent)
                )
            }
            .onDisappear {
                context.unregister(value)
            }
    }

    private var presentation: Binding<Bool> {
        Binding(
            get: { hasContent && context.value == value },
            set: { isPresented in
                guard !isPresented, context.value == value else { return }
                context.setValue(nil, .outsidePress)
            }
        )
    }
}

extension SCNavigationMenuItem where MenuContent == EmptyView {
    /// Creates a direct-link item with no popup content.
    public init<Value: Hashable>(
        value: Value,
        @ViewBuilder content: () -> Trigger
    ) {
        self.init(
            value: AnyHashable(value),
            hasContent: false,
            trigger: content(),
            menuContent: EmptyView()
        )
    }
}

private struct SCNavigationMenuFocusModifier: ViewModifier {
    let focus: FocusState<AnyHashable?>.Binding?
    let value: AnyHashable

    @ViewBuilder
    func body(content: Content) -> some View {
        if let focus {
            content.focused(focus, equals: value)
        } else {
            content
        }
    }
}

// MARK: - Trigger and indicator

/// A real native button that opens its enclosing item's popup.
public struct SCNavigationMenuTrigger<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scNavigationMenuContext) private var context
    @Environment(\.scNavigationMenuItemContext) private var item

    private let isDisabled: Bool
    private let showsIndicator: Bool
    private let label: Label

    public init(
        isDisabled: Bool = false,
        showsIndicator: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.isDisabled = isDisabled
        self.showsIndicator = showsIndicator
        self.label = label()
    }

    public var body: some View {
        Button(action: toggle) {
            HStack(spacing: 6) {
                label
                if showsIndicator {
                    SCNavigationMenuIndicator()
                }
            }
        }
        .buttonStyle(SCNavigationMenuTriggerButtonStyle(isOpen: isOpen))
        .disabled(isDisabled)
        .onHover { isHovered in
            guard isEnabled, !isDisabled, let value = item.value else { return }
            if isHovered {
                context.scheduleOpen(value)
            } else {
                context.scheduleClose()
            }
        }
        .accessibilityValue(isOpen ? "Expanded" : "Collapsed")
    }

    private var isOpen: Bool {
        item.hasContent && item.value == context.value
    }

    private func toggle() {
        guard let value = item.value, item.hasContent else { return }
        context.setValue(isOpen ? nil : value, .triggerPress)
    }
}

extension SCNavigationMenuTrigger where Label == Text {
    public init(
        _ title: String,
        isDisabled: Bool = false,
        showsIndicator: Bool = true
    ) {
        self.init(isDisabled: isDisabled, showsIndicator: showsIndicator) {
            Text(title)
        }
    }
}

/// The disclosure indicator for the active trigger. It mirrors for neither
/// text direction because opening is represented by vertical rotation.
public struct SCNavigationMenuIndicator: View {
    @Environment(\.scNavigationMenuContext) private var context
    @Environment(\.scNavigationMenuItemContext) private var item

    private let size: CGFloat

    public init(size: CGFloat = 10) {
        self.size = max(size, 1)
    }

    public var body: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: size, weight: .semibold))
            .rotationEffect(.degrees(item.value == context.value ? 180 : 0))
            .animation(.easeInOut(duration: 0.2), value: item.value == context.value)
            .accessibilityHidden(true)
    }
}

private struct SCNavigationMenuTriggerButtonStyle: ButtonStyle {
    let isOpen: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.modifier(
            SCNavigationMenuTriggerChrome(isOpen: isOpen, isPressed: configuration.isPressed)
        )
    }
}

private struct SCNavigationMenuTriggerChrome: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.theme) private var theme

    let isOpen: Bool
    let isPressed: Bool

    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 16)
            .frame(minHeight: 36)
            .foregroundStyle(isActive ? theme.accentForeground : theme.foreground)
            .background(background, in: shape)
            .overlay {
                if isFocused {
                    shape.strokeBorder(theme.ring.opacity(0.5), lineWidth: 3)
                }
            }
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.12), value: isPressed)
            .animation(.easeOut(duration: 0.12), value: isOpen)
    }

    private var isActive: Bool {
        isOpen || isPressed || (isHovered && isEnabled)
    }

    private var background: Color {
        isActive ? theme.accent.opacity(isOpen && !isHovered ? 0.5 : 1) : theme.background
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 2, 4), style: .continuous)
    }
}

// MARK: - Popup content

/// Applies the shared native popover surface to arbitrary navigation content.
public struct SCNavigationMenuContent<Content: View>: View {
    @Environment(\.scNavigationMenuContext) private var context
    @Environment(\.theme) private var theme

    private let padding: CGFloat
    private let minimumWidth: CGFloat?
    private let idealWidth: CGFloat?
    private let maximumWidth: CGFloat?
    private let content: Content

    public init(
        padding: CGFloat = 8,
        minimumWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maximumWidth: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = max(padding, 0)
        self.minimumWidth = minimumWidth.map { max($0, 0) }
        self.idealWidth = idealWidth.map { max($0, 0) }
        self.maximumWidth = maximumWidth.map { max($0, 0) }
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(
                minWidth: minimumWidth,
                idealWidth: idealWidth,
                maxWidth: maximumWidth,
                alignment: .leading
            )
            .foregroundStyle(theme.popoverForeground)
            .presentationBackground(theme.popover)
            .presentationCompactAdaptation(.popover)
            .onHover { isHovered in
                if isHovered {
                    context.cancelScheduledClose()
                } else {
                    context.scheduleClose()
                }
            }
            .onKeyPress(.escape) {
                context.setValue(nil, .escapeKey)
                return .handled
            }
            .accessibilityElement(children: .contain)
    }
}

// MARK: - Links and actions

/// A real URL link with active styling and optional popup dismissal.
public struct SCNavigationMenuLink<Label: View>: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scNavigationMenuContext) private var context

    private let destination: URL
    private let isActive: Bool
    private let closesMenu: Bool
    private let presentation: SCNavigationMenuLinkPresentation
    private let label: Label

    public init(
        destination: URL,
        isActive: Bool = false,
        closesMenu: Bool = true,
        presentation: SCNavigationMenuLinkPresentation = .content,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.isActive = isActive
        self.closesMenu = closesMenu
        self.presentation = presentation
        self.label = label()
    }

    public var body: some View {
        Link(destination: destination) { label }
            .buttonStyle(.plain)
            .modifier(
                SCNavigationMenuLinkChrome(
                    isActive: isActive,
                    presentation: presentation
                )
            )
            .environment(
                \.openURL,
                OpenURLAction { url in
                    if closesMenu {
                        context.setValue(nil, .linkPress)
                    }
                    openURL(url)
                    return .handled
                }
            )
            .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

extension SCNavigationMenuLink where Label == Text {
    public init(
        _ title: String,
        destination: URL,
        isActive: Bool = false,
        closesMenu: Bool = true,
        presentation: SCNavigationMenuLinkPresentation = .content
    ) {
        self.init(
            destination: destination,
            isActive: isActive,
            closesMenu: closesMenu,
            presentation: presentation
        ) {
            Text(title)
        }
    }
}

/// A real value-based SwiftUI `NavigationLink` for in-app destinations.
public struct SCNavigationMenuNavigationLink<Value: Hashable, Label: View>: View {
    @Environment(\.scNavigationMenuContext) private var context

    private let value: Value
    private let isActive: Bool
    private let closesMenu: Bool
    private let presentation: SCNavigationMenuLinkPresentation
    private let label: Label

    public init(
        value: Value,
        isActive: Bool = false,
        closesMenu: Bool = true,
        presentation: SCNavigationMenuLinkPresentation = .content,
        @ViewBuilder label: () -> Label
    ) {
        self.value = value
        self.isActive = isActive
        self.closesMenu = closesMenu
        self.presentation = presentation
        self.label = label()
    }

    public var body: some View {
        NavigationLink(value: value) { label }
            .buttonStyle(.plain)
            .modifier(
                SCNavigationMenuLinkChrome(
                    isActive: isActive,
                    presentation: presentation
                )
            )
            .simultaneousGesture(
                TapGesture().onEnded {
                    closeAfterActivation()
                }
            )
            .onKeyPress(.return) {
                closeAfterActivation()
                return .ignored
            }
            .onKeyPress(.space) {
                closeAfterActivation()
                return .ignored
            }
            .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func closeAfterActivation() {
        guard closesMenu else { return }
        context.setValue(nil, .linkPress)
    }
}

/// A real native button for navigation-adjacent actions such as opening a
/// settings window. It is separate from Link so action semantics stay honest.
public struct SCNavigationMenuAction<Label: View>: View {
    @Environment(\.scNavigationMenuContext) private var context

    private let isActive: Bool
    private let isDisabled: Bool
    private let closesMenu: Bool
    private let presentation: SCNavigationMenuLinkPresentation
    private let action: () -> Void
    private let label: Label

    public init(
        isActive: Bool = false,
        isDisabled: Bool = false,
        closesMenu: Bool = true,
        presentation: SCNavigationMenuLinkPresentation = .content,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.isActive = isActive
        self.isDisabled = isDisabled
        self.closesMenu = closesMenu
        self.presentation = presentation
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button {
            if closesMenu {
                context.setValue(nil, .linkPress)
            }
            action()
        } label: {
            label
        }
        .buttonStyle(.plain)
        .modifier(
            SCNavigationMenuLinkChrome(
                isActive: isActive,
                presentation: presentation
            )
        )
        .disabled(isDisabled)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

private struct SCNavigationMenuLinkChrome: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.theme) private var theme

    let isActive: Bool
    let presentation: SCNavigationMenuLinkPresentation

    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(presentation == .trigger ? .medium : .regular))
            .padding(padding)
            .frame(
                maxWidth: presentation == .content ? .infinity : nil,
                minHeight: presentation == .trigger ? 36 : nil,
                alignment: .leading
            )
            .foregroundStyle(isHighlighted ? theme.accentForeground : theme.foreground)
            .background(
                isHighlighted ? theme.accent.opacity(isActive && !isHovered ? 0.5 : 1) : .clear,
                in: shape
            )
            .overlay {
                if isFocused {
                    shape.strokeBorder(theme.ring.opacity(0.5), lineWidth: 3)
                }
            }
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.12), value: isActive)
    }

    private var isHighlighted: Bool {
        isActive || (isHovered && isEnabled)
    }

    private var padding: EdgeInsets {
        switch presentation {
        case .content:
            return EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        case .trigger:
            return EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 3), style: .continuous)
    }
}

extension View {
    /// Applies the same link chrome used by `SCNavigationMenuLink` to a custom
    /// real control supplied by the caller.
    public func scNavigationMenuLinkStyle(
        _ presentation: SCNavigationMenuLinkPresentation = .content,
        isActive: Bool = false
    ) -> some View {
        modifier(
            SCNavigationMenuLinkChrome(
                isActive: isActive,
                presentation: presentation
            )
        )
    }
}

// MARK: - Previews

#Preview("Navigation Menu · controlled") {
    @Previewable @State var openItem: String?
    @Previewable @State var lastAction = "Choose a destination."

    SCPreview {
        VStack(alignment: .leading, spacing: 20) {
            SCNavigationMenu(value: $openItem) {
                SCNavigationMenuList {
                    SCNavigationMenuItem(value: "getting-started") {
                        SCNavigationMenuTrigger("Getting started")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 320) {
                            VStack(alignment: .leading, spacing: 4) {
                                SCNavigationMenuAction {
                                    lastAction = "Introduction"
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Introduction").fontWeight(.medium)
                                        Text("Reusable native SwiftUI components.")
                                            .font(.caption)
                                            .foregroundStyle(Theme.default.mutedForeground)
                                    }
                                }
                                SCNavigationMenuAction {
                                    lastAction = "Installation"
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Installation").fontWeight(.medium)
                                        Text("Add Swiftcn to a macOS or iPadOS app.")
                                            .font(.caption)
                                            .foregroundStyle(Theme.default.mutedForeground)
                                    }
                                }
                            }
                        }
                    }

                    SCNavigationMenuItem(value: "components") {
                        SCNavigationMenuTrigger("Components")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 360) {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 4
                            ) {
                                ForEach(["Alert Dialog", "Progress", "Tabs", "Tooltip"], id: \.self) { title in
                                    SCNavigationMenuAction {
                                        lastAction = title
                                    } label: {
                                        Text(title)
                                    }
                                }
                            }
                        }
                    }

                    SCNavigationMenuItem(value: "documentation") {
                        SCNavigationMenuAction(
                            presentation: .trigger,
                            action: { lastAction = "Documentation" },
                            label: { Text("Documentation") }
                        )
                    }
                }
            }

            Text(lastAction).scMuted()
        }
    }
    .frame(width: 700, height: 420)
}
