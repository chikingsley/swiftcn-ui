import Swiftcn
import SwiftUI

/// Every side/alignment and compact-adaptation option presents rich native
/// popover content, routes actions and close events into caller state, and
/// exposes disabled trigger and close semantics through accessibility.
struct PopoverValidationScene: View {
    @State private var actionCount = 0
    @State private var presentationChangeCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("popover-scene-action-count")
            Text("Presentation changes: \(presentationChangeCount)")
                .accessibilityIdentifier("popover-presentation-change-count")

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(PopoverPositionCase.all) { positionCase in
                    PopoverPositionExample(
                        positionCase: positionCase,
                        actionCount: $actionCount,
                        presentationChangeCount: $presentationChangeCount
                    )
                }
            }

            HStack(spacing: 8) {
                ForEach(SCPopoverCompactAdaptation.allCases, id: \.self) { adaptation in
                    PopoverAdaptationExample(
                        adaptation: adaptation,
                        actionCount: $actionCount,
                        presentationChangeCount: $presentationChangeCount
                    )
                }
            }

            SCPopover(isDisabled: true) {
                SCPopoverTrigger("Disabled popover")
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("popover-disabled")
            } content: {
                SCPopoverContent {
                    Text("Disabled content")
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), alignment: .leading), count: 3)
    }
}

private struct PopoverPositionCase: Identifiable, Sendable {
    let side: SCPopoverSide
    let alignment: SCPopoverAlignment

    var id: String {
        "\(String(describing: side))-\(String(describing: alignment))"
    }

    static let all = SCPopoverSide.allCases.flatMap { side in
        SCPopoverAlignment.allCases.map { alignment in
            PopoverPositionCase(side: side, alignment: alignment)
        }
    }
}

private struct PopoverPositionExample: View {
    let positionCase: PopoverPositionCase
    @Binding var actionCount: Int
    @Binding var presentationChangeCount: Int
    @State private var isPresented = false

    var body: some View {
        SCPopover(
            isPresented: $isPresented,
            position: SCPopoverPosition(
                side: positionCase.side,
                alignment: positionCase.alignment
            ),
            onPresentedChange: { _, _ in presentationChangeCount += 1 }
        ) {
            SCPopoverTrigger(positionCase.id)
                .buttonStyle(.sc(.outline, size: .sm))
                .accessibilityIdentifier("popover-present-\(positionCase.id)")
        } content: {
            validationContent(identifier: positionCase.id)
        }
    }

    private func validationContent(identifier: String) -> some View {
        SCPopoverContent(width: 280) {
            VStack(alignment: .leading, spacing: 12) {
                SCPopoverHeader {
                    SCPopoverTitle("Popover details")
                        .accessibilityIdentifier("popover-title")
                    SCPopoverDescription("Rich content in a native presentation window.")
                        .accessibilityIdentifier("popover-description")
                }
                Text("Actions: \(actionCount)")
                    .accessibilityIdentifier("popover-action-count")
                Button("Run popover action") { actionCount += 1 }
                    .buttonStyle(.sc())
                    .accessibilityIdentifier("popover-run-action")
                SCPopoverClose("Disabled close", isDisabled: true)
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("popover-disabled-close")
                SCPopoverClose("Dismiss popover")
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("popover-dismiss")
            }
        }
        .accessibilityIdentifier("popover-\(identifier)-content")
    }
}

private struct PopoverAdaptationExample: View {
    let adaptation: SCPopoverCompactAdaptation
    @Binding var actionCount: Int
    @Binding var presentationChangeCount: Int
    @State private var isPresented = false

    private var name: String {
        String(describing: adaptation)
    }

    var body: some View {
        SCPopover(
            isPresented: $isPresented,
            compactAdaptation: adaptation,
            onPresentedChange: { _, _ in presentationChangeCount += 1 }
        ) {
            SCPopoverTrigger(name)
                .buttonStyle(.sc(.outline, size: .sm))
                .accessibilityIdentifier("popover-adaptation-\(name)")
        } content: {
            SCPopoverContent(width: 240) {
                VStack(alignment: .leading, spacing: 12) {
                    SCPopoverTitle("Adaptation: \(name)")
                        .accessibilityIdentifier("popover-adaptation-title")
                    Text("Actions: \(actionCount)")
                        .accessibilityIdentifier("popover-action-count")
                    Button("Run popover action") { actionCount += 1 }
                        .buttonStyle(.sc())
                        .accessibilityIdentifier("popover-run-action")
                    SCPopoverClose("Dismiss popover")
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("popover-dismiss")
                }
            }
            .accessibilityIdentifier("popover-adaptation-\(name)-content")
        }
    }
}
