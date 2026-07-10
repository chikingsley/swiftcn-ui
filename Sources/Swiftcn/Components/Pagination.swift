// ============================================================
// Pagination.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (Previous/Next controls)
// ============================================================
import SwiftUI

// MARK: - Component

/// Page navigation with previous/next links and a windowed row of page
/// numbers — the swiftcn port of shadcn/ui's Pagination.
///
/// The first and last pages are always visible; pages around `current`
/// form a sliding window, and gaps collapse into non-tappable ellipses.
/// `maxVisible` caps the number of cells in the numbers row (pages and
/// ellipses combined). Pages are 1-indexed. Like shadcn's pagination
/// (which imports `buttonVariants`), Previous/Next reuse `SCButtonStyle`.
///
///     @State var page = 1
///     SCPagination(current: $page, total: 10)
///     SCPagination(current: $page, total: 42, maxVisible: 9)
public struct SCPagination: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding var current: Int
    var total: Int
    var maxVisible: Int

    /// - Parameters:
    ///   - current: The selected page, 1-indexed.
    ///   - total: Total number of pages.
    ///   - maxVisible: Maximum cells in the numbers row, counting ellipses.
    ///     Values below 5 are clamped to 5 so first, last, current, and both
    ///     ellipses always fit.
    public init(current: Binding<Int>, total: Int, maxVisible: Int = 7) {
        self._current = current
        self.total = total
        self.maxVisible = max(maxVisible, 5)
    }

    public var body: some View {
        HStack(spacing: 4) {
            previousButton
            if total > 1 {
                ForEach(cells) { cell in
                    switch cell {
                    case .page(let page):
                        pageButton(page)
                    case .ellipsis:
                        ellipsis
                    }
                }
            }
            nextButton
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Pagination"))
    }

    // MARK: Cells

    private enum Cell: Hashable, Identifiable {
        case page(Int)
        /// `edge` disambiguates the leading (0) and trailing (1) gaps.
        case ellipsis(edge: Int)

        var id: Cell { self }
    }

    private var cells: [Cell] {
        guard total > 1 else { return [] }
        guard total > maxVisible else {
            return (1...total).map(Cell.page)
        }
        // Near the start: 1 … maxVisible-2 are contiguous, then … and last.
        if current <= maxVisible - 3 {
            return (1...(maxVisible - 2)).map(Cell.page)
                + [.ellipsis(edge: 1), .page(total)]
        }
        // Near the end: first and …, then the trailing contiguous run.
        if current >= total - (maxVisible - 4) {
            return [.page(1), .ellipsis(edge: 0)]
                + ((total - (maxVisible - 3))...total).map(Cell.page)
        }
        // Middle: first, …, window centered on current, …, last.
        let windowCount = maxVisible - 4
        let low = current - (windowCount - 1) / 2
        return [.page(1), .ellipsis(edge: 0)]
            + (low...(low + windowCount - 1)).map(Cell.page)
            + [.ellipsis(edge: 1), .page(total)]
    }

    // MARK: Subviews

    private var previousButton: some View {
        Button {
            current = max(current - 1, 1)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Previous")
            }
        }
        .buttonStyle(.sc(.ghost, size: .sm))
        .disabled(current <= 1)
        .accessibilityLabel(Text("Previous page"))
    }

    private var nextButton: some View {
        Button {
            current = min(current + 1, total)
        } label: {
            HStack(spacing: 4) {
                Text("Next")
                Image(systemName: "chevron.right")
            }
        }
        .buttonStyle(.sc(.ghost, size: .sm))
        .disabled(current >= total)
        .accessibilityLabel(Text("Next page"))
    }

    private func pageButton(_ page: Int) -> some View {
        Button("\(page)") {
            current = page
        }
        .buttonStyle(SCPaginationPageStyle(isCurrent: page == current))
        .accessibilityLabel(Text("Page \(page)"))
        .accessibilityAddTraits(page == current ? [.isSelected] : [])
    }

    private var ellipsis: some View {
        Text("…")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(theme.mutedForeground)
            .frame(width: 36, height: 36)
            .accessibilityLabel(Text("More pages"))
    }
}

// MARK: - Style

/// 36pt square page cell: the current page gets the outline-button look,
/// the rest are ghost.
private struct SCPaginationPageStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var isCurrent: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .monospacedDigit()
            .lineLimit(1)
            .frame(width: 36, height: 36)
            .background(background(pressed: configuration.isPressed), in: shape)
            .overlay {
                if isCurrent {
                    shape.strokeBorder(theme.border)
                }
            }
            .foregroundStyle(theme.foreground)
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.5)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private func background(pressed: Bool) -> Color {
        if isCurrent {
            return pressed ? theme.accent : theme.background
        }
        return pressed ? theme.accent : .clear
    }
}

// MARK: - Previews

#Preview("Pagination") {
    @Previewable @State var page = 2
    SCPreview {
        SCPagination(current: $page, total: 10)
    }
}

#Preview("Pagination · windowing") {
    @Previewable @State var first = 1
    @Previewable @State var middle = 25
    @Previewable @State var last = 50
    SCPreview {
        VStack(spacing: 16) {
            SCPagination(current: $first, total: 50)
            SCPagination(current: $middle, total: 50)
            SCPagination(current: $last, total: 50)
        }
    }
}

#Preview("Pagination · states") {
    @Previewable @State var page = 1
    SCPreview {
        VStack(spacing: 16) {
            SCPagination(current: .constant(1), total: 1)
            SCPagination(current: $page, total: 3)
                .disabled(true)
        }
    }
}
