import SwiftUI
import Swiftcn

private enum DropdownMenuValidationPosition: String, CaseIterable, Hashable {
    case top, bottom, right
}

/// Every SCDropdownMenu part — groups, plain/destructive/disabled/shortcut
/// items, a checkbox item, a radio group, and a submenu — plus a disabled
/// trigger, each routing real native Menu selection into caller-owned state
/// mirrored in visible value texts, so UI tests can prove rendering and
/// selection routing through the accessibility tree. SwiftUI's Menu owns
/// popup presentation, so opened-menu item interaction is asserted where
/// XCUITest can reach it (see the test file for what remains manual).
struct DropdownMenuValidationScene: View {
    @State private var actionCount = 0
    @State private var lastAction = "none"
    @State private var showStatusBar = true
    @State private var selectedPosition = DropdownMenuValidationPosition.bottom

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("dropdownmenu-action-count")
            Text("Last action: \(lastAction)")
                .accessibilityIdentifier("dropdownmenu-last-action")
            Text("Status bar: \(showStatusBar ? "on" : "off")")
                .accessibilityIdentifier("dropdownmenu-status-bar-value")
            Text("Position: \(selectedPosition.rawValue)")
                .accessibilityIdentifier("dropdownmenu-position-value")

            SCDropdownMenu {
                SCDropdownMenuTrigger {
                    Text("Open menu")
                }
            } content: {
                SCDropdownMenuContent {
                    SCDropdownMenuGroup("My Account") {
                        SCDropdownMenuItem(
                            shortcut: SCDropdownMenuShortcut("p", modifiers: [.command, .shift]),
                            action: { record("Profile") },
                            label: { Text("Profile") }
                        )
                        SCDropdownMenuItem("Billing") { record("Billing") }
                        SCDropdownMenuItem("API", isDisabled: true) { record("API") }
                    }
                    SCDropdownMenuSeparator()
                    SCDropdownMenuCheckboxItem("Show Status Bar", isChecked: $showStatusBar)
                    SCDropdownMenuRadioGroup("Panel Position", selection: $selectedPosition) {
                        ForEach(DropdownMenuValidationPosition.allCases, id: \.self) { position in
                            SCDropdownMenuRadioItem(position.rawValue.capitalized, value: position)
                        }
                    }
                    SCDropdownMenuSub {
                        SCDropdownMenuSubTrigger {
                            Text("Invite Users")
                        }
                    } content: {
                        SCDropdownMenuSubContent {
                            SCDropdownMenuItem("Email") { record("Email") }
                        }
                    }
                    SCDropdownMenuSeparator()
                    SCDropdownMenuItem("Log Out", variant: .destructive) { record("Log Out") }
                }
            }
            .buttonStyle(.sc(.outline))
            .accessibilityIdentifier("dropdownmenu-trigger")

            SCDropdownMenu {
                SCDropdownMenuTrigger {
                    Text("Disabled menu")
                }
            } content: {
                SCDropdownMenuContent {
                    SCDropdownMenuItem("Unreachable") {}
                }
            }
            .buttonStyle(.sc(.outline))
            .disabled(true)
            .accessibilityIdentifier("dropdownmenu-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func record(_ action: String) {
        actionCount += 1
        lastAction = action
    }
}
