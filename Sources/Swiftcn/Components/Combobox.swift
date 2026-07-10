// ============================================================
// Combobox.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Option

/// One entry in an `SCCombobox`: the value it writes to the selection
/// binding and the label shown (and searched) for it.
public struct SCComboboxOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let label: String

    public var id: Value { value }

    public init(value: Value, label: String) {
        self.value = value
        self.label = label
    }
}

// MARK: - Component

/// A searchable select — the swiftcn port of shadcn/ui's Combobox
/// (Popover + Command).
///
/// A field-styled trigger opens an anchored popover with a search field and
/// the filtered option list. The selected option shows a leading checkmark;
/// ↑/↓ move the highlight and Return picks it. Choosing an option writes the
/// binding and closes the popover.
///
///     SCCombobox(selection: $framework,
///                options: ["Next.js", "SvelteKit", "Nuxt.js", "Remix", "Astro"])
///
///     SCCombobox(selection: $timezone, options: [
///         SCComboboxOption(value: TimeZone(identifier: "GMT")!, label: "GMT"),
///         SCComboboxOption(value: TimeZone(identifier: "EST")!, label: "Eastern"),
///     ])
public struct SCCombobox<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isSearchFocused: Bool

    @State private var isPresented = false
    @State private var query = ""
    @State private var highlighted: Value?

    @Binding private var selection: Value?
    private let options: [SCComboboxOption<Value>]
    private let placeholder: String
    private let searchPlaceholder: String

    /// Creates a combobox over typed options.
    /// - Parameters:
    ///   - selection: The chosen value; `nil` shows the placeholder.
    ///   - options: The values to choose from, with their labels.
    ///   - placeholder: Trigger text while nothing is selected.
    ///   - searchPlaceholder: Prompt shown in the popover's search field.
    public init(
        selection: Binding<Value?>,
        options: [SCComboboxOption<Value>],
        placeholder: String = "Select…",
        searchPlaceholder: String = "Search…"
    ) {
        self._selection = selection
        self.options = options
        self.placeholder = placeholder
        self.searchPlaceholder = searchPlaceholder
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            trigger
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            panel
                .presentationCompactAdaptation(.popover)
                .presentationBackground(theme.popover)
        }
    }

    // MARK: Trigger

    private var selectedLabel: String? {
        options.first { $0.value == selection }?.label
    }

    private var trigger: some View {
        HStack(spacing: 8) {
            Text(selectedLabel ?? placeholder)
                .font(.subheadline)
                .foregroundStyle(selectedLabel == nil ? theme.mutedForeground : theme.foreground)
                .lineLimit(1)
            Spacer(minLength: 8)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(theme.mutedForeground)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(theme.background, in: triggerShape)
        .overlay(triggerShape.strokeBorder(theme.input))
        .contentShape(triggerShape)
    }

    private var triggerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    // MARK: Panel

    private var panel: some View {
        VStack(spacing: 0) {
            searchField
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
            list
        }
        .frame(minWidth: 220)
        .foregroundStyle(theme.popoverForeground)
        .onAppear {
            query = ""
            highlighted = selection ?? filtered.first?.value
            DispatchQueue.main.async { isSearchFocused = true }
        }
        .onChange(of: query) { _, _ in
            highlighted = filtered.first?.value
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(theme.mutedForeground)
            TextField(
                searchPlaceholder,
                text: $query,
                prompt: Text(searchPlaceholder).foregroundStyle(theme.mutedForeground)
            )
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(theme.popoverForeground)
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
                selectHighlighted() ? .handled : .ignored
            }
            .onSubmit { selectHighlighted() }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
    }

    @ViewBuilder
    private var list: some View {
        let visible = filtered
        if visible.isEmpty {
            Text("No results.")
                .font(.footnote)
                .foregroundStyle(theme.mutedForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(visible) { option in
                            row(for: option)
                                .id(option.value)
                        }
                    }
                    .padding(6)
                }
                .frame(maxHeight: 260)
                .onChange(of: highlighted) { _, value in
                    if let value { proxy.scrollTo(value) }
                }
            }
        }
    }

    private func row(for option: SCComboboxOption<Value>) -> some View {
        let isSelected = option.value == selection
        let isHighlighted = option.value == highlighted
        return Button {
            select(option)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.semibold))
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
                Text(option.label)
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .contentShape(rowShape)
            .background(isHighlighted ? theme.accent : .clear, in: rowShape)
            .foregroundStyle(isHighlighted ? theme.accentForeground : theme.popoverForeground)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { highlighted = option.value }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var rowShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 2), style: .continuous)
    }

    // MARK: Filtering & selection

    private var filtered: [SCComboboxOption<Value>] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return options }
        return options.filter { $0.label.localizedCaseInsensitiveContains(trimmed) }
    }

    private func select(_ option: SCComboboxOption<Value>) {
        selection = option.value
        isPresented = false
    }

    private func moveHighlight(by offset: Int) {
        let visible = filtered
        guard !visible.isEmpty else { return }
        guard
            let current = highlighted,
            let index = visible.firstIndex(where: { $0.value == current })
        else {
            highlighted = offset > 0 ? visible.first?.value : visible.last?.value
            return
        }
        highlighted = visible[(index + offset + visible.count) % visible.count].value
    }

    @discardableResult
    private func selectHighlighted() -> Bool {
        guard
            let current = highlighted,
            let option = filtered.first(where: { $0.value == current })
        else { return false }
        select(option)
        return true
    }
}

// MARK: - Convenience

public extension SCCombobox where Value == String {
    /// Convenience for plain string choices — each string is both value and
    /// label.
    ///
    ///     SCCombobox(selection: $framework, options: ["Next.js", "Remix"])
    init(
        selection: Binding<String?>,
        options: [String],
        placeholder: String = "Select…",
        searchPlaceholder: String = "Search…"
    ) {
        self.init(
            selection: selection,
            options: options.map { SCComboboxOption(value: $0, label: $0) },
            placeholder: placeholder,
            searchPlaceholder: searchPlaceholder
        )
    }
}

// MARK: - Previews

#Preview("Combobox") {
    @Previewable @State var framework: String? = nil

    SCPreview {
        VStack(spacing: 12) {
            SCCombobox(
                selection: $framework,
                options: ["Next.js", "SvelteKit", "Nuxt.js", "Remix", "Astro"],
                placeholder: "Select framework…",
                searchPlaceholder: "Search framework…"
            )
            Text("Selected: \(framework ?? "none")")
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
        }
    }
    .frame(height: 420)
}

#Preview("Combobox · typed values & disabled") {
    @Previewable @State var priority: Int? = 2

    SCPreview {
        VStack(spacing: 12) {
            SCCombobox(
                selection: $priority,
                options: [
                    SCComboboxOption(value: 1, label: "Low"),
                    SCComboboxOption(value: 2, label: "Medium"),
                    SCComboboxOption(value: 3, label: "High"),
                    SCComboboxOption(value: 4, label: "Urgent"),
                ],
                placeholder: "Priority…"
            )
            SCCombobox(
                selection: .constant(String?.none),
                options: ["One", "Two"],
                placeholder: "Disabled"
            )
            .disabled(true)
        }
    }
    .frame(height: 420)
}
