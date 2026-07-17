import SwiftUI
import Swiftcn

/// Vertical, horizontal, combined-axis, and disabled SCScrollArea viewports,
/// each with a marker at the far end of its scrollable content, so UI tests
/// can prove the real native ScrollView genuinely scrolls — and that
/// `isDisabled` genuinely blocks it — through the accessibility tree.
struct ScrollAreaValidationScene: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 16) {
                SCScrollArea(isBordered: true, accessibilityLabel: "Numbered rows") {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<40, id: \.self) { index in
                            Text("Row \(index)")
                                .accessibilityIdentifier("scrollarea-row-\(index)")
                        }
                        Text("Bottom marker")
                            .accessibilityIdentifier("scrollarea-bottom-marker")
                    }
                    .padding(16)
                }
                .frame(width: 200, height: 220)
                .accessibilityIdentifier("scrollarea-vertical")

                SCScrollArea(isDisabled: true, isBordered: true, accessibilityLabel: "Disabled scroll area") {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<40, id: \.self) { index in
                            Text("Locked row \(index)")
                        }
                        Text("Disabled bottom marker")
                            .accessibilityIdentifier("scrollarea-disabled-bottom-marker")
                    }
                    .padding(16)
                }
                .frame(width: 200, height: 220)
                .accessibilityIdentifier("scrollarea-disabled")
            }

            SCScrollArea(isBordered: true, accessibilityLabel: "Artwork") {
                LazyHStack(spacing: 12) {
                    ForEach(0..<12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.default.muted)
                            .frame(width: 100, height: 80)
                            .overlay {
                                Text("Card \(index)")
                            }
                    }
                    Text("Trailing marker")
                        .accessibilityIdentifier("scrollarea-trailing-marker")
                }
                .padding(16)
                SCScrollBar(orientation: .horizontal)
            }
            .frame(width: 320, height: 130)
            .accessibilityIdentifier("scrollarea-horizontal")

            SCScrollArea(axes: [.horizontal, .vertical], isBordered: true, accessibilityLabel: "Grid content") {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<20, id: \.self) { row in
                        Text(String(repeating: "Wide column content · ", count: 6) + "row \(row)")
                            .fixedSize()
                    }
                }
                .padding(16)
                .overlay(alignment: .bottomTrailing) {
                    Text("Corner marker")
                        .accessibilityIdentifier("scrollarea-corner-marker")
                }
            }
            .frame(width: 220, height: 160)
            .accessibilityIdentifier("scrollarea-both-axes")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
