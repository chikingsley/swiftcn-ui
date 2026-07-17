import SwiftUI
import Swiftcn

/// Real SCSonner dispatch — show/success/loading/update/dismiss/dismissAll,
/// a real action button, and a short explicit-duration auto-dismiss —
/// hosted by SCSonnerToaster so a UI test can drive the shared queue and
/// observe real appearance/dismissal through the accessibility tree.
///
/// SCSonner is a typed facade over the same SCToastCenter singleton Toast
/// uses (Sonner.swift's own doc comment: "it does not own another queue or
/// presentation engine"); there is no separate Sonner rendering surface to
/// validate. This scene exercises Sonner's convenience call shapes
/// (variant helpers, `promise`-style `update`); ToastValidationScene
/// exercises the lower-level struct/queue API Sonner does not surface
/// (cancel actions, `isDismissible`, positional configuration) so the two
/// suites cover distinct call paths instead of duplicating each other.
///
/// Toasts default to a nil duration here (persisting until explicitly
/// dismissed) so assertions never race the auto-dismiss timer; one
/// dedicated instance uses a short, explicit duration to prove that timer
/// is real.
struct SonnerValidationScene: View {
    @State private var dispatchCount = 0
    @State private var lastDispatch = "none"
    @State private var actionRuns = 0

    private let defaultId = UUID()
    private let successId = UUID()
    private let actionId = UUID()
    private let loadingId = UUID()
    private let autoId = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dispatches: \(dispatchCount)")
                .accessibilityIdentifier("sonner-dispatch-count")
            Text("Last: \(lastDispatch)")
                .accessibilityIdentifier("sonner-last-dispatch")
            Text("Action runs: \(actionRuns)")
                .accessibilityIdentifier("sonner-action-runs")

            Button("Show default") {
                SCSonner.show(
                    "Event has been created",
                    description: "Monday, January 3rd at 6:00pm",
                    id: defaultId,
                    duration: nil
                )
                dispatchCount += 1
                lastDispatch = "default"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-show-default")

            Button("Show success") {
                SCSonner.success("Saved", id: successId, duration: nil)
                dispatchCount += 1
                lastDispatch = "success"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-show-success")

            Button("Show with action") {
                SCSonner.show(
                    "Message archived",
                    id: actionId,
                    duration: nil,
                    action: SCToastAction("Undo") { actionRuns += 1 }
                )
                dispatchCount += 1
                lastDispatch = "with-action"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-show-action")

            Button("Show loading") {
                SCSonner.loading("Uploading…", id: loadingId)
                dispatchCount += 1
                lastDispatch = "loading"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-show-loading")

            Button("Resolve loading to success") {
                SCSonner.update(loadingId) {
                    $0.variant = .success
                    $0.title = "Uploaded"
                    $0.duration = nil
                }
                dispatchCount += 1
                lastDispatch = "update"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-update-loading")

            Button("Show auto-dismiss (1s)") {
                SCSonner.show("Ephemeral", id: autoId, duration: .seconds(1))
                dispatchCount += 1
                lastDispatch = "auto"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-show-auto")

            Button("Dismiss success") {
                SCSonner.dismiss(successId)
                dispatchCount += 1
                lastDispatch = "dismiss-success"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-dismiss-success")

            Button("Dismiss all") {
                SCSonner.dismissAll()
                dispatchCount += 1
                lastDispatch = "dismiss-all"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("sonner-dismiss-all")

            // SCSonner has no disabled/invalid toast concept; this proves
            // the standard SwiftUI disabled contract on a dispatch trigger.
            Button("Show (disabled trigger)") {
                dispatchCount += 1
                lastDispatch = "disabled"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .disabled(true)
            .accessibilityIdentifier("sonner-show-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .scSonnerToaster()
    }
}
