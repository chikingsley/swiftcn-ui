import Swiftcn
import SwiftUI

/// All four sheet edges share caller-owned presentation and action state,
/// while automatic and caller-composed close paths, semantic header/footer
/// content, Escape dismissal, and a disabled trigger remain observable.
struct SheetValidationScene: View {
    @State private var actionCount = 0
    @State private var edge = SCSheetEdge.trailing
    @State private var isPresented = false
    @State private var openChangeCount = 0
    @State private var usesAutomaticClose = true

    var body: some View {
        SCSheet(
            isPresented: $isPresented,
            edge: edge,
            maximumPanelSize: 420,
            onOpenChange: { isOpen in
                openChangeCount += 1
                if !isOpen {
                    edge = .trailing
                    usesAutomaticClose = true
                }
            }
        ) {
            sceneContent
        } content: {
            SCSheetContent(showsCloseButton: usesAutomaticClose) {
                SCSheetHeader {
                    SCSheetTitle("Validation sheet")
                        .accessibilityIdentifier("sheet-title")
                    SCSheetDescription("Presented from the \(edgeName) edge.")
                        .accessibilityIdentifier("sheet-description")
                }

                Text("Edge: \(edgeName)")
                    .accessibilityIdentifier("sheet-edge-echo")
                Text("Actions: \(actionCount)")
                    .accessibilityIdentifier("sheet-action-count")

                Spacer(minLength: 0)

                SCSheetFooter {
                    Button("Run sheet action") { actionCount += 1 }
                        .buttonStyle(.sc())
                        .accessibilityIdentifier("sheet-run-action")
                    if !usesAutomaticClose {
                        SCSheetClose("Composed close")
                            .buttonStyle(.sc(.outline))
                            .accessibilityIdentifier("sheet-composed-close")
                    }
                }
            }
            .accessibilityIdentifier("sheet-\(edgeName)-content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sceneContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Presented: \(isPresented ? "true" : "false")")
                .accessibilityIdentifier("sheet-presented-echo")
            Text("Open changes: \(openChangeCount)")
                .accessibilityIdentifier("sheet-open-change-count")
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("sheet-scene-action-count")

            HStack(spacing: 8) {
                ForEach(SCSheetEdge.allCases, id: \.self) { candidate in
                    Button(String(describing: candidate).capitalized) {
                        edge = candidate
                        usesAutomaticClose = false
                        isPresented = true
                    }
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("sheet-present-\(String(describing: candidate))")
                }
            }

            SCSheetTrigger("Present automatic close")
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("sheet-present-automatic")

            SCSheetTrigger("Disabled sheet")
                .buttonStyle(.sc(.outline))
                .disabled(true)
                .accessibilityIdentifier("sheet-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var edgeName: String {
        String(describing: edge)
    }
}
