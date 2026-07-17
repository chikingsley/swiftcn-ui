import SwiftUI
import Swiftcn

/// Horizontal, vertical, wrapping, and disabled `SCCarousel` instances, each
/// driven by an externally owned `SCCarouselState` so UI tests can prove
/// Previous/Next, indicator, and programmatic `scroll(to:)`/`scroll(toIndex:)`
/// commands all mutate the same caller-visible state and selection callback.
struct CarouselValidationScene: View {
    @StateObject private var horizontalState = SCCarouselState(initialID: 0)
    @StateObject private var verticalState = SCCarouselState(initialID: 0)
    @StateObject private var wrapState = SCCarouselState(initialID: 0)
    @StateObject private var disabledState = SCCarouselState(initialID: 0)
    @State private var selectionChangeCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            echoes

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Button("Jump to slide 4") { horizontalState.scroll(toIndex: 3) }
                        .buttonStyle(.sc(.outline, size: .sm))
                        .accessibilityIdentifier("carousel-jump-button")
                    Button("Scroll to id 1") { horizontalState.scroll(to: 1) }
                        .buttonStyle(.sc(.outline, size: .sm))
                        .accessibilityIdentifier("carousel-scroll-to-id-button")
                }
                SCCarousel(
                    state: horizontalState,
                    accessibilityLabel: "Horizontal carousel",
                    onSelectionChange: { _ in selectionChangeCount += 1 }
                ) {
                    SCCarouselContent {
                        ForEach(0..<5, id: \.self) { index in
                            SCCarouselItem(id: index, accessibilityLabel: "Slide \(index + 1)") {
                                slideContent(index)
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("carousel-horizontal-item-\(index)")
                        }
                    }
                    SCCarouselPrevious()
                        .accessibilityIdentifier("carousel-horizontal-previous")
                    SCCarouselNext()
                        .accessibilityIdentifier("carousel-horizontal-next")
                    SCCarouselIndicators()
                }
                .frame(height: 120)
                .padding(.horizontal, 44)
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("carousel-horizontal")

            SCCarousel(
                state: verticalState,
                orientation: .vertical,
                accessibilityLabel: "Vertical carousel"
            ) {
                SCCarouselContent {
                    ForEach(0..<3, id: \.self) { index in
                        SCCarouselItem(id: index) { slideContent(index) }
                    }
                }
                SCCarouselPrevious()
                    .accessibilityIdentifier("carousel-vertical-previous")
                SCCarouselNext()
                    .accessibilityIdentifier("carousel-vertical-next")
            }
            .frame(height: 120)
            .padding(.vertical, 44)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("carousel-vertical")

            SCCarousel(
                state: wrapState,
                wrapsNavigation: true,
                accessibilityLabel: "Wrapping carousel"
            ) {
                SCCarouselContent {
                    ForEach(0..<3, id: \.self) { index in
                        SCCarouselItem(id: index) { slideContent(index) }
                    }
                }
                SCCarouselPrevious()
                    .accessibilityIdentifier("carousel-wrap-previous")
                SCCarouselNext()
                    .accessibilityIdentifier("carousel-wrap-next")
            }
            .frame(height: 100)
            .padding(.horizontal, 44)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("carousel-wrap")

            SCCarousel(
                state: disabledState,
                accessibilityLabel: "Disabled carousel"
            ) {
                SCCarouselContent {
                    ForEach(0..<3, id: \.self) { index in
                        SCCarouselItem(id: index) { slideContent(index) }
                    }
                }
                SCCarouselPrevious()
                    .accessibilityIdentifier("carousel-disabled-previous")
                SCCarouselNext()
                    .accessibilityIdentifier("carousel-disabled-next")
                SCCarouselIndicators()
            }
            .frame(height: 100)
            .padding(.horizontal, 44)
            .disabled(true)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("carousel-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var echoes: some View {
        Text("Horizontal current: \(Self.describe(horizontalState.currentID))")
            .accessibilityIdentifier("carousel-horizontal-echo")
        Text("Horizontal selection changes: \(selectionChangeCount)")
            .accessibilityIdentifier("carousel-horizontal-change-count")
        Text("Vertical current: \(Self.describe(verticalState.currentID))")
            .accessibilityIdentifier("carousel-vertical-echo")
        Text("Wrap current: \(Self.describe(wrapState.currentID))")
            .accessibilityIdentifier("carousel-wrap-echo")
        Text("Disabled current: \(Self.describe(disabledState.currentID))")
            .accessibilityIdentifier("carousel-disabled-echo")
    }

    private static func describe(_ id: AnyHashable?) -> String {
        id.map { String(describing: $0) } ?? "none"
    }

    private func slideContent(_ index: Int) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.2))
            .overlay {
                Text("\(index + 1)")
                    .accessibilityHidden(true)
            }
    }
}
