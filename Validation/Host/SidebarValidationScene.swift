import SwiftUI
import Swiftcn

/// The full sidebar family composed around one externally owned
/// SCSidebarState (trigger, ⌘B/⌃B, and the rail all echo into
/// caller-observable Text so collapse/expand is provably real rather than
/// internal-only): header, a labeled group with a group action, a menu with
/// active/badged/disabled rows, a menu-row action, a nested sub-menu, a
/// search input, a loading skeleton, a separator, and a footer. A second,
/// independent, minimal SCSidebarLayout below it uses the real
/// `persistenceKey` (UserDefaults-backed) restore path instead of external
/// state, so a UI test can prove collapse state survives an app relaunch.
struct SidebarValidationScene: View {
    @State private var sidebarState = SCSidebarState(isOpen: true, collapsible: .icon)
    @State private var selection = "Home"
    @State private var activationCount = 0
    @State private var lastActivated = "none"
    @State private var openChangeCount = 0
    @State private var search = ""
    @State private var persistedOpen =
        UserDefaults.standard.object(forKey: "sc.validation.sidebar.persisted") as? Bool ?? true

    enum Part {
        case main
        case persisted
    }

    let part: Part

    // The persisted layout lives under its own scene key ("sidebarpersisted"):
    // auditing both layouts in one scene repeatedly hit Apple's audit timeout
    // (Code -56), and the two are independent by design.
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch part {
            case .main: mainPart
            case .persisted: persistedPart
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var mainPart: some View {
        HStack(spacing: 16) {
            Text("Open: \(sidebarState.isOpen ? "true" : "false")")
                .accessibilityIdentifier("sidebar-open-state")
            Text("OpenChanges: \(openChangeCount)")
                .accessibilityIdentifier("sidebar-open-change-count")
            Text("Selection: \(selection)")
                .accessibilityIdentifier("sidebar-selection-echo")
        }
        HStack(spacing: 16) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("sidebar-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("sidebar-last-activated")
            Text("Search: \(search)")
                .accessibilityIdentifier("sidebar-search-echo")
        }

        SCSidebarLayout(
            collapsible: .icon,
            persistenceKey: nil,
            expandedWidth: 200,
            collapsedWidth: 48,
            state: sidebarState,
            onOpenChange: { _ in openChangeCount += 1 }
        ) {
            SCSidebarHeader {
                Text("Swiftcn").font(.caption.weight(.semibold))
                    .accessibilityIdentifier("sidebar-header-label")
            }
            SCSidebarContent {
                SCSidebarGroup("Platform") {
                    SCSidebarGroupContent {
                        SCSidebarMenu {
                            SCSidebarMenuItem {
                                SCSidebarMenuButton(
                                    "Home", systemImage: "house",
                                    isActive: selection == "Home"
                                ) {
                                    selection = "Home"
                                    activationCount += 1
                                    lastActivated = "home"
                                }
                                .accessibilityIdentifier("sidebar-menu-home")
                                SCSidebarMenuAction(
                                    accessibilityLabel: Text("Pin Home"),
                                    action: {
                                        activationCount += 1
                                        lastActivated = "menu-action-home"
                                    }
                                ) {
                                    Image(systemName: "pin")
                                }
                                .accessibilityIdentifier("sidebar-menu-action-home")
                            }
                            SCSidebarMenuButton(
                                "Inbox", systemImage: "tray",
                                isActive: selection == "Inbox",
                                badge: "3"
                            ) {
                                selection = "Inbox"
                                activationCount += 1
                                lastActivated = "inbox"
                            }
                            .accessibilityIdentifier("sidebar-menu-inbox")
                            SCSidebarMenuButton(
                                "Disabled", systemImage: "lock",
                                isDisabled: true
                            ) {
                                activationCount += 1
                                lastActivated = "disabled"
                            }
                            .accessibilityIdentifier("sidebar-menu-disabled")
                            SCSidebarMenuSub {
                                SCSidebarMenuSubItem {
                                    SCSidebarMenuSubButton("Get Started") {
                                        activationCount += 1
                                        lastActivated = "submenu-get-started"
                                    }
                                    .accessibilityIdentifier("sidebar-submenu-item")
                                }
                            }
                        }
                    }
                    SCSidebarGroupAction(
                        accessibilityLabel: Text("Add platform item"),
                        action: {
                            activationCount += 1
                            lastActivated = "group-action"
                        }
                    ) {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("sidebar-group-action")
                }
                SCSidebarInput("Search", text: $search)
                    .accessibilityIdentifier("sidebar-search")
                SCSidebarMenuSkeleton(showsIcon: true)
                    .accessibilityIdentifier("sidebar-menu-skeleton")
            }
            SCSidebarSeparator()
            SCSidebarFooter {
                Text("Alex Chen").font(.caption)
                    .accessibilityIdentifier("sidebar-footer-label")
            }
        } detail: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    SCSidebarTrigger()
                        .accessibilityIdentifier("sidebar-trigger")
                    Text(selection).font(.subheadline)
                }
                Text("Detail pane").font(.caption).foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 700, height: 300)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sidebar-layout")
    }

    @ViewBuilder
    private var persistedPart: some View {
        // Persistence: an independent layout exercising the real
        // UserDefaults-backed persistenceKey restore path (the main
        // layout uses externally owned state to stay deterministic).
        SCSidebarLayout(
            collapsible: .icon,
            persistenceKey: "sc.validation.sidebar.persisted",
            expandedWidth: 140,
            collapsedWidth: 40,
            onOpenChange: { persistedOpen = $0 }
        ) {
            SCSidebarHeader {
                Text("P").font(.caption2)
            }
        } detail: {
            HStack(spacing: 8) {
                SCSidebarTrigger()
                    .accessibilityIdentifier("sidebar-persisted-trigger")
                Text("Persisted: \(persistedOpen ? "open" : "closed")")
                    .accessibilityIdentifier("sidebar-persisted-echo")
            }
            .padding(8)
        }
        .frame(width: 320, height: 70)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sidebar-persisted-layout")
    }
}
