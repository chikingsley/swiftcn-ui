import SwiftUI
import Swiftcn

private struct CommandValidationTask: Identifiable {
    let id: String
    let title: String
    let isEnabled: Bool
}

private let commandValidationTasks: [SCCommandSection<CommandValidationTask>] = [
    SCCommandSection(
        id: "tasks",
        title: "Tasks",
        items: [
            CommandValidationTask(id: "enabled", title: "Enabled Task", isEnabled: true),
            CommandValidationTask(id: "disabled", title: "Disabled Task", isEnabled: false),
        ]
    )
]

/// The shadcn-parity SCCommandList (grouped, searchable, keyword-filtered
/// items with decorative shortcut hints), a whole-root disabled SCCommandRoot
/// composition, the generic SCCommandCollection's per-item isItemEnabled
/// support, and the `.scCommandPalette` ⌘K dialog presentation — each routing
/// real selection into caller-owned state mirrored in visible value texts, so
/// UI tests can prove rendering, search filtering, selection routing, and
/// disabled semantics through the accessibility tree.
///
/// SCCommandItem itself has no `isDisabled` field (unlike SCSelectItem or
/// SCComboboxOption), so per-item disabling is only reachable through the
/// generic SCCommandCollection<Item> engine below, not the SCCommandItem-
/// based SCCommandList convenience — see the final report for this note.
struct CommandValidationScene: View {
    @State private var inlineRunCount = 0
    @State private var lastInlineRun = "none"
    @State private var paletteRunCount = 0
    @State private var lastPaletteRun = "none"
    @State private var taskRunCount = 0
    @State private var lastTaskRun = "none"
    @State private var disabledRootActionCount = 0
    @State private var isPaletteOpen = false

    var body: some View {
        // The two collections sit side by side and status lines are tightly
        // stacked so the whole scene — including the palette trigger — fits
        // inside the fixed 780x560 validation window; a taller vertical stack
        // pushed the generic collection and trigger below the window edge,
        // where XCUITest reports them as unhittable.
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Inline runs: \(inlineRunCount)")
                    .accessibilityIdentifier("command-inline-run-count")
                Text("Last inline: \(lastInlineRun)")
                    .accessibilityIdentifier("command-last-inline-run")
                Text("Palette runs: \(paletteRunCount)")
                    .accessibilityIdentifier("command-palette-run-count")
                Text("Last palette: \(lastPaletteRun)")
                    .accessibilityIdentifier("command-last-palette-run")
                Text("Task runs: \(taskRunCount)")
                    .accessibilityIdentifier("command-task-run-count")
                Text("Last task: \(lastTaskRun)")
                    .accessibilityIdentifier("command-last-task-run")
                Text("Disabled root actions: \(disabledRootActionCount)")
                    .accessibilityIdentifier("command-disabled-root-action-count")
            }

            HStack(alignment: .top, spacing: 16) {
                SCCommandList(groups: inlineGroups, placeholder: "Search commands…")
                    .frame(width: 320, height: 200)

                VStack(alignment: .leading, spacing: 12) {
                    genericTaskCollection
                    disabledCommandRoot
                }
            }

            Button("Open command palette") {
                isPaletteOpen = true
            }
            .buttonStyle(.sc(.outline))
            .accessibilityIdentifier("command-palette-trigger")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .scCommandPalette(
            isPresented: $isPaletteOpen,
            groups: paletteGroups,
            placeholder: "Search palette…"
        )
    }

    private var inlineGroups: [SCCommandGroup] {
        [
            SCCommandGroup(
                label: "Suggestions",
                items: [
                    commandItem(
                        title: "Calendar",
                        systemImage: "calendar",
                        countBinding: $inlineRunCount,
                        lastRunBinding: $lastInlineRun
                    ),
                    commandItem(
                        title: "Search Emoji",
                        systemImage: "face.smiling",
                        keywords: ["smiley", "emoticon"],
                        countBinding: $inlineRunCount,
                        lastRunBinding: $lastInlineRun
                    ),
                ]
            ),
            SCCommandGroup(
                label: "Settings",
                items: [
                    commandItem(
                        title: "Profile",
                        systemImage: "person",
                        shortcut: "⌘P",
                        countBinding: $inlineRunCount,
                        lastRunBinding: $lastInlineRun
                    ),
                    commandItem(
                        title: "Billing",
                        systemImage: "creditcard",
                        shortcut: "⌘B",
                        countBinding: $inlineRunCount,
                        lastRunBinding: $lastInlineRun
                    ),
                ]
            ),
        ]
    }

    private var paletteGroups: [SCCommandGroup] {
        [
            SCCommandGroup(
                label: "Palette",
                items: [
                    commandItem(
                        title: "Palette Action A",
                        countBinding: $paletteRunCount,
                        lastRunBinding: $lastPaletteRun
                    ),
                    commandItem(
                        title: "Palette Action B",
                        countBinding: $paletteRunCount,
                        lastRunBinding: $lastPaletteRun
                    ),
                ]
            )
        ]
    }

    private var genericTaskCollection: some View {
        SCCommandCollection(
            sections: commandValidationTasks,
            id: \.id,
            placeholder: "Search tasks…",
            itemText: { $0.title },
            isItemEnabled: { $0.isEnabled },
            onSelect: { task in
                taskRunCount += 1
                lastTaskRun = task.title
            },
            row: { task, _ in Text(task.title) },
            sectionHeader: { section in
                if let title = section.title {
                    Text(title)
                }
            },
            empty: { Text("No tasks.") }
        )
        .frame(width: 320, height: 130)
    }

    private var disabledCommandRoot: some View {
        SCCommandRoot(isDisabled: true) {
            VStack(alignment: .leading, spacing: 0) {
                SCCommandInput(placeholder: "Disabled search…", autoFocus: false)
                SCCommandSeparator()
                SCCommandItemView(action: { disabledRootActionCount += 1 }) {
                    Text("Disabled item")
                }
                .accessibilityIdentifier("command-disabled-item")
            }
        }
        .frame(width: 320)
    }

    /// Builds an `SCCommandItem` whose action mutates caller-owned state via
    /// explicit `Binding` captures. `SCCommandItem.action` is `@Sendable`
    /// (the whole struct conforms to `Sendable`), so the closure must not
    /// capture `self` — only the Sendable `Binding` values passed in below.
    private func commandItem(
        title: String,
        systemImage: String? = nil,
        shortcut: String? = nil,
        keywords: [String] = [],
        countBinding: Binding<Int>,
        lastRunBinding: Binding<String>
    ) -> SCCommandItem {
        SCCommandItem(
            title: title,
            systemImage: systemImage,
            shortcut: shortcut,
            keywords: keywords
        ) {
            countBinding.wrappedValue += 1
            lastRunBinding.wrappedValue = title
        }
    }
}
