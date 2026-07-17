import SwiftUI
import Swiftcn

/// LTR and RTL SCDirectionProvider subtrees, a nested override, the
/// `.scDirection(_:)` modifier form, and SCDirectionReader mirrored into
/// visible text, so UI tests can prove the provider genuinely mirrors
/// SwiftUI's native layoutDirection — reversing real element order — rather
/// than merely rendering a label, through the accessibility tree's frames.
struct DirectionValidationScene: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCDirectionReader { direction in
                Text("Ambient: \(direction.rawValue)")
                    .accessibilityIdentifier("direction-ambient-echo")
            }

            SCDirectionProvider(.ltr) {
                VStack(alignment: .leading, spacing: 8) {
                    SCDirectionReader { direction in
                        Text("Provider: \(direction.rawValue)")
                            .accessibilityIdentifier("direction-ltr-echo")
                    }
                    HStack(spacing: 8) {
                        Text("First").accessibilityIdentifier("direction-ltr-first")
                        Text("Second").accessibilityIdentifier("direction-ltr-second")
                    }
                }
            }

            SCDirectionProvider(.rtl) {
                VStack(alignment: .leading, spacing: 8) {
                    SCDirectionReader { direction in
                        Text("Provider: \(direction.rawValue)")
                            .accessibilityIdentifier("direction-rtl-echo")
                    }
                    HStack(spacing: 8) {
                        Text("First").accessibilityIdentifier("direction-rtl-first")
                        Text("Second").accessibilityIdentifier("direction-rtl-second")
                    }

                    SCDirectionProvider(.ltr) {
                        VStack(alignment: .leading, spacing: 8) {
                            SCDirectionReader { direction in
                                Text("Nested: \(direction.rawValue)")
                                    .accessibilityIdentifier("direction-nested-echo")
                            }
                            HStack(spacing: 8) {
                                Text("First").accessibilityIdentifier("direction-nested-first")
                                Text("Second").accessibilityIdentifier("direction-nested-second")
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                SCDirectionReader { direction in
                    Text("Modifier: \(direction.rawValue)")
                        .accessibilityIdentifier("direction-modifier-echo")
                }
                HStack(spacing: 8) {
                    Text("First").accessibilityIdentifier("direction-modifier-first")
                    Text("Second").accessibilityIdentifier("direction-modifier-second")
                }
            }
            .scDirection(.rtl)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
