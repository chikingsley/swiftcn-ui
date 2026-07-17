import SwiftUI
import Swiftcn

/// Every SCAttachment state, size, and orientation; both media variants; a
/// real SCAttachmentAction routing to caller-owned state alongside a
/// disabled action; a full-card SCAttachmentTrigger (including one that is
/// both disabled and in the error state); and an SCAttachmentGroup, so UI
/// tests can prove rendering, activation routing, and disabled semantics
/// through the accessibility tree.
struct AttachmentValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("attachment-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("attachment-last-activated")

            HStack(spacing: 12) {
                ForEach(SCAttachmentState.allCases, id: \.self) { state in
                    let name = String(describing: state)
                    SCAttachment(state: state) {
                        SCAttachmentMedia {
                            Image(systemName: "doc.text")
                        }
                        SCAttachmentContent {
                            SCAttachmentTitle("report-\(name).pdf")
                            SCAttachmentDescription(description(for: state))
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("attachment-state-\(name)")
                }
            }

            HStack(spacing: 12) {
                ForEach(SCAttachmentSize.allCases, id: \.self) { size in
                    let name = String(describing: size)
                    SCAttachment(size: size) {
                        SCAttachmentMedia {
                            Image(systemName: "doc")
                        }
                        SCAttachmentContent {
                            SCAttachmentTitle("size-\(name)")
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("attachment-size-\(name)")
                }
            }

            SCAttachment(orientation: .vertical) {
                SCAttachmentMedia(variant: .image) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFill()
                }
                SCAttachmentContent {
                    SCAttachmentTitle("vertical-orientation.png")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("attachment-orientation-vertical")

            SCAttachment {
                SCAttachmentMedia(variant: .icon) {
                    Image(systemName: "doc.text")
                }
                SCAttachmentContent {
                    SCAttachmentTitle("quarterly-report.pdf")
                    SCAttachmentDescription("Uploading · 72%")
                }
                SCAttachmentActions {
                    SCAttachmentAction(
                        action: {
                            activationCount += 1
                            lastActivated = "remove"
                        },
                        label: { Image(systemName: "xmark") }
                    )
                    .accessibilityLabel("Remove attachment")
                    .accessibilityIdentifier("attachment-action-remove")

                    SCAttachmentAction(
                        isDisabled: true,
                        action: {
                            activationCount += 1
                            lastActivated = "disabled-action"
                        },
                        label: { Image(systemName: "arrow.down") }
                    )
                    .accessibilityLabel("Download attachment")
                    .accessibilityIdentifier("attachment-action-disabled")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("attachment-with-actions")

            SCAttachmentTrigger(
                action: {
                    activationCount += 1
                    lastActivated = "trigger"
                }
            ) {
                SCAttachment {
                    SCAttachmentMedia {
                        Image(systemName: "doc.richtext")
                    }
                    SCAttachmentContent {
                        SCAttachmentTitle("full-card-trigger.pdf")
                        SCAttachmentDescription("Tap anywhere on the card")
                    }
                }
            }
            .accessibilityIdentifier("attachment-trigger")

            // Combines the disabled and error (the closest analog to an
            // "invalid" state this component exposes) instances: a real
            // SCAttachmentTrigger disabled while its card renders `.error`.
            SCAttachmentTrigger(
                isDisabled: true,
                action: {
                    activationCount += 1
                    lastActivated = "disabled-trigger"
                }
            ) {
                SCAttachment(state: .error) {
                    SCAttachmentMedia {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    SCAttachmentContent {
                        SCAttachmentTitle("disabled-and-error.zip")
                        SCAttachmentDescription("Upload failed")
                    }
                }
            }
            .accessibilityIdentifier("attachment-disabled")

            SCAttachmentGroup {
                SCAttachment(size: .small) {
                    SCAttachmentContent { SCAttachmentTitle("grouped-1.txt") }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("attachment-group-item-1")
                SCAttachment(size: .small) {
                    SCAttachmentContent { SCAttachmentTitle("grouped-2.txt") }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("attachment-group-item-2")
            }
            .frame(width: 320)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("attachment-group")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func description(for state: SCAttachmentState) -> String {
        switch state {
        case .idle: "Waiting to upload"
        case .uploading: "Uploading · 72%"
        case .processing: "Processing…"
        case .error: "Upload failed"
        case .done: "Uploaded"
        }
    }
}
