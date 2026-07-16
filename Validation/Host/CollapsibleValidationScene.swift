import Swiftcn
import SwiftUI

/// Controlled and internally managed collapsibles expose real open state,
/// default-open content, callback delivery, and disabled trigger semantics.
struct CollapsibleValidationScene: View {
    @State private var controlledOpen = false
    @State private var controlledCallback = "none"
    @State private var internalCallback = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Controlled: \(controlledOpen ? "open" : "closed")")
                .accessibilityIdentifier("collapsible-controlled-echo")
            Text("Controlled callback: \(controlledCallback)")
                .accessibilityIdentifier("collapsible-controlled-callback")
            Text("Internal callback: \(internalCallback)")
                .accessibilityIdentifier("collapsible-internal-callback")

            SCCollapsibleRoot(
                isOpen: $controlledOpen,
                onOpenChange: { controlledCallback = $0 ? "open" : "closed" }
            ) {
                SCCollapsibleTrigger { Text("Controlled details") }
                    .accessibilityIdentifier("collapsible-controlled-trigger")
                SCCollapsibleContent {
                    Text("Controlled content")
                        .accessibilityIdentifier("collapsible-controlled-content")
                }
            }

            SCCollapsibleRoot(
                defaultOpen: true,
                onOpenChange: { internalCallback = $0 ? "open" : "closed" }
            ) {
                SCCollapsibleTrigger { Text("Default-open details") }
                    .accessibilityIdentifier("collapsible-default-open-trigger")
                SCCollapsibleContent(keepMounted: true) {
                    Text("Default-open content")
                        .accessibilityIdentifier("collapsible-default-open-content")
                }
            }

            SCCollapsibleRoot(isDisabled: true) {
                SCCollapsibleTrigger { Text("Disabled details") }
                    .accessibilityIdentifier("collapsible-disabled")
                SCCollapsibleContent {
                    Text("Disabled content")
                        .accessibilityIdentifier("collapsible-disabled-content")
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
