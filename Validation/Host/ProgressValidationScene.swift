import SwiftUI
import Swiftcn

/// SCProgress's determinate lifecycle, indeterminate state, built-in label and
/// value slots, custom composition, and disabled state, with an external action
/// proving caller-owned progress updates reach native accessibility semantics.
struct ProgressValidationScene: View {
    @State private var uploadValue = 25.0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Upload: \(uploadValue.formatted(.number.precision(.fractionLength(0))))")
                .accessibilityIdentifier("progress-value-echo")
            Button("Advance upload") {
                uploadValue = min(uploadValue + 25, 100)
            }
            .accessibilityIdentifier("progress-advance")

            SCProgress(value: 0, accessibilityLabel: "Empty progress")
                .accessibilityIdentifier("progress-empty")
                .frame(width: 320)
            SCProgress(
                value: uploadValue,
                accessibilityLabel: "Upload progress",
                accessibilityValue: "\(Int(uploadValue)) percent"
            ) {
                SCProgressLabel("Upload progress")
                SCProgressValue()
            }
            .accessibilityIdentifier("progress-determinate")
            .frame(width: 320)
            SCProgress(value: 100, accessibilityLabel: "Complete progress")
                .accessibilityIdentifier("progress-complete")
                .frame(width: 320)
            SCProgress(value: nil, accessibilityLabel: "Indeterminate progress")
                .accessibilityIdentifier("progress-indeterminate")
                .frame(width: 320)

            SCProgress(
                value: 60,
                accessibilityLabel: "Custom progress",
                accessibilityValue: "Working",
                showsDefaultTrack: false
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    SCProgressLabel {
                        Label("Custom upload", systemImage: "shippingbox")
                    }
                    SCProgressValue { snapshot in
                        Text(snapshot.status == .complete ? "Complete" : "Working")
                    }
                    SCProgressTrack(height: 8) {
                        SCProgressIndicator { _ in
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                }
            }
            .accessibilityIdentifier("progress-custom")
            .frame(width: 320)

            SCProgress(value: 50, accessibilityLabel: "Disabled progress")
                .disabled(true)
                .accessibilityIdentifier("progress-disabled")
                .frame(width: 320)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
