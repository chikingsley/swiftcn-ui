// ============================================================
// Carousel.swift — swiftcn-ui
// Depends on: Theme/, Button.swift
// ============================================================
import Combine
import SwiftUI

// MARK: - State and options

public enum SCCarouselOrientation: CaseIterable, Sendable {
    case horizontal, vertical
}

/// An extension point for autoplay, analytics, or other carousel behaviors.
public protocol SCCarouselPlugin {
    func connect(to state: SCCarouselState)
    func disconnect(from state: SCCarouselState)
}

extension SCCarouselPlugin {
    public func disconnect(from state: SCCarouselState) {}
}

/// The caller-observable API for selection and previous/next navigation.
public final class SCCarouselState: ObservableObject {
    @Published public private(set) var currentID: AnyHashable?
    @Published public private(set) var itemIDs: [AnyHashable] = []

    public private(set) var orientation: SCCarouselOrientation
    public private(set) var wrapsNavigation: Bool
    public private(set) var itemsPerPage: Int
    public private(set) var spacing: CGFloat

    public init(
        initialID: AnyHashable? = nil,
        orientation: SCCarouselOrientation = .horizontal,
        wrapsNavigation: Bool = false,
        itemsPerPage: Int = 1,
        spacing: CGFloat = 16
    ) {
        currentID = initialID
        self.orientation = orientation
        self.wrapsNavigation = wrapsNavigation
        self.itemsPerPage = max(itemsPerPage, 1)
        self.spacing = max(spacing, 0)
    }

    public var currentIndex: Int {
        guard let currentID, let index = itemIDs.firstIndex(of: currentID) else { return 0 }
        return index
    }

    public var canScrollPrevious: Bool {
        itemIDs.count > 1 && (wrapsNavigation || currentIndex > 0)
    }

    public var canScrollNext: Bool {
        itemIDs.count > 1 && (wrapsNavigation || currentIndex < itemIDs.count - 1)
    }

    public func scrollPrevious() {
        scroll(toIndex: currentIndex - 1)
    }

    public func scrollNext() {
        scroll(toIndex: currentIndex + 1)
    }

    public func scroll(to id: AnyHashable) {
        guard itemIDs.contains(id) else { return }
        withAnimation(.snappy(duration: 0.3)) {
            currentID = id
        }
    }

    public func scroll(toIndex index: Int) {
        guard !itemIDs.isEmpty else { return }
        let resolved: Int
        if wrapsNavigation {
            resolved = (index % itemIDs.count + itemIDs.count) % itemIDs.count
        } else {
            resolved = min(max(index, 0), itemIDs.count - 1)
        }
        scroll(to: itemIDs[resolved])
    }

    fileprivate func configure(
        orientation: SCCarouselOrientation,
        wrapsNavigation: Bool,
        itemsPerPage: Int,
        spacing: CGFloat
    ) {
        self.orientation = orientation
        self.wrapsNavigation = wrapsNavigation
        self.itemsPerPage = max(itemsPerPage, 1)
        self.spacing = max(spacing, 0)
    }

    fileprivate func register(_ ids: [AnyHashable]) {
        guard itemIDs != ids else { return }
        itemIDs = ids
        if let currentID, ids.contains(currentID) { return }
        currentID = ids.first
    }

    fileprivate func updateSelection(_ id: AnyHashable?) {
        guard currentID != id else { return }
        currentID = id
    }
}

// MARK: - Root

/// A composable carousel root that provides a shared external-control state.
public struct SCCarousel<Content: View>: View {
    @StateObject private var state: SCCarouselState

    private let orientation: SCCarouselOrientation
    private let wrapsNavigation: Bool
    private let itemsPerPage: Int
    private let spacing: CGFloat
    private let accessibilityLabel: String
    private let plugins: [any SCCarouselPlugin]
    private let onSelectionChange: ((AnyHashable?) -> Void)?
    private let content: Content

    public init(
        state: SCCarouselState = SCCarouselState(),
        orientation: SCCarouselOrientation = .horizontal,
        wrapsNavigation: Bool = false,
        itemsPerPage: Int = 1,
        spacing: CGFloat = 16,
        accessibilityLabel: String = "Carousel",
        plugins: [any SCCarouselPlugin] = [],
        onSelectionChange: ((AnyHashable?) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._state = StateObject(wrappedValue: state)
        self.orientation = orientation
        self.wrapsNavigation = wrapsNavigation
        self.itemsPerPage = max(itemsPerPage, 1)
        self.spacing = max(spacing, 0)
        self.accessibilityLabel = accessibilityLabel
        self.plugins = plugins
        self.onSelectionChange = onSelectionChange
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
        }
        .environmentObject(state)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(accessibilityLabel))
        .onAppear {
            configure()
            for plugin in plugins { plugin.connect(to: state) }
        }
        .onDisappear {
            for plugin in plugins { plugin.disconnect(from: state) }
        }
        .onChange(of: orientation) { _, _ in configure() }
        .onChange(of: wrapsNavigation) { _, _ in configure() }
        .onChange(of: itemsPerPage) { _, _ in configure() }
        .onChange(of: spacing) { _, _ in configure() }
        .onChange(of: state.currentID) { _, newValue in
            onSelectionChange?(newValue)
        }
        .onKeyPress(.leftArrow) {
            guard orientation == .horizontal else { return .ignored }
            state.scrollPrevious()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            guard orientation == .horizontal else { return .ignored }
            state.scrollNext()
            return .handled
        }
        .onKeyPress(.upArrow) {
            guard orientation == .vertical else { return .ignored }
            state.scrollPrevious()
            return .handled
        }
        .onKeyPress(.downArrow) {
            guard orientation == .vertical else { return .ignored }
            state.scrollNext()
            return .handled
        }
    }

    private func configure() {
        state.configure(
            orientation: orientation,
            wrapsNavigation: wrapsNavigation,
            itemsPerPage: itemsPerPage,
            spacing: spacing
        )
    }
}

// MARK: - Content

private struct SCCarouselItemIDsKey: PreferenceKey {
    static var defaultValue: [AnyHashable] { [] }

    static func reduce(value: inout [AnyHashable], nextValue: () -> [AnyHashable]) {
        for id in nextValue() where !value.contains(id) {
            value.append(id)
        }
    }
}

/// The scroll viewport and snapping track for carousel items.
public struct SCCarouselContent<Content: View>: View {
    @EnvironmentObject private var state: SCCarouselState
    @Environment(\.isEnabled) private var isEnabled

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView(state.orientation == .horizontal ? .horizontal : .vertical) {
            track
                .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: selectionBinding)
        .scrollIndicators(.hidden)
        .scrollDisabled(!isEnabled)
        .onPreferenceChange(SCCarouselItemIDsKey.self, perform: state.register)
        .accessibilityValue(
            Text("Slide \(state.currentIndex + 1) of \(max(state.itemIDs.count, 1))")
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: state.scrollNext()
            case .decrement: state.scrollPrevious()
            @unknown default: break
            }
        }
    }

    @ViewBuilder
    private var track: some View {
        switch state.orientation {
        case .horizontal:
            HStack(spacing: state.spacing) { content }
        case .vertical:
            VStack(spacing: state.spacing) { content }
        }
    }

    private var selectionBinding: Binding<AnyHashable?> {
        Binding {
            state.currentID
        } set: { value in
            state.updateSelection(value)
        }
    }
}

/// One identified, accessible slide in a carousel content track.
public struct SCCarouselItem<ID: Hashable, Content: View>: View {
    @EnvironmentObject private var state: SCCarouselState

    private let id: ID
    private let span: Int
    private let accessibilityLabel: String?
    private let content: Content

    public init(
        id: ID,
        span: Int = 1,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.span = max(span, 1)
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        Group {
            switch state.orientation {
            case .horizontal:
                content.containerRelativeFrame(
                    .horizontal,
                    count: state.itemsPerPage,
                    span: min(span, state.itemsPerPage),
                    spacing: state.spacing
                )
            case .vertical:
                content.containerRelativeFrame(
                    .vertical,
                    count: state.itemsPerPage,
                    span: min(span, state.itemsPerPage),
                    spacing: state.spacing
                )
            }
        }
        .id(AnyHashable(id))
        .preference(key: SCCarouselItemIDsKey.self, value: [AnyHashable(id)])
        .accessibilityElement(children: .contain)
        .modifier(SCCarouselOptionalLabel(label: accessibilityLabel))
    }
}

private struct SCCarouselOptionalLabel: ViewModifier {
    var label: String?

    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(Text(label))
        } else {
            content
        }
    }
}

// MARK: - Controls

/// The previous-slide control, positioned from the carousel orientation.
public struct SCCarouselPrevious<Label: View>: View {
    @EnvironmentObject private var state: SCCarouselState

    private let variant: SCButtonVariant
    private let size: SCButtonSize
    private let rotatesForVertical: Bool
    private let label: Label

    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .iconSM,
        rotatesForVertical: Bool = false,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.rotatesForVertical = rotatesForVertical
        self.label = label()
    }

    public var body: some View {
        Button(action: state.scrollPrevious) {
            label.rotationEffect(
                state.orientation == .vertical && rotatesForVertical ? .degrees(90) : .zero
            )
        }
        .buttonStyle(.sc(variant, size: size))
        .disabled(!state.canScrollPrevious)
        .accessibilityLabel(Text("Previous slide"))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: state.orientation == .horizontal ? .leading : .top
        )
        .offset(
            x: state.orientation == .horizontal ? -44 : 0,
            y: state.orientation == .vertical ? -44 : 0
        )
    }
}

extension SCCarouselPrevious where Label == Image {
    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .iconSM
    ) {
        self.init(variant: variant, size: size, rotatesForVertical: true) {
            Image(systemName: "chevron.backward")
        }
    }
}

/// The next-slide control, positioned from the carousel orientation.
public struct SCCarouselNext<Label: View>: View {
    @EnvironmentObject private var state: SCCarouselState

    private let variant: SCButtonVariant
    private let size: SCButtonSize
    private let rotatesForVertical: Bool
    private let label: Label

    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .iconSM,
        rotatesForVertical: Bool = false,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.rotatesForVertical = rotatesForVertical
        self.label = label()
    }

    public var body: some View {
        Button(action: state.scrollNext) {
            label.rotationEffect(
                state.orientation == .vertical && rotatesForVertical ? .degrees(90) : .zero
            )
        }
        .buttonStyle(.sc(variant, size: size))
        .disabled(!state.canScrollNext)
        .accessibilityLabel(Text("Next slide"))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: state.orientation == .horizontal ? .trailing : .bottom
        )
        .offset(
            x: state.orientation == .horizontal ? 44 : 0,
            y: state.orientation == .vertical ? 44 : 0
        )
    }
}

extension SCCarouselNext where Label == Image {
    public init(
        variant: SCButtonVariant = .outline,
        size: SCButtonSize = .iconSM
    ) {
        self.init(variant: variant, size: size, rotatesForVertical: true) {
            Image(systemName: "chevron.forward")
        }
    }
}

// MARK: - Optional indicators and array convenience

/// Optional page indicators layered on the official carousel composition.
public struct SCCarouselIndicators: View {
    @EnvironmentObject private var state: SCCarouselState
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(state.itemIDs.enumerated()), id: \.element) { index, id in
                Button {
                    state.scroll(to: id)
                } label: {
                    Circle()
                        .fill(id == state.currentID ? theme.primary : theme.muted)
                        .frame(width: 7, height: 7)
                        .padding(4)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Slide \(index + 1) of \(state.itemIDs.count)"))
                .accessibilityAddTraits(id == state.currentID ? .isSelected : [])
            }
        }
    }
}

public struct SCCarouselDataContent<Item: Identifiable, Slide: View>: View {
    fileprivate let items: [Item]
    fileprivate let showsControls: Bool
    fileprivate let showsIndicators: Bool
    fileprivate let slide: (Item) -> Slide

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                SCCarouselContent {
                    ForEach(items) { item in
                        SCCarouselItem(id: item.id) {
                            slide(item)
                        }
                    }
                }
                if showsControls, items.count > 1 {
                    SCCarouselPrevious()
                    SCCarouselNext()
                }
            }
            if showsIndicators, items.count > 1 {
                SCCarouselIndicators()
            }
        }
    }
}

extension SCCarousel {
    /// Compatibility initializer for the original data-driven carousel API.
    public init<Item: Identifiable, Slide: View>(
        items: [Item],
        orientation: SCCarouselOrientation = .horizontal,
        spacing: CGFloat = 16,
        showsControls: Bool = true,
        showsIndicators: Bool = true,
        wrapsNavigation: Bool = false,
        @ViewBuilder content: @escaping (Item) -> Slide
    ) where Content == SCCarouselDataContent<Item, Slide> {
        self.init(
            orientation: orientation,
            wrapsNavigation: wrapsNavigation,
            spacing: spacing
        ) {
            SCCarouselDataContent(
                items: items,
                showsControls: showsControls,
                showsIndicators: showsIndicators,
                slide: content
            )
        }
    }
}

// MARK: - Previews

private struct CarouselSlide: Identifiable {
    let id: Int
}

#Preview("Carousel · composition") {
    SCPreview {
        SCCarousel {
            SCCarouselContent {
                ForEach(0..<5, id: \.self) { index in
                    SCCarouselItem(id: index, accessibilityLabel: "Slide \(index + 1)") {
                        RoundedRectangle(cornerRadius: Theme.default.radius)
                            .fill(Theme.default.muted)
                            .frame(height: 200)
                            .overlay { Text("\(index + 1)").font(.largeTitle) }
                    }
                }
            }
            SCCarouselPrevious()
            SCCarouselNext()
        }
        .padding(.horizontal, 48)
    }
}

#Preview("Carousel · data convenience") {
    SCPreview {
        SCCarousel(items: (0..<3).map(CarouselSlide.init)) { slide in
            RoundedRectangle(cornerRadius: Theme.default.radius)
                .strokeBorder(Theme.default.border)
                .frame(height: 140)
                .overlay { Text("Slide \(slide.id + 1)") }
        }
        .padding(.horizontal, 48)
    }
}
