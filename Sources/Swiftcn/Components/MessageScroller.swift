// ============================================================
// MessageScroller.swift — swiftcn-ui
// Depends on: Theme/ · Button.swift · Effects/ScrollFade.swift
//
// SwiftUI port of shadcn/ui's MessageScroller (June 2026 chat
// release): the conversation scroll container with anchored
// turns, streamed replies, prepended history, jump-to-message,
// scroll controls, and visibility tracking. Upstream parts:
// MessageScrollerProvider · MessageScroller ·
// MessageScrollerViewport · MessageScrollerContent ·
// MessageScrollerItem · MessageScrollerButton, plus the
// useMessageScroller / useMessageScrollerVisibility /
// useMessageScrollerScrollable hooks. `SCMessageScrollerState`
// replaces the provider and the hooks, following the same
// adaptation as `SCSidebarState`.
//
//     SCMessageScroller {
//         SCMessageScrollerViewport {
//             SCMessageScrollerContent {
//                 ForEach(messages) { message in
//                     SCMessageScrollerItem(
//                         messageId: message.id,
//                         scrollAnchor: message.isFromUser
//                     ) {
//                         SCMessage { … }
//                     }
//                 }
//             }
//         }
//         SCMessageScrollerButton()
//     }
// ============================================================
import SwiftUI

// MARK: - Position

/// Where a saved thread opens — shadcn's `defaultScrollPosition` prop on
/// `MessageScrollerProvider`.
public enum SCMessageScrollerPosition: CaseIterable, Equatable, Hashable, Sendable {
    /// The oldest message.
    case start
    /// The newest message (the default).
    case end
    /// The last anchored turn, positioned near the top of the viewport.
    case lastAnchor
}

/// Which end a scroll control targets — shadcn's `direction` prop on
/// `MessageScrollerButton`.
public enum SCMessageScrollerButtonDirection: CaseIterable, Equatable, Hashable, Sendable {
    case start
    case end
}

public enum SCMessageScrollerScrollAlignment: CaseIterable, Equatable, Hashable, Sendable {
    case start
    case center
    case end
    case nearest
}

public struct SCMessageScrollerScrollOptions: Equatable, Sendable {
    public var alignment: SCMessageScrollerScrollAlignment
    public var animated: Bool
    public var scrollMargin: CGFloat?

    public init(
        alignment: SCMessageScrollerScrollAlignment = .start,
        animated: Bool = true,
        scrollMargin: CGFloat? = nil
    ) {
        self.alignment = alignment
        self.animated = animated
        self.scrollMargin = scrollMargin
    }
}

// MARK: - State

/// Shared scroller state — the SwiftUI analog of shadcn's
/// `MessageScrollerProvider` plus the `useMessageScroller`,
/// `useMessageScrollerVisibility`, and `useMessageScrollerScrollable`
/// hooks. `SCMessageScroller` owns one (or accepts yours) and injects it
/// into the environment; read it anywhere via
/// `@Environment(\.scMessageScroller)`.
///
///     let scroller = SCMessageScrollerState(defaultScrollPosition: .lastAnchor)
///     scroller.scrollToMessage("message-41")
@Observable
public final class SCMessageScrollerState: @unchecked Sendable {
    /// Pins the viewport to the live edge of the conversation while
    /// streamed content grows — but only while the reader is already at
    /// the end. Scrolling up is a deliberate opt-out, exactly as upstream.
    public var autoScroll: Bool
    /// Where the thread opens on first layout.
    public var defaultScrollPosition: SCMessageScrollerPosition {
        didSet {
            if oldValue != defaultScrollPosition {
                appliedInitialPosition = false
            }
        }
    }
    /// Distance from an edge before that direction is considered scrollable.
    public var scrollEdgeThreshold: CGFloat
    /// Points of the previous turn left visible above an anchored row —
    /// shadcn's `scrollPreviousItemPeek`.
    public var scrollPreviousItemPeek: CGFloat
    /// Margin retained around imperative scroll targets.
    public var scrollMargin: CGFloat

    /// Identifiers of the rows currently intersecting the viewport, in
    /// document order — `useMessageScrollerVisibility().visibleMessageIds`.
    public private(set) var visibleMessageIds: [String] = []
    /// The anchored turn currently governing the view —
    /// `useMessageScrollerVisibility().currentAnchorId`.
    public private(set) var currentAnchorId: String?
    /// Whether content extends beyond the top of the viewport —
    /// `useMessageScrollerScrollable().start`.
    public private(set) var canScrollToStart = false
    /// Whether content extends beyond the bottom of the viewport —
    /// `useMessageScrollerScrollable().end`.
    public private(set) var canScrollToEnd = false
    /// Whether the reader is at the live edge of the conversation.
    public private(set) var isAtEnd = true

    /// Creates scroller state.
    /// - Parameters:
    ///   - autoScroll: Follow streamed content while at the end. Defaults
    ///     to `false`, matching the published primitive.
    ///   - defaultScrollPosition: Where the thread opens. Defaults to
    ///     `.end`.
    ///   - scrollEdgeThreshold: Distance from an edge before its scroll
    ///     control becomes active. Defaults to 8.
    ///   - scrollPreviousItemPeek: Previous-turn peek above anchored rows,
    ///     in points. Defaults to 64.
    ///   - scrollMargin: Margin retained around imperative targets. Defaults
    ///     to zero.
    public init(
        autoScroll: Bool = false,
        defaultScrollPosition: SCMessageScrollerPosition = .end,
        scrollEdgeThreshold: CGFloat = 8,
        scrollPreviousItemPeek: CGFloat = 64,
        scrollMargin: CGFloat = 0
    ) {
        self.autoScroll = autoScroll
        self.defaultScrollPosition = defaultScrollPosition
        self.scrollEdgeThreshold = max(scrollEdgeThreshold, 0)
        self.scrollPreviousItemPeek = max(scrollPreviousItemPeek, 0)
        self.scrollMargin = max(scrollMargin, 0)
    }

    // MARK: Commands

    /// Scrolls an anchored (or any registered) row near the top of the
    /// viewport — shadcn's `scrollToMessage`. Returns `false` when no row
    /// with that identifier is currently part of the transcript.
    @discardableResult
    public func scrollToMessage(_ messageId: String, animated: Bool = true) -> Bool {
        scrollToMessage(
            messageId,
            options: SCMessageScrollerScrollOptions(animated: animated)
        )
    }

    /// Scrolls to a registered row using the requested native alignment and
    /// margin. A request made before the first transcript rows arrive is held
    /// and executed when that identifier registers.
    @discardableResult
    public func scrollToMessage(
        _ messageId: String,
        options: SCMessageScrollerScrollOptions
    ) -> Bool {
        guard let item = items.first(where: { $0.id == messageId }) else {
            guard items.isEmpty else { return false }
            pendingMessageRequest = SCMessageScrollerPendingMessageRequest(
                messageId: messageId,
                options: options
            )
            return true
        }
        guard viewportHeight > 0 else {
            pendingMessageRequest = SCMessageScrollerPendingMessageRequest(
                messageId: messageId,
                options: options
            )
            return true
        }
        guard let anchor = commandAnchor(for: item, options: options) else { return true }
        pendingMessageRequest = nil
        send(.message(messageId, anchor), animated: options.animated)
        return true
    }

    /// Scrolls to the newest message and re-engages follow-output —
    /// shadcn's `scrollToEnd`.
    @discardableResult
    public func scrollToEnd(animated: Bool = true) -> Bool {
        send(.end, animated: animated)
        return true
    }

    /// Scrolls to the oldest message — shadcn's `scrollToStart`.
    @discardableResult
    public func scrollToStart(animated: Bool = true) -> Bool {
        send(.start, animated: animated)
        return true
    }

    // MARK: Internal plumbing

    private(set) var pendingCommand: SCMessageScrollerCommand?

    @ObservationIgnored private var items: [SCMessageScrollerItemInfo] = []
    @ObservationIgnored private var itemIds: [String] = []
    @ObservationIgnored private var viewportHeight: CGFloat = 0
    @ObservationIgnored private var contentHeight: CGFloat = 0
    @ObservationIgnored private var scrollOffset: CGFloat = 0
    @ObservationIgnored private var atEndInternal = true
    @ObservationIgnored private var hasInitialLayout = false
    @ObservationIgnored private var appliedInitialPosition = false
    @ObservationIgnored private var suppressNextFollow = false
    @ObservationIgnored private var preserveScrollOnPrepend = true
    @ObservationIgnored private var serial = 0
    @ObservationIgnored private var topVisible: SCMessageScrollerItemInfo?
    @ObservationIgnored private var pendingMessageRequest: SCMessageScrollerPendingMessageRequest?

    func updateGeometry(contentFrame: CGRect, viewportHeight: CGFloat) {
        self.viewportHeight = viewportHeight
        let offset = -contentFrame.minY
        scrollOffset = offset
        let distanceToEnd = contentFrame.height - viewportHeight - offset
        let previousHeight = contentHeight
        contentHeight = contentFrame.height
        let wasAtEnd = atEndInternal
        atEndInternal = distanceToEnd <= scrollEdgeThreshold

        setIfChanged(\.isAtEnd, to: atEndInternal)
        setIfChanged(\.canScrollToStart, to: offset > scrollEdgeThreshold)
        setIfChanged(\.canScrollToEnd, to: distanceToEnd > scrollEdgeThreshold)

        if flushPendingMessageRequest() {
            suppressNextFollow = true
        }

        if !hasInitialLayout {
            hasInitialLayout = true
            applyInitialPositionIfNeeded()
        } else if autoScroll, wasAtEnd, !suppressNextFollow, contentHeight > previousHeight + 0.5 {
            // Follow-output: keep the live edge in view while streaming.
            send(.end, animated: false)
        }
        suppressNextFollow = false
        recomputeVisibility()
    }

    func updateItems(_ newItems: [SCMessageScrollerItemInfo]) {
        let previousIds = itemIds
        let newIds = newItems.map(\.id)
        items = newItems
        itemIds = newIds
        defer { recomputeVisibility() }
        if flushPendingMessageRequest() {
            suppressNextFollow = true
            return
        }
        if hasInitialLayout {
            applyInitialPositionIfNeeded()
        }
        guard hasInitialLayout, !previousIds.isEmpty, previousIds != newIds else { return }

        let prependedIndex = previousIds.first.flatMap { newIds.firstIndex(of: $0) } ?? 0
        let appendedItems = appendedItems(previousIds: previousIds, newIds: newIds, newItems: newItems)
        if preserveScrollOnPrepend, prependedIndex > 0 {
            // History was prepended: hold the previously visible row in
            // place so the reader stays where they were.
            if let snapshot = topVisible, newIds.contains(snapshot.id) {
                send(.message(snapshot.id, restorePoint(for: snapshot)), animated: false)
                suppressNextFollow = true
            }
        } else if let anchor = appendedItems.first(where: \.isAnchor) {
            // Turn anchoring: a new anchored turn settles near the top with
            // a peek of the previous exchange left visible above it.
            let appendedAnchorCount = appendedItems.filter(\.isAnchor).count
            if autoScroll, atEndInternal, appendedAnchorCount > 1 {
                send(.end, animated: false)
            } else {
                send(.message(anchor.id, anchorPoint(itemHeight: anchor.frame.height)), animated: true)
            }
            suppressNextFollow = true
        }
    }

    /// The rows appended after the previously last-known row, in document
    /// order — the candidates for turn anchoring.
    private func appendedItems(
        previousIds: [String],
        newIds: [String],
        newItems: [SCMessageScrollerItemInfo]
    ) -> ArraySlice<SCMessageScrollerItemInfo> {
        guard let previousLast = previousIds.last,
            let lastIndex = newIds.firstIndex(of: previousLast),
            lastIndex + 1 < newItems.count
        else { return [] }
        return newItems[(lastIndex + 1)...]
    }

    /// Applies `defaultScrollPosition` once, as soon as both the geometry
    /// and the transcript rows have registered. `.start` and `.end` are
    /// handled declaratively by `defaultScrollAnchor` in the viewport.
    private func applyInitialPositionIfNeeded() {
        guard !appliedInitialPosition else { return }
        guard defaultScrollPosition == .lastAnchor else {
            appliedInitialPosition = true
            return
        }
        guard let anchor = items.last(where: \.isAnchor) else { return }
        let anchorTopInContent = scrollOffset + anchor.frame.minY
        if contentHeight - anchorTopInContent <= viewportHeight {
            send(.end, animated: false)
        } else {
            send(.message(anchor.id, anchorPoint(itemHeight: anchor.frame.height)), animated: false)
        }
        appliedInitialPosition = true
    }

    private func recomputeVisibility() {
        guard viewportHeight > 0 else { return }
        let visible = items.filter { $0.frame.maxY > 0 && $0.frame.minY < viewportHeight }
        setIfChanged(\.visibleMessageIds, to: visible.map(\.id))
        let current =
            items.last(where: {
                $0.isAnchor && $0.frame.minY <= scrollMargin + scrollPreviousItemPeek + 0.5
            })?.id
            ?? visible.first(where: \.isAnchor)?.id
        setIfChanged(\.currentAnchorId, to: current)
        if let top = visible.first {
            topVisible = top
        }
    }

    private func send(_ kind: SCMessageScrollerCommand.Kind, animated: Bool) {
        serial += 1
        pendingCommand = SCMessageScrollerCommand(serial: serial, kind: kind, animated: animated)
    }

    /// The `scrollTo` anchor that puts a row's top `scrollPreviousItemPeek`
    /// points below the viewport top. `scrollTo` aligns the same relative
    /// point of row and viewport, so solve
    /// `rowTop = f * (viewportHeight - rowHeight)` for `f`.
    private func anchorPoint(itemHeight: CGFloat, target: CGFloat? = nil) -> UnitPoint {
        let room = viewportHeight - itemHeight
        guard room > 1 else { return .top }
        let fraction = min(max((target ?? (scrollMargin + scrollPreviousItemPeek)) / room, 0), 1)
        return UnitPoint(x: 0.5, y: fraction)
    }

    private func restorePoint(for snapshot: SCMessageScrollerItemInfo) -> UnitPoint {
        anchorPoint(itemHeight: snapshot.frame.height, target: snapshot.frame.minY)
    }

    private func commandAnchor(
        for item: SCMessageScrollerItemInfo,
        options: SCMessageScrollerScrollOptions
    ) -> UnitPoint? {
        let margin = max(options.scrollMargin ?? scrollMargin, 0)
        switch options.alignment {
        case .start:
            return anchorPoint(itemHeight: item.frame.height, target: margin)
        case .center:
            return .center
        case .end:
            return anchorPoint(
                itemHeight: item.frame.height,
                target: max(viewportHeight - item.frame.height - margin, 0)
            )
        case .nearest:
            let visibleStart = margin
            let visibleEnd = viewportHeight - margin
            if item.frame.minY >= visibleStart, item.frame.maxY <= visibleEnd {
                return nil
            }
            if item.frame.minY < visibleStart {
                return anchorPoint(itemHeight: item.frame.height, target: margin)
            }
            return anchorPoint(
                itemHeight: item.frame.height,
                target: max(viewportHeight - item.frame.height - margin, 0)
            )
        }
    }

    private func flushPendingMessageRequest() -> Bool {
        guard viewportHeight > 0,
            let request = pendingMessageRequest,
            let item = items.first(where: { $0.id == request.messageId })
        else { return false }
        pendingMessageRequest = nil
        guard let anchor = commandAnchor(for: item, options: request.options) else { return true }
        send(.message(item.id, anchor), animated: request.options.animated)
        return true
    }

    func setPreservesScrollOnPrepend(_ preserves: Bool) {
        preserveScrollOnPrepend = preserves
    }

    private func setIfChanged<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<SCMessageScrollerState, Value>,
        to newValue: Value
    ) {
        if self[keyPath: keyPath] != newValue {
            self[keyPath: keyPath] = newValue
        }
    }
}

// MARK: - Internal types

struct SCMessageScrollerItemInfo: Equatable {
    var id: String
    var isAnchor: Bool
    var frame: CGRect
}

struct SCMessageScrollerCommand: Equatable {
    var serial: Int
    var kind: Kind
    var animated: Bool

    enum Kind: Equatable {
        case message(String, UnitPoint)
        case end
        case start
    }
}

private struct SCMessageScrollerPendingMessageRequest: Equatable {
    var messageId: String
    var options: SCMessageScrollerScrollOptions
}

private struct SCMessageScrollerItemsKey: PreferenceKey {
    static let defaultValue: [SCMessageScrollerItemInfo] = []

    static func reduce(value: inout [SCMessageScrollerItemInfo], nextValue: () -> [SCMessageScrollerItemInfo]) {
        value.append(contentsOf: nextValue())
    }
}

private struct SCMessageScrollerContentFrameKey: PreferenceKey {
    static let defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private enum SCMessageScrollerLayout {
    static let coordinateSpace = "SCMessageScrollerViewport"
    static let startSentinel = "sc-message-scroller-start"
    static let endSentinel = "sc-message-scroller-end"
}

// MARK: - Environment

private struct SCMessageScrollerStateKey: EnvironmentKey {
    static let defaultValue = SCMessageScrollerState()
}

extension EnvironmentValues {
    /// The enclosing scroller's state — swiftcn's `useMessageScroller`.
    /// Read it to jump, follow, or inspect visibility from anywhere inside
    /// `SCMessageScroller`.
    public internal(set) var scMessageScroller: SCMessageScrollerState {
        get { self[SCMessageScrollerStateKey.self] }
        set { self[SCMessageScrollerStateKey.self] = newValue }
    }
}

// MARK: - Scroller

/// The conversation frame — shadcn's `MessageScroller` root (and, when no
/// external state is passed, its `MessageScrollerProvider`). Hosts the
/// viewport plus floating scroll controls.
///
///     SCMessageScroller {
///         SCMessageScrollerViewport { SCMessageScrollerContent { rows } }
///         SCMessageScrollerButton()
///     }
public struct SCMessageScroller<Content: View>: View {
    private let externalState: SCMessageScrollerState?
    @State private var ownedState = SCMessageScrollerState()
    @ViewBuilder private var content: Content

    /// Creates a message scroller.
    /// - Parameters:
    ///   - state: Pass your own `SCMessageScrollerState` to configure
    ///     behavior and drive the scroller from outside; `nil` lets the
    ///     scroller own one.
    ///   - content: An `SCMessageScrollerViewport` and, optionally,
    ///     `SCMessageScrollerButton`s.
    public init(state: SCMessageScrollerState? = nil, @ViewBuilder content: () -> Content) {
        self.externalState = state
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
        }
        .clipped()
        .environment(\.scMessageScroller, externalState ?? ownedState)
    }
}

// MARK: - Viewport

/// The scrollable element — shadcn's `MessageScrollerViewport`. Applies
/// the bottom scroll-fade, executes scroll commands, publishes geometry to
/// the scroller state, and (on iOS) dismisses the keyboard interactively.
public struct SCMessageScrollerViewport<Content: View>: View {
    @Environment(\.scMessageScroller) private var state

    private let preserveScrollOnPrepend: Bool
    private let showsIndicators: Bool
    private let accessibilityLabel: String
    @ViewBuilder private var content: Content

    /// Creates the viewport. Put an `SCMessageScrollerContent` inside.
    public init(
        preserveScrollOnPrepend: Bool = true,
        showsIndicators: Bool = true,
        accessibilityLabel: String = "Messages",
        @ViewBuilder content: () -> Content
    ) {
        self.preserveScrollOnPrepend = preserveScrollOnPrepend
        self.showsIndicators = showsIndicators
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        GeometryReader { outer in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: showsIndicators) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 1)
                            .id(SCMessageScrollerLayout.startSentinel)
                        content
                        Color.clear
                            .frame(height: 1)
                            .id(SCMessageScrollerLayout.endSentinel)
                    }
                    .background {
                        GeometryReader { inner in
                            Color.clear.preference(
                                key: SCMessageScrollerContentFrameKey.self,
                                value: inner.frame(in: .named(SCMessageScrollerLayout.coordinateSpace))
                            )
                        }
                    }
                }
                .coordinateSpace(.named(SCMessageScrollerLayout.coordinateSpace))
                .defaultScrollAnchor(state.defaultScrollPosition == .start ? .top : .bottom)
                .scScrollFade(.bottom)
                .scMessageScrollerKeyboardBehavior()
                .focusable()
                .accessibilityLabel(Text(accessibilityLabel))
                .accessibilityElement(children: .contain)
                .onAppear {
                    state.setPreservesScrollOnPrepend(preserveScrollOnPrepend)
                    execute(state.pendingCommand, with: proxy)
                }
                .onChange(of: preserveScrollOnPrepend) { _, preserves in
                    state.setPreservesScrollOnPrepend(preserves)
                }
                .onPreferenceChange(SCMessageScrollerContentFrameKey.self) { frame in
                    state.updateGeometry(contentFrame: frame, viewportHeight: outer.size.height)
                }
                .onPreferenceChange(SCMessageScrollerItemsKey.self) { items in
                    state.updateItems(items)
                }
                .onChange(of: state.pendingCommand) { _, command in
                    execute(command, with: proxy)
                }
            }
        }
    }

    private func execute(_ command: SCMessageScrollerCommand?, with proxy: ScrollViewProxy) {
        guard let command else { return }
        let scroll = {
            switch command.kind {
            case .message(let id, let anchor):
                proxy.scrollTo(id, anchor: anchor)
            case .end:
                proxy.scrollTo(SCMessageScrollerLayout.endSentinel, anchor: .bottom)
            case .start:
                proxy.scrollTo(SCMessageScrollerLayout.startSentinel, anchor: .top)
            }
        }
        if command.animated {
            withAnimation(.easeOut(duration: 0.25), scroll)
        } else {
            scroll()
        }
    }
}

extension View {
    fileprivate func scMessageScrollerKeyboardBehavior() -> some View {
        #if os(iOS)
            return scrollDismissesKeyboard(.interactively)
        #else
            return self
        #endif
    }
}

// MARK: - Content

/// The transcript container — shadcn's `MessageScrollerContent`. Upstream
/// keeps every row mounted (skipping offscreen rendering with
/// `content-visibility: auto`); the Swift port mirrors that with a plain
/// `VStack`, which is what keeps jump-to-message and visibility tracking
/// reliable.
public struct SCMessageScrollerContent<Content: View>: View {
    private let spacing: CGFloat
    @ViewBuilder private var content: Content

    /// Creates the transcript container. Put `SCMessageScrollerItem`s inside.
    public init(spacing: CGFloat = 32, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Item

/// A transcript row boundary — shadcn's `MessageScrollerItem`. Registers
/// the row for jump-to-message and visibility tracking; `scrollAnchor`
/// marks it as a turn boundary that settles near the viewport top when it
/// arrives.
///
///     SCMessageScrollerItem(messageId: message.id, scrollAnchor: message.isFromUser) {
///         SCMessage { … }
///     }
public struct SCMessageScrollerItem<Content: View>: View {
    private let messageId: String?
    private let scrollAnchor: Bool
    @ViewBuilder private var content: Content

    /// Creates a transcript row.
    /// - Parameters:
    ///   - messageId: Optional stable identifier used by `scrollToMessage`
    ///     and visibility tracking. Omit it for transient unregistered rows.
    ///   - scrollAnchor: Marks the row as a turn boundary.
    ///   - content: The row content — usually an `SCMessage`.
    public init(
        messageId: String? = nil,
        scrollAnchor: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.messageId = messageId
        self.scrollAnchor = scrollAnchor
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        if let messageId {
            content
                .id(messageId)
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: SCMessageScrollerItemsKey.self,
                            value: [
                                SCMessageScrollerItemInfo(
                                    id: messageId,
                                    isAnchor: scrollAnchor,
                                    frame: proxy.frame(
                                        in: .named(SCMessageScrollerLayout.coordinateSpace)
                                    )
                                )
                            ]
                        )
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Button

/// A floating scroll control — shadcn's `MessageScrollerButton`. Appears
/// when there is content beyond its direction, scrolls there on tap, and
/// inerts itself (no hit testing, hidden from assistive technologies)
/// while inactive, exactly like upstream's `data-active="false"`.
public struct SCMessageScrollerButton<Label: View>: View {
    @Environment(\.scMessageScroller) private var state
    @FocusState private var isFocused: Bool

    private let direction: SCMessageScrollerButtonDirection
    private let variant: SCButtonVariant
    private let size: SCButtonSize
    private let animated: Bool
    private let rotatesLabelForStart: Bool
    @ViewBuilder private var label: Label

    /// Creates a scroll control with a custom label.
    public init(
        direction: SCMessageScrollerButtonDirection = .end,
        variant: SCButtonVariant = .secondary,
        size: SCButtonSize = .iconSM,
        animated: Bool = true,
        rotatesLabelForStart: Bool = false,
        @ViewBuilder label: () -> Label
    ) {
        self.direction = direction
        self.variant = variant
        self.size = size
        self.animated = animated
        self.rotatesLabelForStart = rotatesLabelForStart
        self.label = label()
    }

    public var body: some View {
        Button(action: activate) {
            label.rotationEffect(
                direction == .start && rotatesLabelForStart ? .degrees(180) : .zero
            )
        }
        .buttonStyle(.sc(variant, size: size))
        .focused($isFocused)
        .accessibilityLabel(Text(direction == .end ? "Scroll to end" : "Scroll to start"))
        .opacity(isActive ? 1 : 0)
        .scaleEffect(isActive ? 1 : 0.95)
        .offset(y: isActive ? 0 : (direction == .end ? 16 : -16))
        .animation(.easeOut(duration: 0.2), value: isActive)
        .allowsHitTesting(isActive)
        .accessibilityHidden(!isActive)
        .padding(direction == .end ? .bottom : .top, 16)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: direction == .end ? .bottom : .top
        )
    }

    private var isActive: Bool {
        direction == .end ? state.canScrollToEnd : state.canScrollToStart
    }

    private func activate() {
        isFocused = false
        if direction == .end {
            state.scrollToEnd(animated: animated)
        } else {
            state.scrollToStart(animated: animated)
        }
    }
}

extension SCMessageScrollerButton where Label == Image {
    /// Creates the default arrow control.
    public init(
        direction: SCMessageScrollerButtonDirection = .end,
        variant: SCButtonVariant = .secondary,
        size: SCButtonSize = .iconSM,
        animated: Bool = true
    ) {
        self.init(
            direction: direction,
            variant: variant,
            size: size,
            animated: animated,
            rotatesLabelForStart: true
        ) {
            Image(systemName: "arrow.down")
        }
    }
}

// MARK: - Previews

private struct SCMessageScrollerPreviewMessage: Identifiable {
    let id: String
    var text: String
    let fromUser: Bool
}

#Preview("MessageScroller · conversation") {
    @Previewable @State var messages: [SCMessageScrollerPreviewMessage] = [
        .init(id: "m1", text: "The scroll behavior in our chat is driving me nuts.", fromUser: true),
        .init(
            id: "m2",
            text: "Wrap the list in a MessageScroller and turn on autoScroll — "
                + "the viewport pins to the bottom as tokens arrive.",
            fromUser: false
        ),
        .init(id: "m3", text: "And when someone sends a new message?", fromUser: true),
        .init(
            id: "m4",
            text: "Turn anchoring settles the new turn near the top, with a peek "
                + "of the previous exchange above it.",
            fromUser: false
        ),
    ]
    @Previewable @State var draft = 0

    SCPreview {
        VStack(spacing: 8) {
            SCMessageScroller {
                SCMessageScrollerViewport {
                    SCMessageScrollerContent {
                        ForEach(messages) { message in
                            SCMessageScrollerItem(messageId: message.id, scrollAnchor: message.fromUser) {
                                SCMessage(align: message.fromUser ? .end : .start) {
                                    SCMessageContent {
                                        SCBubble(
                                            variant: message.fromUser ? .default : .muted,
                                            align: message.fromUser ? .end : .start
                                        ) {
                                            SCBubbleContent(message.text)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                SCMessageScrollerButton()
            }
            .frame(width: 360, height: 320)
            Button("Send message") {
                draft += 1
                messages.append(.init(id: "d\(draft)", text: "Follow-up question #\(draft)?", fromUser: true))
            }
            .buttonStyle(.sc(.outline, size: .sm))
        }
    }
}

#Preview("MessageScroller · jump & visibility") {
    @Previewable @State var scroller = SCMessageScrollerState(defaultScrollPosition: .end)

    SCPreview {
        VStack(spacing: 8) {
            SCMessageScroller(state: scroller) {
                SCMessageScrollerViewport {
                    SCMessageScrollerContent {
                        ForEach(1...20, id: \.self) { index in
                            SCMessageScrollerItem(messageId: "m\(index)", scrollAnchor: index.isMultiple(of: 5)) {
                                SCMessage {
                                    SCMessageContent {
                                        SCBubble(variant: .muted) { SCBubbleContent("Message #\(index)") }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                SCMessageScrollerButton()
            }
            .frame(width: 360, height: 300)
            HStack(spacing: 8) {
                Button("Jump to #5") { scroller.scrollToMessage("m5") }
                    .buttonStyle(.sc(.outline, size: .sm))
                Button("Start") { scroller.scrollToStart() }
                    .buttonStyle(.sc(.outline, size: .sm))
                Button("End") { scroller.scrollToEnd() }
                    .buttonStyle(.sc(.outline, size: .sm))
            }
            Text("Anchor: \(scroller.currentAnchorId ?? "none") · visible: \(scroller.visibleMessageIds.count)")
                .scMuted()
        }
    }
}
