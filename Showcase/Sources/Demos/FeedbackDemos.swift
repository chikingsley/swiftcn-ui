// ============================================================
// FeedbackDemos.swift — Swiftcn macOS Showcase
// Live demos for the Feedback category.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Alert

struct AlertDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SCAlert(
                icon: "terminal",
                title: "Heads up!",
                description: "You can add components to your app using the CLI."
            )
            SCAlert(
                icon: "exclamationmark.triangle",
                title: "Error",
                description: "Your session has expired. Please log in again.",
                variant: .destructive
            )
            SCAlert(icon: "checkmark.circle") {
                SCAlertTitle("Payment received")
                SCAlertDescription("A receipt was sent to your inbox.")
                SCBadge("Order #1024", variant: .secondary)
            }
        }
    }
}

// MARK: - Progress

struct ProgressDemo: View {
    @State private var progress = 0.4

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: progress)
                    .progressViewStyle(.scLinear)
                Button("Advance") {
                    progress = progress >= 1 ? 0 : min(progress + 0.25, 1)
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
            ProgressView("Uploading…", value: 0.66)
                .progressViewStyle(.scLinear)
            DemoSection("Indeterminate") {
                ProgressView()
                    .progressViewStyle(.scLinear)
            }
        }
        .frame(maxWidth: 320)
    }
}

// MARK: - Skeleton

struct SkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                SCSkeleton(width: 48, height: 48)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 8) {
                    SCSkeleton(width: 200, height: 14)
                    SCSkeleton(width: 140, height: 14)
                }
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sync complete")
                        .font(.headline)
                    Text("All 128 files are up to date.")
                        .font(.subheadline)
                }
                .scSkeleton(when: isLoading)

                Button(isLoading ? "Show content" : "Show skeleton") {
                    isLoading.toggle()
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
        }
    }
}

// MARK: - Spinner

struct SpinnerDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 24) {
                SCSpinner(size: 14, lineWidth: 1.5)
                SCSpinner()
                SCSpinner(size: 32, lineWidth: 3)
            }
            Button {
                isLoading = true
            } label: {
                HStack(spacing: 8) {
                    SCSpinner(size: 14, lineWidth: 1.5)
                    Text("Please wait")
                }
            }
            .buttonStyle(.sc())
            .disabled(isLoading)
            Button("Finish loading") { isLoading = false }
                .buttonStyle(.sc(.outline, size: .sm))
        }
    }
}

// MARK: - Toast

/// The toaster is applied to this demo's own bounded container, so toasts
/// stack inside the stage rather than over the whole app.
struct ToastDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            WrappingRow {
                Button("Default") {
                    SCToastCenter.shared.show(
                        title: "Event has been created",
                        description: "Sunday, December 03, 2023 at 9:00 AM"
                    )
                }
                .buttonStyle(.sc(.outline))

                Button("Success") {
                    SCToastCenter.shared.show(title: "Changes saved", variant: .success)
                }
                .buttonStyle(.sc(.outline))

                Button("Error") {
                    SCToastCenter.shared.show(
                        title: "Something went wrong",
                        description: "Your changes could not be saved.",
                        variant: .error
                    )
                }
                .buttonStyle(.sc(.outline))

                Button("Warning") {
                    SCToastCenter.shared.show(title: "Storage almost full", variant: .warning)
                }
                .buttonStyle(.sc(.outline))

                Button("With action") {
                    SCToastCenter.shared.show(
                        SCToast(
                            title: "Message archived",
                            action: SCToastAction("Undo") { print("undo") }
                        ))
                }
                .buttonStyle(.sc(.outline))
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .scToaster()
    }
}

#Preview("Feedback · Alert") { ShowcasePreview { AlertDemo() } }
#Preview("Feedback · Progress") { ShowcasePreview { ProgressDemo() } }
#Preview("Feedback · Skeleton") { ShowcasePreview { SkeletonDemo() } }
#Preview("Feedback · Spinner") { ShowcasePreview { SpinnerDemo() } }
#Preview("Feedback · Toast") { ShowcasePreview { ToastDemo() } }
