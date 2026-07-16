import SwiftUI
import Swiftcn

/// Composed and collapsed breadcrumbs expose actionable links, current-page
/// semantics, separators, ellipsis, and caller-observable activation counts.
struct BreadcrumbValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("breadcrumb-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("breadcrumb-last-activated")

            SCBreadcrumb(accessibilityLabel: "Composed breadcrumb") {
                SCBreadcrumbList {
                    SCBreadcrumbItem {
                        SCBreadcrumbLink(action: { activate("home") }, label: { Text("Home") })
                            .accessibilityIdentifier("breadcrumb-home-link")
                    }
                    SCBreadcrumbSeparator()
                        .accessibilityIdentifier("breadcrumb-default-separator")
                    SCBreadcrumbItem {
                        SCBreadcrumbLink(
                            action: { activate("components") },
                            label: { Text("Components") }
                        )
                        .accessibilityIdentifier("breadcrumb-components-link")
                    }
                    SCBreadcrumbSeparator { Text("/") }
                        .accessibilityIdentifier("breadcrumb-custom-separator")
                    SCBreadcrumbItem {
                        SCBreadcrumbEllipsis(accessibilityLabel: "More breadcrumb items")
                            .accessibilityIdentifier("breadcrumb-ellipsis")
                    }
                    SCBreadcrumbSeparator()
                    SCBreadcrumbItem {
                        SCBreadcrumbPage("Breadcrumb")
                            .accessibilityIdentifier("breadcrumb-current-page")
                    }
                }
            }
            .accessibilityIdentifier("breadcrumb-composed")

            SCBreadcrumb(
                items: [
                    SCBreadcrumbItem("Root") { activate("collapsed-root") },
                    SCBreadcrumbItem("Docs") { activate("collapsed-docs") },
                    SCBreadcrumbItem("Components") { activate("collapsed-components") },
                    SCBreadcrumbItem("Breadcrumb"),
                ],
                maxVisible: 3,
                accessibilityLabel: "Collapsed breadcrumb"
            )
            .frame(width: 280)
            .accessibilityIdentifier("breadcrumb-collapsed")

            SCBreadcrumb {
                SCBreadcrumbList {
                    SCBreadcrumbItem {
                        SCBreadcrumbLink(
                            action: { activate("disabled") },
                            label: { Text("Disabled destination") }
                        )
                        .disabled(true)
                        .accessibilityIdentifier("breadcrumb-disabled-link")
                    }
                }
            }
            .accessibilityIdentifier("breadcrumb-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func activate(_ name: String) {
        activationCount += 1
        lastActivated = name
    }
}
