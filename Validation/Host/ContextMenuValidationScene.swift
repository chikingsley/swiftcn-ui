import SwiftUI
import Swiftcn

private enum ContextMenuValidationTheme: String, CaseIterable, Hashable {
    case light, dark, system
}

/// SCContextMenu's real right-click presentation with grouped items — a
/// shortcut item, a checkbox item, a radio group, a submenu, a disabled item,
/// and a destructive item — plus the `.scContextMenu` view-modifier form,
/// each routing real selection into caller-owned state mirrored in visible
/// value texts, so UI tests can prove rendering and selection routing
/// through the accessibility tree. SwiftUI's contextMenu owns popup
/// presentation, so opened-menu item interaction is asserted where XCUITest
/// can reach it (see the test file for what remains manual).
struct ContextMenuValidationScene: View {
    @State private var actionCount = 0
    @State private var lastAction = "none"
    @State private var showsBookmarks = true
    @State private var selectedTheme = ContextMenuValidationTheme.system
    @State private var modifierActionCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("contextmenu-action-count")
            Text("Last action: \(lastAction)")
                .accessibilityIdentifier("contextmenu-last-action")
            Text("Bookmarks: \(showsBookmarks ? "on" : "off")")
                .accessibilityIdentifier("contextmenu-bookmarks-value")
            Text("Theme: \(selectedTheme.rawValue)")
                .accessibilityIdentifier("contextmenu-theme-value")
            Text("Modifier actions: \(modifierActionCount)")
                .accessibilityIdentifier("contextmenu-modifier-action-count")

            SCContextMenu {
                triggerBox(label: "Right-click here", identifier: "contextmenu-trigger")
            } content: {
                SCContextMenuGroup {
                    SCContextMenuItem(
                        shortcut: SCContextMenuShortcut("c"),
                        action: { record("Copy") },
                        label: { Text("Copy") }
                    )
                    SCContextMenuCheckboxItem(isChecked: $showsBookmarks) {
                        Text("Show Bookmarks")
                    }
                }
                SCContextMenuSeparator()
                SCContextMenuRadioGroup("Theme", selection: $selectedTheme) {
                    ForEach(ContextMenuValidationTheme.allCases, id: \.self) { theme in
                        SCContextMenuRadioItem(value: theme) {
                            Text(theme.rawValue.capitalized)
                        }
                    }
                }
                SCContextMenuSub {
                    Text("More Tools")
                } content: {
                    SCContextMenuItem(action: { record("Developer Tools") }) {
                        Text("Developer Tools")
                    }
                    SCContextMenuItem(isDisabled: true, action: { record("Unreachable") }) {
                        Text("Unreachable")
                    }
                    SCContextMenuItem(variant: .destructive, action: { record("Delete") }) {
                        Text("Delete")
                    }
                }
            }

            triggerBox(label: "Right-click (modifier form)", identifier: "contextmenu-modifier-trigger")
                .scContextMenu {
                    SCContextMenuItem(action: { modifierActionCount += 1 }) {
                        Text("Modifier Action")
                    }
                }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// A right-clickable surface. It is a real `Button` (empty primary action)
    /// so it exposes a genuine AX press action — a hand-rolled
    /// `.accessibilityAddTraits(.isButton)` element would claim button
    /// semantics without an action and fail Apple's `.action` audit. The
    /// context menu is what the right-click actually opens; the primary action
    /// is intentionally inert.
    private func triggerBox(label: String, identifier: String) -> some View {
        Button {
            // Inert: a context-menu target is activated by right-click, not by
            // a primary press. The empty action still gives VoiceOver a real
            // AX action so the element is not flagged as action-less.
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary)
                .frame(width: 260, height: 80)
                .overlay { Text(label) }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func record(_ action: String) {
        actionCount += 1
        lastAction = action
    }
}
