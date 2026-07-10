// ============================================================
// Command.swift — swiftcn-ui
// Depends on: Theme/, Kbd.swift (SCKbd)
// ============================================================
import SwiftUI

// MARK: - Model

/// One executable entry in a command list: a title, optional icon and
/// shortcut hint, extra search keywords, and the action to run.
public struct SCCommandItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String?
    public let shortcut: String?
    public let keywords: [String]
    public let action: @Sendable () -> Void

    /// Creates a command item.
    /// - Parameters:
    ///   - id: Stable identity; defaults to `title`. Provide one when two
    ///     items share a title.
    ///   - title: The visible label, also matched by the search filter.
    ///   - systemImage: Optional leading SF Symbol.
    ///   - shortcut: Optional shortcut hint rendered as a keycap (e.g. "⌘P").
    ///   - keywords: Extra terms the search filter matches besides the title.
    ///   - action: Runs when the item is chosen.
    public init(
        id: String? = nil,
        title: String,
        systemImage: String? = nil,
        shortcut: String? = nil,
        keywords: [String] = [],
        action: @escaping @Sendable () -> Void
    ) {
        self.id = id ?? title
        self.title = title
        self.systemImage = systemImage
        self.shortcut = shortcut
        self.keywords = keywords
        self.action = action
    }

    /// Case-insensitive substring match over the title and keywords.
    func matches(_ query: String) -> Bool {
        title.localizedCaseInsensitiveContains(query)
            || keywords.contains { $0.localizedCaseInsensitiveContains(query) }
    }
}

/// A labeled section of command items.
public struct SCCommandGroup: Identifiable, Sendable {
    public let label: String
    public let items: [SCCommandItem]

    public var id: String { label }

    public init(label: String, items: [SCCommandItem]) {
        self.label = label
        self.items = items
    }
}

// MARK: - Component

/// A filterable command list — the swiftcn port of shadcn/ui's Command.
///
/// Renders a search field over grouped, keyboard-navigable results: ↑/↓ move
/// the highlight, Return runs the highlighted item, and typing filters by
/// title and keywords. Use it inline, or present it as a ⌘K palette with
/// `.scCommandPalette(isPresented:groups:)`.
///
///     SCCommandList(groups: [
///         SCCommandGroup(label: "Suggestions", items: [
///             SCCommandItem(title: "Calendar", systemImage: "calendar") { openCalendar() },
///             SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") { openProfile() },
///         ]),
///     ])
public struct SCCommandList: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isSearchFocused: Bool

    @State private var internalQuery = ""
    @State private var highlightedID: String?

    private let groups: [SCCommandGroup]
    private let placeholder: String
    private let externalQuery: Binding<String>?
    /// Palette hook: when set, replaces the default "run the item's action"
    /// behavior so the presenter can dismiss first.
    private let onExecute: ((SCCommandItem) -> Void)?

    init(
        groups: [SCCommandGroup],
        placeholder: String,
        externalQuery: Binding<String>?,
        onExecute: ((SCCommandItem) -> Void)?
    ) {
        self.groups = groups
        self.placeholder = placeholder
        self.externalQuery = externalQuery
        self.onExecute = onExecute
    }

    /// Creates a command list that manages its own search text.
    public init(
        groups: [SCCommandGroup],
        placeholder: String = "Type a command or search…"
    ) {
        self.init(groups: groups, placeholder: placeholder, externalQuery: nil, onExecute: nil)
    }

    /// Creates a command list whose search text is owned by the caller.
    public init(
        groups: [SCCommandGroup],
        query: Binding<String>,
        placeholder: String = "Type a command or search…"
    ) {
        self.init(groups: groups, placeholder: placeholder, externalQuery: query, onExecute: nil)
    }

    public var body: some View {
        VStack(spacing: 0) {
            searchField
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
            results
        }
        .opacity(isEnabled ? 1 : 0.5)
        .onAppear {
            highlightedID = filteredItems.first?.id
            DispatchQueue.main.async { isSearchFocused = true }
        }
        .onChange(of: queryText) { _, _ in
            highlightedID = filteredItems.first?.id
        }
    }

    // MARK: Search field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(theme.mutedForeground)
            TextField(
                placeholder,
                text: queryBinding,
                prompt: Text(placeholder).foregroundStyle(theme.mutedForeground)
            )
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(theme.foreground)
            .focused($isSearchFocused)
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .onKeyPress(.upArrow) {
                moveHighlight(by: -1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                moveHighlight(by: 1)
                return .handled
            }
            .onKeyPress(.return) {
                executeHighlighted() ? .handled : .ignored
            }
            .onSubmit { executeHighlighted() }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
    }

    // MARK: Results

    @ViewBuilder
    private var results: some View {
        let visibleGroups = filteredGroups
        if visibleGroups.isEmpty {
            Text("No results found.")
                .font(.footnote)
                .foregroundStyle(theme.mutedForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(visibleGroups) { group in
                            Text(group.label)
                                .font(.caption)
                                .foregroundStyle(theme.mutedForeground)
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                                .padding(.bottom, 4)
                            ForEach(group.items) { item in
                                row(for: item)
                                    .id(item.id)
                            }
                        }
                    }
                    .padding(6)
                }
                .onChange(of: highlightedID) { _, id in
                    if let id { proxy.scrollTo(id) }
                }
            }
        }
    }

    private func row(for item: SCCommandItem) -> some View {
        let isHighlighted = item.id == highlightedID
        return Button {
            execute(item)
        } label: {
            HStack(spacing: 10) {
                if let systemImage = item.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16))
                        .frame(width: 20)
                        .foregroundStyle(isHighlighted ? theme.accentForeground : theme.mutedForeground)
                }
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if let shortcut = item.shortcut {
                    SCKbd(shortcut)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .contentShape(rowShape)
            .background(isHighlighted ? theme.accent : .clear, in: rowShape)
            .foregroundStyle(isHighlighted ? theme.accentForeground : theme.foreground)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { highlightedID = item.id }
        }
    }

    private var rowShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 2), style: .continuous)
    }

    // MARK: Filtering & selection

    private var queryBinding: Binding<String> {
        externalQuery ?? $internalQuery
    }

    private var queryText: String {
        externalQuery?.wrappedValue ?? internalQuery
    }

    private var filteredGroups: [SCCommandGroup] {
        let trimmed = queryText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return groups }
        return groups.compactMap { group in
            let items = group.items.filter { $0.matches(trimmed) }
            return items.isEmpty ? nil : SCCommandGroup(label: group.label, items: items)
        }
    }

    private var filteredItems: [SCCommandItem] {
        filteredGroups.flatMap(\.items)
    }

    private func moveHighlight(by offset: Int) {
        let items = filteredItems
        guard !items.isEmpty else { return }
        guard
            let current = highlightedID,
            let index = items.firstIndex(where: { $0.id == current })
        else {
            highlightedID = offset > 0 ? items.first?.id : items.last?.id
            return
        }
        highlightedID = items[(index + offset + items.count) % items.count].id
    }

    @discardableResult
    private func executeHighlighted() -> Bool {
        guard
            let current = highlightedID,
            let item = filteredItems.first(where: { $0.id == current })
        else { return false }
        execute(item)
        return true
    }

    private func execute(_ item: SCCommandItem) {
        if let onExecute {
            onExecute(item)
        } else {
            item.action()
        }
    }
}

// MARK: - Palette presentation

public extension View {
    /// Presents a floating ⌘K command palette over this view — shadcn's
    /// Command inside its Command Dialog.
    ///
    /// Pure SwiftUI overlay (same approach as `.scDialog`): a scrim that
    /// dismisses on tap, with the command list in a top-aligned panel.
    /// Escape dismisses; choosing an item dismisses the palette first, then
    /// runs the item's action. Attach it to the container the scrim should
    /// cover.
    ///
    ///     .scCommandPalette(isPresented: $showPalette, groups: [
    ///         SCCommandGroup(label: "Settings", items: [
    ///             SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") { openProfile() },
    ///         ]),
    ///     ])
    ///
    /// - Parameters:
    ///   - isPresented: Controls the palette's visibility.
    ///   - groups: The command sections to search and run.
    ///   - placeholder: Prompt shown in the search field.
    func scCommandPalette(
        isPresented: Binding<Bool>,
        groups: [SCCommandGroup],
        placeholder: String = "Type a command or search…"
    ) -> some View {
        modifier(SCCommandPaletteModifier(
            isPresented: isPresented,
            groups: groups,
            placeholder: placeholder
        ))
    }
}

private struct SCCommandPaletteModifier: ViewModifier {
    @Environment(\.theme) private var theme

    @Binding var isPresented: Bool
    var groups: [SCCommandGroup]
    var placeholder: String

    func body(content: Content) -> some View {
        content.overlay {
            ZStack(alignment: .top) {
                if isPresented {
                    // shadcn's bg-black/50 overlay — the one sanctioned raw color.
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { isPresented = false }
                        .accessibilityHidden(true)
                        .transition(AnyTransition.opacity)

                    GeometryReader { proxy in
                        panel
                            .frame(maxWidth: 560)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.top, proxy.size.height * 0.12)
                    }
                    .transition(AnyTransition.scale(scale: 0.96, anchor: .top).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.22), value: isPresented)
        }
    }

    private var panel: some View {
        SCCommandList(
            groups: groups,
            placeholder: placeholder,
            externalQuery: nil,
            onExecute: { item in
                isPresented = false
                item.action()
            }
        )
        .frame(maxHeight: 380)
        .clipShape(shape)
        .background {
            shape
                .fill(theme.popover)
                .shadow(radius: 24, y: 10)
        }
        .overlay { shape.strokeBorder(theme.border) }
        .foregroundStyle(theme.popoverForeground)
        .accessibilityAddTraits(.isModal)
        .onKeyPress(.escape) {
            isPresented = false
            return .handled
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 4, style: .continuous)
    }
}

// MARK: - Previews

private let commandPreviewGroups = [
    SCCommandGroup(label: "Suggestions", items: [
        SCCommandItem(title: "Calendar", systemImage: "calendar") {},
        SCCommandItem(title: "Search Emoji", systemImage: "face.smiling", keywords: ["smiley", "emoticon"]) {},
        SCCommandItem(title: "Calculator", systemImage: "plus.forwardslash.minus", keywords: ["math"]) {},
    ]),
    SCCommandGroup(label: "Settings", items: [
        SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") {},
        SCCommandItem(title: "Billing", systemImage: "creditcard", shortcut: "⌘B") {},
        SCCommandItem(title: "Settings", systemImage: "gearshape", shortcut: "⌘S") {},
    ]),
]

#Preview("Command") {
    SCPreview {
        SCCommandList(groups: commandPreviewGroups)
            .frame(height: 340)
            .background(
                Theme.default.popover,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Theme.default.border)
            }
    }
}

#Preview("Command · palette") {
    @Previewable @State var isPresented = true

    SCPreview {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 8) {
                Text("Open command palette")
                SCKbdGroup(["⌘", "K"])
            }
        }
        .buttonStyle(.sc(.outline))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(height: 560)
    .scCommandPalette(isPresented: $isPresented, groups: commandPreviewGroups)
}
