import SwiftUI
import Swiftcn

/// Three canonical ratios, explicit alignment and clipping behavior, plus a
/// state-driven alignment control and disabled surface, so UI tests can prove
/// exact geometry, caller-owned configuration, and accessibility semantics.
struct AspectRatioValidationScene: View {
    @Environment(\.theme) private var theme
    @State private var usesTrailingAlignment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Alignment: \(usesTrailingAlignment ? "bottom-trailing" : "top-leading")")
                .accessibilityIdentifier("aspectratio-alignment-echo")

            HStack(alignment: .top, spacing: 16) {
                ratioView(ratio: 16.0 / 9.0, label: "16:9")
                    .frame(width: 180)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("16 by 9 aspect ratio")
                    .accessibilityIdentifier("aspectratio-16-9")

                ratioView(ratio: 1, label: "1:1")
                    .frame(width: 120)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("1 by 1 aspect ratio")
                    .accessibilityIdentifier("aspectratio-1-1")

                ratioView(ratio: 4.0 / 3.0, label: "4:3")
                    .frame(width: 160)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("4 by 3 aspect ratio")
                    .accessibilityIdentifier("aspectratio-4-3")
            }

            HStack(alignment: .top, spacing: 16) {
                SCAspectRatio(
                    ratio: 2,
                    alignment: usesTrailingAlignment ? .bottomTrailing : .topLeading
                ) {
                    Image(systemName: "rectangle.fill")
                        .resizable()
                        .foregroundStyle(.orange)
                        .frame(width: 36, height: 24)
                        .accessibilityLabel("Alignment marker")
                        .accessibilityIdentifier("aspectratio-alignment-marker")
                }
                .background(.blue.opacity(0.15))
                .frame(width: 240)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("aspectratio-aligned")

                SCAspectRatio(ratio: 4.0 / 3.0) {
                    Image(systemName: "rectangle.fill")
                        .resizable()
                        .foregroundStyle(.purple)
                        .frame(width: 260, height: 160)
                        .accessibilityLabel("Oversized clipped content")
                        .accessibilityIdentifier("aspectratio-clipped-content")
                }
                .background(.gray.opacity(0.15))
                .frame(width: 160)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Clipped oversized content")
                .accessibilityIdentifier("aspectratio-clipped")
            }

            Button("Move marker") {
                usesTrailingAlignment.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("aspectratio-alignment-toggle")

            SCAspectRatio(ratio: 3) {
                Text("Disabled ratio")
            }
            .frame(width: 180)
            .disabled(true)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("aspectratio-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func ratioView(ratio: CGFloat, label: String) -> some View {
        SCAspectRatio(ratio: ratio) {
            Rectangle().fill(theme.muted)
            Text(label)
                .foregroundStyle(theme.foreground)
                .accessibilityIdentifier("aspectratio-label-\(label.replacing(":", with: "-"))")
        }
    }
}
