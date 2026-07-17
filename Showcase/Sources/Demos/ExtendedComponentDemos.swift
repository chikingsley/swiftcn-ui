// ============================================================
// ExtendedComponentDemos.swift — Swiftcn macOS Showcase
// Live surfaces for the official components added after the first gallery.
// ============================================================
import SwiftUI
import Swiftcn

struct AspectRatioDemo: View {
    var body: some View {
        SCAspectRatio(ratio: 16 / 9) {
            LinearGradient(
                colors: [.indigo, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("16:9")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
        .frame(width: 420)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ContextMenuDemo: View {
    private enum ThemeChoice: String, CaseIterable {
        case system, light, dark
    }

    @State private var showsBookmarks = true
    @State private var theme = ThemeChoice.system
    @State private var lastAction = "Right-click or long-press."

    var body: some View {
        VStack(spacing: 16) {
            SCContextMenu {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.default.border)
                    .frame(width: 320, height: 150)
                    .overlay { Text("Right-click or long-press") }
            } content: {
                SCContextMenuGroup {
                    SCContextMenuItem(
                        action: { lastAction = "Copy" },
                        label: { Label("Copy", systemImage: "doc.on.doc") }
                    )
                    SCContextMenuCheckboxItem(isChecked: $showsBookmarks) {
                        Text("Show Bookmarks")
                    }
                }
                SCContextMenuSeparator()
                SCContextMenuRadioGroup("Theme", selection: $theme) {
                    ForEach(ThemeChoice.allCases, id: \.self) { value in
                        SCContextMenuRadioItem(value: value) {
                            Text(value.rawValue.capitalized)
                        }
                    }
                }
                SCContextMenuSub {
                    Text("More Tools")
                } content: {
                    SCContextMenuItem(
                        action: { lastAction = "Developer Tools" },
                        label: { Text("Developer Tools") }
                    )
                    SCContextMenuItem(
                        variant: .destructive,
                        action: { lastAction = "Delete" },
                        label: { Text("Delete") }
                    )
                }
            }
            Text(lastAction).scMuted()
        }
    }
}

struct DataTableDemo: View {
    private struct Payment: Identifiable {
        let id: String
        let status: String
        let email: String
        let amount: Double
    }

    @State private var controller = SCDataTableController<Payment>(pageSize: 3)

    private let rows = [
        Payment(id: "pay-001", status: "Success", email: "ken99@example.com", amount: 316),
        Payment(id: "pay-002", status: "Success", email: "abe45@example.com", amount: 242),
        Payment(id: "pay-003", status: "Processing", email: "monserrat44@example.com", amount: 837),
        Payment(id: "pay-004", status: "Failed", email: "carmella@example.com", amount: 721),
        Payment(id: "pay-005", status: "Success", email: "simon@example.com", amount: 149),
    ]

    private var columns: [SCTableColumn<Payment>] {
        [
            SCTableColumn("Status", width: .min(100)) { $0.status },
            SCTableColumn(
                "Email",
                comparator: { $0.email < $1.email },
                value: { $0.email }
            ),
            SCTableColumn(
                "Amount",
                alignment: .trailing,
                comparator: { $0.amount < $1.amount },
                value: { $0.amount.formatted(.currency(code: "USD")) }
            ),
        ]
    }

    var body: some View {
        SCDataTable(rows: rows, columns: columns, controller: controller)
            .frame(width: 760, height: 420)
    }
}

struct DirectionDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            SCDirectionProvider(.ltr) {
                Label("Account settings", systemImage: "chevron.forward")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SCDirectionProvider(.rtl) {
                Label("إعدادات الحساب", systemImage: "chevron.forward")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SCDirectionReader { direction in
                Text("Current direction: \(direction.rawValue)")
            }
        }
        .frame(width: 420)
    }
}

struct DropdownMenuDemo: View {
    private enum Position: String, CaseIterable {
        case top, bottom, left, right
    }

    @State private var showStatusBar = true
    @State private var selectedPosition = Position.bottom
    @State private var lastAction = "No action"

    var body: some View {
        VStack(spacing: 16) {
            SCDropdownMenu {
                SCDropdownMenuTrigger {
                    Label("Open", systemImage: "ellipsis.circle")
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                }
            } content: {
                SCDropdownMenuContent {
                    SCDropdownMenuGroup("My Account") {
                        SCDropdownMenuItem("Profile") { lastAction = "Profile" }
                        SCDropdownMenuItem("Billing") { lastAction = "Billing" }
                    }
                    SCDropdownMenuSeparator()
                    SCDropdownMenuCheckboxItem(
                        "Show Status Bar",
                        isChecked: $showStatusBar
                    )
                    SCDropdownMenuRadioGroup(
                        "Panel Position",
                        selection: $selectedPosition
                    ) {
                        ForEach(Position.allCases, id: \.self) { position in
                            SCDropdownMenuRadioItem(
                                position.rawValue.capitalized,
                                value: position
                            )
                        }
                    }
                    SCDropdownMenuSeparator()
                    SCDropdownMenuItem(
                        "Log Out",
                        variant: .destructive,
                        action: { lastAction = "Log Out" }
                    )
                }
            }
            .buttonStyle(.sc(.outline))
            Text(lastAction).scMuted()
        }
    }
}

struct InputGroupDemo: View {
    @State private var query = ""
    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            SCInputGroup {
                SCInputGroupInput("Search documentation", text: $query, kind: .search)
                SCInputGroupAddon {
                    Image(systemName: "magnifyingglass")
                }
                SCInputGroupAddon(alignment: .inlineEnd) {
                    SCInputGroupText("\(query.count)")
                    SCInputGroupButton(size: .iconXS) {
                        copied = true
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            Text(copied ? "Copied" : "Type a query, then use the copy action.")
                .scMuted()
        }
        .frame(width: 520)
    }
}

struct MenubarDemo: View {
    private enum ThemeChoice: String, CaseIterable {
        case system, light, dark
    }

    @State private var showBookmarks = true
    @State private var theme = ThemeChoice.system
    @State private var lastAction = "No action"

    var body: some View {
        VStack(spacing: 16) {
            SCMenubar {
                SCMenubarMenu {
                    SCMenubarTrigger("File")
                } content: {
                    SCMenubarContent {
                        SCMenubarItem("New File") { lastAction = "New File" }
                        SCMenubarSeparator()
                        SCMenubarItem(
                            "Delete File",
                            variant: .destructive,
                            action: { lastAction = "Delete" }
                        )
                    }
                }
                SCMenubarMenu {
                    SCMenubarTrigger("View")
                } content: {
                    SCMenubarContent {
                        SCMenubarCheckboxItem(
                            "Show Bookmarks",
                            isChecked: $showBookmarks
                        )
                        SCMenubarRadioGroup("Theme", selection: $theme) {
                            ForEach(ThemeChoice.allCases, id: \.self) { value in
                                SCMenubarRadioItem(
                                    value.rawValue.capitalized,
                                    value: value
                                )
                            }
                        }
                    }
                }
            }
            Text(lastAction).scMuted()
        }
    }
}

struct NativeSelectDemo: View {
    private enum Food: String, CaseIterable {
        case none, apple, banana, blueberry, carrot, broccoli
    }

    @State private var food = Food.none

    var body: some View {
        SCField("Food", description: "Select a food.") {
            SCNativeSelect(selection: $food, accessibilityLabel: "Food") {
                SCNativeSelectOption("Select a food", value: Food.none)
                SCNativeSelectOptGroup("Fruits") {
                    SCNativeSelectOption("Apple", value: Food.apple)
                    SCNativeSelectOption("Banana", value: Food.banana)
                    SCNativeSelectOption("Blueberry", value: Food.blueberry)
                }
                SCNativeSelectOptGroup("Vegetables") {
                    SCNativeSelectOption("Carrot", value: Food.carrot)
                    SCNativeSelectOption("Broccoli", value: Food.broccoli)
                }
            }
        }
        .frame(width: 420)
    }
}

struct NavigationMenuDemo: View {
    @State private var openItem: String? = ShowcaseCaptureMode.isEnabled ? "getting-started" : nil
    @State private var lastAction = "Choose a destination."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCNavigationMenu(value: $openItem) {
                SCNavigationMenuList {
                    SCNavigationMenuItem(value: "getting-started") {
                        SCNavigationMenuTrigger("Getting started")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 320) {
                            VStack(alignment: .leading, spacing: 4) {
                                SCNavigationMenuAction {
                                    lastAction = "Introduction"
                                } label: {
                                    Text("Introduction")
                                }
                                SCNavigationMenuAction {
                                    lastAction = "Installation"
                                } label: {
                                    Text("Installation")
                                }
                            }
                        }
                    }
                    SCNavigationMenuItem(value: "components") {
                        SCNavigationMenuTrigger("Components")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 320) {
                            SCNavigationMenuAction {
                                lastAction = "Data Table"
                            } label: {
                                Text("Data Table")
                            }
                        }
                    }
                    SCNavigationMenuItem(value: "documentation") {
                        SCNavigationMenuAction(
                            presentation: .trigger,
                            action: { lastAction = "Documentation" },
                            label: { Text("Documentation") }
                        )
                    }
                }
            }
            Text(lastAction).scMuted()
        }
        .frame(width: 700, height: 360)
    }
}

struct ScrollAreaDemo: View {
    var body: some View {
        SCScrollArea(isBordered: true, accessibilityLabel: "Version tags") {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("Tags").font(.headline)
                ForEach(0..<50, id: \.self) { index in
                    Text("v1.2.0-beta.\(50 - index)")
                    SCSeparator(isDecorative: true)
                }
            }
            .padding(16)
        }
        .frame(width: 240, height: 320)
    }
}

struct SonnerDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Show toast") {
                SCSonner.show(
                    "Event has been created",
                    description: "Monday, January 3rd at 6:00pm"
                )
            }
            .buttonStyle(.sc(.outline))
            Button("Show promise") {
                SCSonner.promise(
                    {
                        try await Task.sleep(for: .seconds(1))
                        return "Report"
                    },
                    loading: "Saving…",
                    success: { "\($0) saved" },
                    failure: { $0.localizedDescription }
                )
            }
            .buttonStyle(.sc(.outline))
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .scSonnerToaster()
        .onAppear {
            guard ShowcaseCaptureMode.isEnabled else { return }
            SCSonner.show(
                "Event has been created",
                description: "Monday, January 3rd at 6:00pm"
            )
        }
    }
}
