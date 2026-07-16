import SwiftUI
import Swiftcn

/// Every typed key, arbitrary and convenience keycap composition, coherent
/// shortcut groups, and explicitly labeled icon-only content, plus a real
/// action and disabled keycap for interaction and accessibility validation.
struct KbdValidationScene: View {
    @State private var activationCount = 0

    private let typedKeys: [(id: String, key: SCKbdKey)] = [
        ("command", .command), ("control", .control), ("option", .option),
        ("shift", .shift), ("caps-lock", .capsLock), ("escape", .escape),
        ("tab", .tab), ("return", .returnKey), ("delete", .delete),
        ("forward-delete", .forwardDelete), ("space", .space),
        ("arrow-up", .arrowUp), ("arrow-down", .arrowDown),
        ("arrow-left", .arrowLeft), ("arrow-right", .arrowRight),
        ("character", .character("K")),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("kbd-activation-count")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(
                            row * 6..<min(row * 6 + 6, typedKeys.count),
                            id: \.self
                        ) { index in
                            SCKbd(typedKeys[index].key)
                                .accessibilityIdentifier("kbd-key-\(typedKeys[index].id)")
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                SCKbd("⌘K", accessibilityLabel: "Command K")
                    .accessibilityIdentifier("kbd-arbitrary-string")

                SCKbdGroup(["Ctrl", "K"])
                    .accessibilityLabel("Control, K")
                    .accessibilityIdentifier("kbd-group-string-array")

                SCKbdGroup([.command, .shift, .character("P")])
                    .accessibilityIdentifier("kbd-group-typed")

                SCKbdGroup(accessibilityLabel: "Previous and next") {
                    SCKbd(accessibilityLabel: "Previous") {
                        Image(systemName: "arrow.left")
                    }
                    SCKbd(accessibilityLabel: "Next") {
                        Image(systemName: "arrow.right")
                    }
                }
                .accessibilityIdentifier("kbd-group-icon-only")
            }

            Button {
                activationCount += 1
            } label: {
                HStack(spacing: 8) {
                    Text("Run shortcut")
                    SCKbd(.returnKey)
                }
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("kbd-action-button")

            SCKbd(.escape)
                .disabled(true)
                .accessibilityIdentifier("kbd-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
