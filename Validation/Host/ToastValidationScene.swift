import SwiftUI
import Swiftcn

/// The lower-level SCToastCenter/SCToast queue API that SCSonner wraps —
/// direct struct construction, a paired action/cancel row, a non-dismissible
/// toast resolved back to dismissible, `onDismiss`, and `.scToaster()` with
/// a custom `SCToasterConfiguration` (position, close button) — hosted
/// separately from SonnerValidationScene so the two suites exercise
/// distinct call paths against the same shared queue rather than
/// duplicating coverage (see that scene's doc comment).
struct ToastValidationScene: View {
    @State private var dispatchCount = 0
    @State private var actionRuns = 0
    @State private var cancelRuns = 0
    @State private var dismissCallbacks = 0

    private let defaultId = UUID()
    private let cancelableId = UUID()
    private let nonDismissibleId = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dispatches: \(dispatchCount)")
                .accessibilityIdentifier("toast-dispatch-count")
            Text("Action runs: \(actionRuns)")
                .accessibilityIdentifier("toast-action-runs")
            Text("Cancel runs: \(cancelRuns)")
                .accessibilityIdentifier("toast-cancel-runs")
            Text("onDismiss callbacks: \(dismissCallbacks)")
                .accessibilityIdentifier("toast-dismiss-callbacks")

            Button("Show default") {
                SCToastCenter.shared.show(
                    SCToast(
                        id: defaultId,
                        title: "Event has been created",
                        description: "Monday, January 3rd at 6:00pm",
                        duration: nil
                    )
                )
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-show-default")

            Button("Show with action and cancel") {
                SCToastCenter.shared.show(
                    SCToast(
                        id: cancelableId,
                        title: "Delete file?",
                        variant: .warning,
                        duration: nil,
                        action: SCToastAction("Delete") { actionRuns += 1 },
                        cancel: SCToastAction("Keep") { cancelRuns += 1 },
                        onDismiss: { _ in dismissCallbacks += 1 }
                    )
                )
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-show-cancelable")

            Button("Show non-dismissible") {
                SCToastCenter.shared.show(
                    SCToast(
                        id: nonDismissibleId,
                        title: "Syncing…",
                        variant: .loading,
                        duration: nil,
                        isDismissible: false
                    )
                )
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-show-nondismissible")

            Button("Resolve non-dismissible") {
                SCToastCenter.shared.update(nonDismissibleId) {
                    $0.variant = .success
                    $0.title = "Synced"
                    $0.isDismissible = true
                }
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-resolve-nondismissible")

            Button("Dismiss default") {
                SCToastCenter.shared.dismiss(defaultId)
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-dismiss-default")

            Button("Show error variant") {
                SCToastCenter.shared.show(
                    title: "Upload failed",
                    variant: .error,
                    duration: nil
                )
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("toast-show-error")

            // SCToast has no disabled/invalid notification concept; this
            // proves the standard SwiftUI disabled contract on a dispatch
            // trigger.
            Button("Show (disabled trigger)") {
                dispatchCount += 1
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .disabled(true)
            .accessibilityIdentifier("toast-show-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .scToaster(
            configuration: SCToasterConfiguration(
                position: .topTrailing,
                showsCloseButton: true
            )
        )
    }
}
