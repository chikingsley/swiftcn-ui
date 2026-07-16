import Swiftcn
import SwiftUI

/// Every drawer direction and modal behavior uses one caller-controlled
/// engine, with a draggable snap-point case, a real scroll body, routed
/// footer actions, close and Escape dismissal, and disabled trigger semantics.
struct DrawerValidationScene: View {
    @State private var actionCount = 0
    @State private var direction = SCDrawerSwipeDirection.down
    @State private var isPresented = false
    @State private var modalBehavior = SCDrawerModalBehavior.modal
    @State private var openChangeCount = 0
    @State private var presentationName = "direction-down"
    @State private var snapPoint: SCDrawerSnapPoint? = .fraction(0.3)
    @State private var usesSnapPoints = false

    private let snapPoints: [SCDrawerSnapPoint] = [
        .fraction(0.3), .fraction(0.6), .full,
    ]

    var body: some View {
        SCDrawer(
            isPresented: $isPresented,
            modalBehavior: modalBehavior,
            showSwipeHandle: true,
            snapPoints: usesSnapPoints ? snapPoints : [],
            snapPoint: usesSnapPoints ? $snapPoint : nil,
            swipeDirection: direction,
            panelSize: 340,
            maximumPanelSize: 520,
            onOpenChange: { _ in openChangeCount += 1 }
        ) {
            sceneContent
        } content: {
            SCDrawerContent {
                SCDrawerHeader {
                    SCDrawerTitle("Validation drawer")
                        .accessibilityIdentifier("drawer-title")
                    SCDrawerDescription("Direction: \(String(describing: direction))")
                        .accessibilityIdentifier("drawer-description")
                }

                Text("Snap: \(snapName)")
                    .accessibilityIdentifier("drawer-snap-echo")
                Text("Actions: \(actionCount)")
                    .accessibilityIdentifier("drawer-action-count")

                SCDrawerScrollContent {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(1...20, id: \.self) { row in
                            Text("Scrollable row \(row)")
                                .accessibilityIdentifier("drawer-row-\(row)")
                        }
                    }
                }
                .accessibilityIdentifier("drawer-scroll-body")

                SCDrawerFooter {
                    Button("Run drawer action") { actionCount += 1 }
                        .buttonStyle(.sc())
                        .accessibilityIdentifier("drawer-run-action")
                    SCDrawerClose("Dismiss drawer")
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("drawer-dismiss")
                }
            }
            .accessibilityIdentifier("drawer-\(presentationName)-content")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sceneContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Presented: \(isPresented ? "true" : "false")")
                .accessibilityIdentifier("drawer-presented-echo")
            Text("Open changes: \(openChangeCount)")
                .accessibilityIdentifier("drawer-open-change-count")
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("drawer-scene-action-count")

            HStack(spacing: 8) {
                ForEach(SCDrawerSwipeDirection.allCases, id: \.self) { candidate in
                    Button(String(describing: candidate).capitalized) {
                        configureDirection(candidate)
                    }
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("drawer-present-\(String(describing: candidate))")
                }
            }

            HStack(spacing: 8) {
                ForEach(SCDrawerModalBehavior.allCases, id: \.self) { behavior in
                    Button(String(describing: behavior)) {
                        configureBehavior(behavior)
                    }
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("drawer-present-behavior-\(String(describing: behavior))")
                }
            }

            Button("Present snap drawer") {
                direction = .down
                modalBehavior = .modal
                presentationName = "snap"
                snapPoint = .fraction(0.3)
                usesSnapPoints = true
                isPresented = true
            }
            .buttonStyle(.sc(.outline))
            .accessibilityIdentifier("drawer-present-snap")

            SCDrawerTrigger("Disabled drawer")
                .buttonStyle(.sc(.outline))
                .disabled(true)
                .accessibilityIdentifier("drawer-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var snapName: String {
        switch snapPoint {
        case .fraction(let fraction) where fraction == 0.3: "fraction-0.3"
        case .fraction(let fraction) where fraction == 0.6: "fraction-0.6"
        case .fraction: "fraction-other"
        case .points(let points): "points-\(Int(points))"
        case nil: "none"
        }
    }

    private func configureDirection(_ candidate: SCDrawerSwipeDirection) {
        direction = candidate
        modalBehavior = .modal
        presentationName = "direction-\(String(describing: candidate))"
        usesSnapPoints = false
        isPresented = true
    }

    private func configureBehavior(_ behavior: SCDrawerModalBehavior) {
        direction = .right
        modalBehavior = behavior
        presentationName = "behavior-\(String(describing: behavior))"
        usesSnapPoints = false
        isPresented = true
    }
}
