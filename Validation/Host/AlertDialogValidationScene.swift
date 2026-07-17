import SwiftUI
import Swiftcn

/// Both SCAlertDialogSize presentations wired to caller-owned save, delete,
/// and cancel counters, a disabled action, a disabled trigger, and the alert
/// dialog's non-dismissible backdrop, so UI tests can prove presentation,
/// real action routing, and its stronger dismissal contract than a plain
/// dialog through the accessibility tree.
struct AlertDialogValidationScene: View {
    @State private var isPresented = false
    @State private var size = SCAlertDialogSize.default
    @State private var saveCount = 0
    @State private var deleteCount = 0
    @State private var cancelCount = 0

    var body: some View {
        SCAlertDialog(isPresented: $isPresented) {
            sceneContent
        } content: {
            SCAlertDialogContent(size: size) {
                SCAlertDialogHeader {
                    SCAlertDialogTitle("Delete account?")
                        .accessibilityIdentifier("alertdialog-title")
                    SCAlertDialogDescription("This action cannot be undone.")
                        .accessibilityIdentifier("alertdialog-description")
                }

                Text("Saves: \(saveCount)")
                    .accessibilityIdentifier("alertdialog-save-count")
                Text("Deletes: \(deleteCount)")
                    .accessibilityIdentifier("alertdialog-delete-count")

                SCAlertDialogFooter {
                    SCAlertDialogCancel(action: { cancelCount += 1 })
                        .accessibilityIdentifier("alertdialog-cancel")

                    SCAlertDialogAction(isDisabled: true, action: {}) {
                        Text("Disabled action")
                    }
                    .accessibilityIdentifier("alertdialog-action-disabled")

                    SCAlertDialogAction("Save") {
                        saveCount += 1
                    }
                    .accessibilityIdentifier("alertdialog-save")

                    SCAlertDialogAction("Delete", role: .destructive) {
                        deleteCount += 1
                    }
                    .accessibilityIdentifier("alertdialog-delete")
                }
            }
            // `.contain` keeps this identifier on one container element; a
            // bare identifier on the composite content propagates onto every
            // descendant and OVERWRITES the per-control identifiers above.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("alertdialog-\(sizeName)-content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sceneContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Saves: \(saveCount)")
                .accessibilityIdentifier("alertdialog-scene-save-count")
            Text("Deletes: \(deleteCount)")
                .accessibilityIdentifier("alertdialog-scene-delete-count")
            Text("Cancels: \(cancelCount)")
                .accessibilityIdentifier("alertdialog-cancel-count")

            HStack(spacing: 8) {
                Button("Present default") {
                    size = .default
                    isPresented = true
                }
                .buttonStyle(.sc(.destructive))
                .accessibilityIdentifier("alertdialog-present-default")

                Button("Present small") {
                    size = .small
                    isPresented = true
                }
                .buttonStyle(.sc(.destructive))
                .accessibilityIdentifier("alertdialog-present-small")
            }

            SCAlertDialogTrigger("Disabled alert dialog")
                .buttonStyle(.sc(.outline))
                .disabled(true)
                .accessibilityIdentifier("alertdialog-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var sizeName: String {
        String(describing: size)
    }
}
