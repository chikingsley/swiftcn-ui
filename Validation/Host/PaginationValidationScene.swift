import SwiftUI
import Swiftcn

/// Composed pagination parts and a controlled windowed pager route actions,
/// expose active-page semantics, and enforce disabled boundary controls.
struct PaginationValidationScene: View {
    @State private var page = 1
    @State private var callbackPage = 0
    @State private var composedCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Page: \(page)")
                .accessibilityIdentifier("pagination-page-echo")
            Text("Callback page: \(callbackPage)")
                .accessibilityIdentifier("pagination-callback-echo")
            Text("Composed activations: \(composedCount)")
                .accessibilityIdentifier("pagination-composed-echo")

            SCPagination(accessibilityLabel: "Composed pagination", fillsAvailableWidth: false) {
                SCPaginationContent {
                    SCPaginationItem {
                        SCPaginationPrevious(isDisabled: true, action: { composedCount += 1 })
                            .accessibilityIdentifier("pagination-composed-previous")
                    }
                    SCPaginationItem {
                        SCPaginationLink(
                            "1",
                            isActive: true,
                            accessibilityLabel: "Composed page 1",
                            action: { composedCount += 1 }
                        )
                        .accessibilityIdentifier("pagination-composed-page")
                    }
                    SCPaginationItem {
                        SCPaginationEllipsis(isAccessibilityHidden: false)
                            .accessibilityIdentifier("pagination-composed-ellipsis")
                    }
                    SCPaginationItem {
                        SCPaginationNext(action: { composedCount += 1 })
                            .accessibilityIdentifier("pagination-composed-next")
                    }
                }
            }
            .accessibilityIdentifier("pagination-composed")

            SCPagination(
                current: $page,
                total: 5,
                maxVisible: 5,
                controlLabelVisibility: .visible,
                accessibilityLabel: "Windowed pagination",
                onPageChange: { callbackPage = $0 }
            )
            .accessibilityIdentifier("pagination-windowed")

            SCPagination(accessibilityLabel: "Disabled pagination", isDisabled: true) {
                SCPaginationContent {
                    SCPaginationItem {
                        SCPaginationLink("Disabled", action: {})
                            .accessibilityIdentifier("pagination-disabled-link")
                    }
                }
            }
            .accessibilityIdentifier("pagination-disabled-root")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
