// ============================================================
// Carousel.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (chevron controls)
// ============================================================
import SwiftUI

// MARK: - Component

/// A horizontally paging carousel with dot indicators and optional
/// previous/next controls — the swiftcn port of shadcn/ui's Carousel.
///
/// Built on iOS 17 scroll APIs: each slide fills the container width via
/// `containerRelativeFrame`, paging snaps with `.viewAligned` target
/// behavior, and the current page is tracked through `scrollPosition`.
/// Like shadcn's carousel (which imports the Button component), the
/// floating controls reuse `SCButtonStyle`.
///
///     SCCarousel(items: slides) { slide in
///         SCCard { SCCardTitle(slide.title) }
///     }
///
///     SCCarousel(items: slides, spacing: 24, showsControls: false) { slide in
///         Text(slide.title)
///     }
public struct SCCarousel<Item: Identifiable, Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var items: [Item]
    var spacing: CGFloat
    var showsControls: Bool
    @ViewBuilder var content: (Item) -> Content

    @State private var currentID: Item.ID?

    /// - Parameters:
    ///   - items: The slides' data, one element per page.
    ///   - spacing: Gap between adjacent slides in points.
    ///   - showsControls: Whether to float previous/next chevron buttons over
    ///     the edges. Always on for macOS, where swiping is uncommon.
    ///   - content: Renders one slide; it is sized to the container width.
    public init(
        items: [Item],
        spacing: CGFloat = 16,
        showsControls: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.showsControls = showsControls
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 16) {
            scroller
                .overlay(alignment: .leading) {
                    if controlsVisible { previousButton.offset(x: -20) }
                }
                .overlay(alignment: .trailing) {
                    if controlsVisible { nextButton.offset(x: 20) }
                }
            if items.count > 1 {
                dots
            }
        }
    }

    // MARK: Scroller

    private var scroller: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $currentID)
        .scrollIndicators(.hidden)
        .scrollDisabled(!isEnabled)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Carousel"))
        .accessibilityValue(Text("Page \(currentIndex + 1) of \(max(items.count, 1))"))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: scroll(to: currentIndex + 1)
            case .decrement: scroll(to: currentIndex - 1)
            @unknown default: break
            }
        }
    }

    // MARK: Controls

    private var controlsVisible: Bool {
        guard items.count > 1 else { return false }
        #if os(macOS)
        return true
        #else
        return showsControls
        #endif
    }

    private var previousButton: some View {
        Button {
            scroll(to: currentIndex - 1)
        } label: {
            Image(systemName: "chevron.left")
        }
        .buttonStyle(.sc(.outline, size: .icon))
        .disabled(currentIndex <= 0)
        .accessibilityLabel(Text("Previous page"))
    }

    private var nextButton: some View {
        Button {
            scroll(to: currentIndex + 1)
        } label: {
            Image(systemName: "chevron.right")
        }
        .buttonStyle(.sc(.outline, size: .icon))
        .disabled(currentIndex >= items.count - 1)
        .accessibilityLabel(Text("Next page"))
    }

    // MARK: Dots

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    scroll(to: index)
                } label: {
                    Circle()
                        .fill(index == currentIndex ? theme.primary : theme.muted)
                        .frame(width: 7, height: 7)
                        .padding(4)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Page \(index + 1) of \(items.count)"))
                .accessibilityAddTraits(index == currentIndex ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
        .opacity(isEnabled ? 1 : 0.5)
    }

    // MARK: Navigation

    private var currentIndex: Int {
        guard let currentID,
              let index = items.firstIndex(where: { $0.id == currentID })
        else { return 0 }
        return index
    }

    private func scroll(to index: Int) {
        guard items.indices.contains(index) else { return }
        withAnimation(.snappy(duration: 0.3)) {
            currentID = items[index].id
        }
    }
}

// MARK: - Previews

private struct CarouselSlide: Identifiable {
    let id: Int
    var label: String { "\(id + 1)" }
}

#Preview("Carousel") {
    SCPreview {
        SCCarousel(items: (0..<5).map(CarouselSlide.init)) { slide in
            RoundedRectangle(cornerRadius: Theme.default.radius + 2, style: .continuous)
                .fill(Theme.default.muted)
                .frame(height: 200)
                .overlay {
                    Text(slide.label)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(Theme.default.foreground)
                }
        }
        .padding(.horizontal, 24)
    }
}

#Preview("Carousel · no controls") {
    SCPreview {
        SCCarousel(items: (0..<3).map(CarouselSlide.init), showsControls: false) { slide in
            RoundedRectangle(cornerRadius: Theme.default.radius + 2, style: .continuous)
                .strokeBorder(Theme.default.border)
                .frame(height: 140)
                .overlay {
                    Text("Slide \(slide.label)")
                        .foregroundStyle(Theme.default.mutedForeground)
                }
        }
    }
}
