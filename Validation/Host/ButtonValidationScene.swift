import Swiftcn
import SwiftUI

/// Every SCButtonStyle variant and size wired to real actions, plus a
/// disabled control, so UI tests can prove rendering, activation routing,
/// and disabled semantics through the accessibility tree.
struct ButtonValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("button-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("button-last-activated")

            HStack(spacing: 8) {
                ForEach(SCButtonVariant.allCases, id: \.self) { variant in
                    let name = String(describing: variant)
                    Button(name) {
                        activationCount += 1
                        lastActivated = name
                    }
                    .buttonStyle(.sc(variant))
                    .accessibilityIdentifier("button-variant-\(name)")
                }
            }

            HStack(spacing: 8) {
                ForEach(SCButtonSize.allCases, id: \.self) { size in
                    let name = String(describing: size)
                    Button {
                        activationCount += 1
                        lastActivated = "size-\(name)"
                    } label: {
                        if name.hasPrefix("icon") {
                            Image(systemName: "star")
                                .accessibilityLabel("Star \(name)")
                        } else {
                            Text(name)
                        }
                    }
                    .buttonStyle(.sc(.outline, size: size))
                    .accessibilityIdentifier("button-size-\(name)")
                }
            }

            Button("Disabled") {
                activationCount += 1
                lastActivated = "disabled"
            }
            .buttonStyle(.sc())
            .disabled(true)
            .accessibilityIdentifier("button-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
