import Swiftcn
import SwiftUI

/// Every dialog size presented from a full-scene controlled root, with
/// semantic header content, caller-owned action and presentation echoes, and
/// close, Escape, backdrop, focus, and disabled-trigger paths for UI tests.
struct DialogValidationScene: View {
    @State private var actionCount = 0
    @State private var isPresented = false
    @State private var openChangeCount = 0
    @State private var size = SCDialogSize.default

    var body: some View {
        SCDialog(
            isPresented: $isPresented,
            onOpenChange: { isOpen in
                openChangeCount += 1
                if !isOpen {
                    size = .default
                }
            }
        ) {
            sceneContent
        } content: {
            SCDialogContent(size: size) {
                SCDialogHeader {
                    SCDialogTitle("Validation dialog")
                        .accessibilityIdentifier("dialog-title")
                    SCDialogDescription("A caller-owned modal interaction.")
                        .accessibilityIdentifier("dialog-description")
                }

                Text("Actions: \(actionCount)")
                    .accessibilityIdentifier("dialog-action-count")

                SCDialogFooter {
                    Button("Run action") { actionCount += 1 }
                        .buttonStyle(.sc())
                        .accessibilityIdentifier("dialog-run-action")
                    SCDialogClose("Dismiss")
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("dialog-dismiss")
                }
            }
            .accessibilityIdentifier("dialog-\(sizeName)-content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sceneContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Presented: \(isPresented ? "true" : "false")")
                .accessibilityIdentifier("dialog-presented-echo")
            Text("Open changes: \(openChangeCount)")
                .accessibilityIdentifier("dialog-open-change-count")
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("dialog-scene-action-count")

            HStack(spacing: 8) {
                SCDialogTrigger("Present default")
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("dialog-present-default")

                Button("Present small") {
                    size = .small
                    isPresented = true
                }
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("dialog-present-small")

                Button("Present large") {
                    size = .large
                    isPresented = true
                }
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("dialog-present-large")
            }

            SCDialogTrigger("Disabled dialog")
                .buttonStyle(.sc(.outline))
                .disabled(true)
                .accessibilityIdentifier("dialog-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var sizeName: String {
        String(describing: size)
    }
}
