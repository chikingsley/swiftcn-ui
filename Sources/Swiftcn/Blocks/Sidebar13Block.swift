// ============================================================
// Sidebar13Block.swift — swiftcn-ui
// Depends on: Sidebar, Breadcrumb, Button, Dialog
// ============================================================
import SwiftUI

public struct SCSidebar13NavigationItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let systemImage: String

    public init(id: String, name: String, systemImage: String) {
        self.id = id
        self.name = name
        self.systemImage = systemImage
    }
}

public struct SCSidebar13Data: Sendable {
    public var title: String
    public var description: String
    public var navigation: [SCSidebar13NavigationItem]
    public var defaultSelectionID: String

    public init(
        title: String,
        description: String,
        navigation: [SCSidebar13NavigationItem],
        defaultSelectionID: String
    ) {
        self.title = title
        self.description = description
        self.navigation = navigation
        self.defaultSelectionID = defaultSelectionID
    }

    public static let sidebar13 = SCSidebar13Data(
        title: "Settings",
        description: "Customize your settings here.",
        navigation: [
            SCSidebar13NavigationItem(
                id: "notifications",
                name: "Notifications",
                systemImage: "bell"
            ),
            SCSidebar13NavigationItem(
                id: "navigation",
                name: "Navigation",
                systemImage: "line.3.horizontal"
            ),
            SCSidebar13NavigationItem(id: "home", name: "Home", systemImage: "house"),
            SCSidebar13NavigationItem(
                id: "appearance",
                name: "Appearance",
                systemImage: "paintbrush"
            ),
            SCSidebar13NavigationItem(
                id: "messages-media",
                name: "Messages & media",
                systemImage: "message"
            ),
            SCSidebar13NavigationItem(
                id: "language-region",
                name: "Language & region",
                systemImage: "globe"
            ),
            SCSidebar13NavigationItem(
                id: "accessibility",
                name: "Accessibility",
                systemImage: "keyboard"
            ),
            SCSidebar13NavigationItem(
                id: "mark-as-read",
                name: "Mark as read",
                systemImage: "checkmark"
            ),
            SCSidebar13NavigationItem(
                id: "audio-video",
                name: "Audio & video",
                systemImage: "video"
            ),
            SCSidebar13NavigationItem(
                id: "connected-accounts",
                name: "Connected accounts",
                systemImage: "link"
            ),
            SCSidebar13NavigationItem(
                id: "privacy-visibility",
                name: "Privacy & visibility",
                systemImage: "lock"
            ),
            SCSidebar13NavigationItem(
                id: "advanced",
                name: "Advanced",
                systemImage: "gearshape"
            ),
        ],
        defaultSelectionID: "messages-media"
    )
}

public enum SCSidebar13Action: Hashable, Sendable {
    case setPresented(Bool)
    case selectNavigation(String)
    case openSettingsRoot
}

/// A settings dialog with a real selectable sidebar and caller-owned content.
/// Presentation and selection can be controlled by an application coordinator.
public struct SCSidebar13Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalIsPresented: Bool
    @State private var internalSelection: String

    private let data: SCSidebar13Data
    private let externalIsPresented: Binding<Bool>?
    private let externalSelection: Binding<String>?
    private let triggerLabel: AnyView
    private let onAction: (SCSidebar13Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar13Data = .sidebar13,
        isPresented: Binding<Bool>? = nil,
        defaultPresented: Bool = false,
        selection: Binding<String>? = nil,
        onAction: @escaping (SCSidebar13Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalIsPresented = isPresented
        self.externalSelection = selection
        self.triggerLabel = AnyView(Text("Open Dialog"))
        self.onAction = onAction
        self.detail = detail
        _internalIsPresented = State(
            initialValue: isPresented?.wrappedValue ?? defaultPresented
        )
        _internalSelection = State(
            initialValue: selection?.wrappedValue ?? data.defaultSelectionID
        )
    }

    public init<TriggerLabel: View>(
        data: SCSidebar13Data = .sidebar13,
        isPresented: Binding<Bool>? = nil,
        defaultPresented: Bool = false,
        selection: Binding<String>? = nil,
        onAction: @escaping (SCSidebar13Action) -> Void,
        @ViewBuilder triggerLabel: () -> TriggerLabel,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalIsPresented = isPresented
        self.externalSelection = selection
        self.triggerLabel = AnyView(triggerLabel())
        self.onAction = onAction
        self.detail = detail
        _internalIsPresented = State(
            initialValue: isPresented?.wrappedValue ?? defaultPresented
        )
        _internalSelection = State(
            initialValue: selection?.wrappedValue ?? data.defaultSelectionID
        )
    }

    public var body: some View {
        SCDialog(
            isPresented: presentedBinding,
            onOpenChange: { onAction(.setPresented($0)) },
            trigger: {
                SCDialogTrigger { triggerLabel }
                    .buttonStyle(.sc(.default, size: .sm))
            },
            content: {
                SCDialogContent(
                    size: .large,
                    maxWidth: 800,
                    maxHeight: 500,
                    contentPadding: 0
                ) {
                    ViewThatFits(in: .horizontal) {
                        regularDialogContent
                            .frame(minWidth: 700)
                        compactDialogContent
                            .frame(minWidth: 300)
                    }
                    .accessibilityLabel("\(data.title). \(data.description)")
                }
            }
        )
    }

    private var isPresentedValue: Bool {
        externalIsPresented?.wrappedValue ?? internalIsPresented
    }

    private var presentedBinding: Binding<Bool> {
        Binding(
            get: { isPresentedValue },
            set: { value in
                if let externalIsPresented {
                    externalIsPresented.wrappedValue = value
                } else {
                    internalIsPresented = value
                }
            }
        )
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var regularDialogContent: some View {
        HStack(spacing: 0) {
            navigationPane
                .frame(width: 250)
            Rectangle()
                .fill(theme.sidebarBorder)
                .frame(width: 1)
                .accessibilityHidden(true)
            detailPane(showsSettingsRoot: true)
        }
        .frame(height: 480)
    }

    private var compactDialogContent: some View {
        detailPane(showsSettingsRoot: false)
            .frame(height: 480)
    }

    private var navigationPane: some View {
        SCSidebarContent {
            SCSidebarGroup {
                SCSidebarGroupContent {
                    SCSidebarMenu {
                        ForEach(data.navigation) { item in
                            SCSidebarMenuItem {
                                SCSidebarMenuButton(
                                    item.name,
                                    systemImage: item.systemImage,
                                    isActive: selectedID == item.id,
                                    action: { select(item.id) }
                                )
                            }
                        }
                    }
                }
            }
        }
        .background(theme.sidebar)
    }

    private func detailPane(showsSettingsRoot: Bool) -> some View {
        VStack(spacing: 0) {
            dialogHeader(showsSettingsRoot: showsSettingsRoot)
            ScrollView {
                detail(selectedID)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(16)
                    .padding(.top, -16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }

    private func dialogHeader(showsSettingsRoot: Bool) -> some View {
        HStack(spacing: 8) {
            SCBreadcrumb {
                SCBreadcrumbList {
                    if showsSettingsRoot {
                        SCBreadcrumbItem {
                            SCBreadcrumbLink(
                                action: { onAction(.openSettingsRoot) },
                                label: { Text(data.title) }
                            )
                        }
                        SCBreadcrumbSeparator()
                    }
                    SCBreadcrumbItem {
                        SCBreadcrumbPage(selectedItem?.name ?? selectedID)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    private var selectedItem: SCSidebar13NavigationItem? {
        data.navigation.first { $0.id == selectedID }
    }

    private func select(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
        onAction(.selectNavigation(id))
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-13") {
    @Previewable @State var isPresented = true
    @Previewable @State var lastAction = "Select a settings destination."

    SCPreview {
        SCSidebar13Block(
            isPresented: $isPresented,
            onAction: { lastAction = String(describing: $0) },
            detail: { selection in
                VStack(alignment: .leading, spacing: 12) {
                    Text(selection).scH2()
                    Text(lastAction).scMuted()
                    ForEach(0..<6, id: \.self) { index in
                        SCCard {
                            SCCardContent {
                                Text("Setting \(index + 1)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        )
        .frame(width: 1000, height: 700)
    }
}
