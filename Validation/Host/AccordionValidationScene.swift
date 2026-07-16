import SwiftUI
import Swiftcn

/// Single, multiple, collapsible, controlled, default-expanded, and disabled
/// accordion forms expose their expansion state and callbacks to callers.
struct AccordionValidationScene: View {
    @State private var controlledExpanded: Set<String> = []
    @State private var controlledCallback = "none"
    @State private var internalCallback = "none"
    @State private var multipleCallback = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Controlled: \(names(controlledExpanded))")
                .accessibilityIdentifier("accordion-controlled-echo")
            Text("Controlled callback: \(controlledCallback)")
                .accessibilityIdentifier("accordion-controlled-callback")
            Text("Internal callback: \(internalCallback)")
                .accessibilityIdentifier("accordion-internal-callback")
            Text("Multiple callback: \(multipleCallback)")
                .accessibilityIdentifier("accordion-multiple-callback")

            SCAccordion(
                type: .single(collapsible: true),
                expanded: $controlledExpanded,
                onExpandedChange: { controlledCallback = names($0) },
                content: {
                    SCAccordionItem(id: "controlled") {
                        SCAccordionTrigger("Controlled section")
                            .accessibilityIdentifier("accordion-controlled-trigger")
                        SCAccordionContent {
                            Text("Controlled panel")
                                .accessibilityIdentifier("accordion-controlled-content")
                        }
                    }
                }
            )

            SCAccordion(
                type: .single(collapsible: false),
                defaultExpanded: ["required"],
                onExpandedChange: { internalCallback = names($0) },
                content: {
                    SCAccordionItem(id: "required") {
                        SCAccordionTrigger("Required section")
                            .accessibilityIdentifier("accordion-required-trigger")
                        SCAccordionContent {
                            Text("Required panel")
                                .accessibilityIdentifier("accordion-required-content")
                        }
                    }
                    SCAccordionItem(id: "other") {
                        SCAccordionTrigger("Other section")
                            .accessibilityIdentifier("accordion-other-trigger")
                        SCAccordionContent {
                            Text("Other panel")
                                .accessibilityIdentifier("accordion-other-content")
                        }
                    }
                    SCAccordionItem(id: "disabled", isDisabled: true) {
                        SCAccordionTrigger("Disabled section")
                            .accessibilityIdentifier("accordion-disabled-trigger")
                        SCAccordionContent { Text("Disabled panel") }
                    }
                }
            )

            SCAccordion(
                type: .multiple,
                onExpandedChange: { multipleCallback = names($0) },
                content: {
                    SCAccordionItem("Alpha", id: "alpha") {
                        Text("Alpha panel").accessibilityIdentifier("accordion-alpha-content")
                    }
                    SCAccordionItem("Beta", id: "beta") {
                        Text("Beta panel").accessibilityIdentifier("accordion-beta-content")
                    }
                }
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func names(_ values: Set<String>) -> String {
        values.isEmpty ? "none" : values.sorted().joined(separator: ",")
    }
}
