import SwiftUI
import Swiftcn

/// Inline and block addons around both a text input and a textarea control,
/// an addon button whose action reaches caller-owned state, noninteractive
/// addons that forward focus to the real control on tap, and invalid and
/// disabled instances, so UI tests can prove real typing, focus forwarding,
/// and disabled semantics through the accessibility tree.
struct InputGroupValidationScene: View {
    @State private var query = ""
    @State private var copyCount = 0
    @State private var message = ""
    @State private var refreshCount = 0
    @State private var invalidValue = "bad-value"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Query: \(query)")
                .accessibilityIdentifier("inputgroup-query-echo")
            Text("Copy actions: \(copyCount)")
                .accessibilityIdentifier("inputgroup-copy-count")
            Text("Message: \(message)")
                .accessibilityIdentifier("inputgroup-message-echo")
            Text("Refresh actions: \(refreshCount)")
                .accessibilityIdentifier("inputgroup-refresh-count")
            Text("Invalid field: \(invalidValue)")
                .accessibilityIdentifier("inputgroup-invalid-echo")

            SCInputGroup {
                SCInputGroupInput("Search documentation", text: $query, kind: .search)
                SCInputGroupAddon {
                    Image(systemName: "magnifyingglass")
                        .accessibilityLabel("Search icon")
                }
                SCInputGroupAddon(alignment: .inlineEnd) {
                    SCInputGroupText("\(query.count)")
                        .accessibilityIdentifier("inputgroup-query-length")
                    SCInputGroupButton(size: .iconXS) {
                        copyCount += 1
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .accessibilityIdentifier("inputgroup-copy-button")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("inputgroup-inline")

            SCInputGroup {
                SCInputGroupTextarea("Share your thoughts…", text: $message, minHeight: 96)
                SCInputGroupAddon(alignment: .blockStart) {
                    SCInputGroupText("Comment")
                        .accessibilityIdentifier("inputgroup-block-start-addon")
                    Spacer()
                    SCInputGroupButton(size: .iconXS) {
                        refreshCount += 1
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("inputgroup-refresh-button")
                }
                SCInputGroupAddon(alignment: .blockEnd) {
                    SCInputGroupText("\(message.count)/500 characters")
                        .accessibilityIdentifier("inputgroup-character-count")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("inputgroup-block")

            HStack(spacing: 16) {
                SCInputGroup(isInvalid: true) {
                    SCInputGroupInput("Invalid", text: $invalidValue)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("inputgroup-invalid")

                SCInputGroup {
                    SCInputGroupInput("Disabled", text: .constant("cannot edit"))
                }
                .disabled(true)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("inputgroup-disabled")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
