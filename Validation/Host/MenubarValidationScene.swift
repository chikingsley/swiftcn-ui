import SwiftUI
import Swiftcn

private enum MenubarValidationTheme: String, CaseIterable, Hashable {
    case light, dark, system
}

/// Both SCMenubar orientations, a per-menu disabled trigger, a whole-menubar
/// disabled instance, groups, plain/destructive/disabled/shortcut items, a
/// checkbox item, a radio group, and a submenu — each routing real native
/// Menu selection into caller-owned state mirrored in visible value texts,
/// so UI tests can prove rendering and selection routing through the
/// accessibility tree. SwiftUI's Menu owns popup presentation, so
/// opened-menu item interaction is asserted where XCUITest can reach it (see
/// the test file for what remains manual).
struct MenubarValidationScene: View {
    @State private var actionCount = 0
    @State private var lastAction = "none"
    @State private var showBookmarks = true
    @State private var selectedTheme = MenubarValidationTheme.system

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("menubar-action-count")
            Text("Last action: \(lastAction)")
                .accessibilityIdentifier("menubar-last-action")
            Text("Bookmarks: \(showBookmarks ? "on" : "off")")
                .accessibilityIdentifier("menubar-bookmarks-value")
            Text("Theme: \(selectedTheme.rawValue)")
                .accessibilityIdentifier("menubar-theme-value")

            SCMenubar {
                SCMenubarMenu {
                    SCMenubarTrigger("File")
                } content: {
                    SCMenubarContent {
                        SCMenubarGroup("File actions") {
                            SCMenubarItem(
                                shortcut: SCMenubarShortcut("n"),
                                action: { record("New File") },
                                label: { Text("New File") }
                            )
                            SCMenubarItem("New Incognito Window", isDisabled: true) {
                                record("New Incognito Window")
                            }
                        }
                        SCMenubarSeparator()
                        SCMenubarSub {
                            SCMenubarSubTrigger("Share")
                        } content: {
                            SCMenubarSubContent {
                                SCMenubarItem("Email") { record("Email") }
                            }
                        }
                        SCMenubarSeparator()
                        SCMenubarItem("Delete File", variant: .destructive) {
                            record("Delete File")
                        }
                    }
                }
                .accessibilityIdentifier("menubar-file-menu")

                SCMenubarMenu {
                    SCMenubarTrigger("View")
                } content: {
                    SCMenubarContent {
                        SCMenubarCheckboxItem("Show Bookmarks", isChecked: $showBookmarks)
                        SCMenubarSeparator()
                        SCMenubarRadioGroup("Theme", selection: $selectedTheme) {
                            ForEach(MenubarValidationTheme.allCases, id: \.self) { theme in
                                SCMenubarRadioItem(theme.rawValue.capitalized, value: theme)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("menubar-view-menu")

                SCMenubarMenu(isDisabled: true) {
                    SCMenubarTrigger("Help")
                } content: {
                    SCMenubarContent { EmptyView() }
                }
                .accessibilityIdentifier("menubar-help-menu")
            }
            .accessibilityIdentifier("menubar-horizontal")

            SCMenubar(orientation: .vertical) {
                SCMenubarMenu {
                    SCMenubarTrigger("Edit")
                } content: {
                    SCMenubarItem("Undo") { record("Undo") }
                }
                .accessibilityIdentifier("menubar-vertical-edit-menu")
            }
            .accessibilityIdentifier("menubar-vertical")

            SCMenubar(isDisabled: true) {
                SCMenubarMenu {
                    SCMenubarTrigger("Disabled")
                } content: {
                    SCMenubarItem("Unreachable") { record("Unreachable") }
                }
                .accessibilityIdentifier("menubar-disabled-menu")
            }
            .accessibilityIdentifier("menubar-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func record(_ action: String) {
        actionCount += 1
        lastAction = action
    }
}
