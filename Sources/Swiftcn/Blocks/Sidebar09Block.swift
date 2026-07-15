// ============================================================
// Sidebar09Block.swift — swiftcn-ui
// Depends on: SidebarBlock (models, user menu, shared sidebar engine)
// ============================================================
import SwiftUI

public struct SCSidebar09Mail: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let email: String
    public let subject: String
    public let date: String
    public let teaser: String
    public let isUnread: Bool

    public init(
        id: String,
        name: String,
        email: String,
        subject: String,
        date: String,
        teaser: String,
        isUnread: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.subject = subject
        self.date = date
        self.teaser = teaser
        self.isUnread = isUnread
    }
}

public struct SCSidebar09Folder: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let mailIDs: [String]

    public init(
        id: String,
        title: String,
        systemImage: String,
        mailIDs: [String]
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.mailIDs = mailIDs
    }
}

public struct SCSidebar09Data: Sendable {
    public var organization: SCSidebarTeam
    public var user: SCSidebarUser
    public var folders: [SCSidebar09Folder]
    public var mails: [SCSidebar09Mail]
    public var defaultFolderID: String

    public init(
        organization: SCSidebarTeam,
        user: SCSidebarUser,
        folders: [SCSidebar09Folder],
        mails: [SCSidebar09Mail],
        defaultFolderID: String
    ) {
        self.organization = organization
        self.user = user
        self.folders = folders
        self.mails = mails
        self.defaultFolderID = defaultFolderID
    }

    public static var sidebar09: SCSidebar09Data {
        let mails = sampleMails
        let allMailIDs = mails.map(\.id)
        return SCSidebar09Data(
            organization: SCSidebarTeam(
                id: "acme-inc",
                name: "Acme Inc",
                plan: "Enterprise",
                systemImage: "command"
            ),
            user: SCSidebarBlockData.sidebar07.user,
            folders: [
                SCSidebar09Folder(
                    id: "inbox",
                    title: "Inbox",
                    systemImage: "tray",
                    mailIDs: allMailIDs
                ),
                SCSidebar09Folder(
                    id: "drafts",
                    title: "Drafts",
                    systemImage: "doc",
                    mailIDs: ["weekend-plans", "vacation-plans", "team-dinner"]
                ),
                SCSidebar09Folder(
                    id: "sent",
                    title: "Sent",
                    systemImage: "paperplane",
                    mailIDs: [
                        "project-update",
                        "budget-question",
                        "proposal-feedback",
                        "conference-registration",
                    ]
                ),
                SCSidebar09Folder(
                    id: "junk",
                    title: "Junk",
                    systemImage: "archivebox",
                    mailIDs: ["new-project-idea"]
                ),
                SCSidebar09Folder(
                    id: "trash",
                    title: "Trash",
                    systemImage: "trash",
                    mailIDs: ["important-announcement"]
                ),
            ],
            mails: mails,
            defaultFolderID: "inbox"
        )
    }

    private static let sampleMails: [SCSidebar09Mail] = [
        SCSidebar09Mail(
            id: "meeting-tomorrow",
            name: "William Smith",
            email: "williamsmith@example.com",
            subject: "Meeting Tomorrow",
            date: "09:34 AM",
            teaser: """
                Hi team, just a reminder about our meeting tomorrow at 10 AM.
                Please come prepared with your project updates.
                """,
            isUnread: true
        ),
        SCSidebar09Mail(
            id: "project-update",
            name: "Alice Smith",
            email: "alicesmith@example.com",
            subject: "Re: Project Update",
            date: "Yesterday",
            teaser: """
                Thanks for the update. The progress looks great so far.
                Let's schedule a call to discuss the next steps.
                """,
            isUnread: true
        ),
        SCSidebar09Mail(
            id: "weekend-plans",
            name: "Bob Johnson",
            email: "bobjohnson@example.com",
            subject: "Weekend Plans",
            date: "2 days ago",
            teaser: """
                Hey everyone! I'm thinking of organizing a team outing this weekend.
                Would you be interested in a hiking trip or a beach day?
                """,
            isUnread: true
        ),
        SCSidebar09Mail(
            id: "budget-question",
            name: "Emily Davis",
            email: "emilydavis@example.com",
            subject: "Re: Question about Budget",
            date: "2 days ago",
            teaser: """
                I've reviewed the budget numbers you sent over.
                Can we set up a quick call to discuss some potential adjustments?
                """,
            isUnread: true
        ),
        SCSidebar09Mail(
            id: "important-announcement",
            name: "Michael Wilson",
            email: "michaelwilson@example.com",
            subject: "Important Announcement",
            date: "1 week ago",
            teaser: """
                Please join us for an all-hands meeting this Friday at 3 PM.
                We have some exciting news to share about the company's future.
                """
        ),
        SCSidebar09Mail(
            id: "proposal-feedback",
            name: "Sarah Brown",
            email: "sarahbrown@example.com",
            subject: "Re: Feedback on Proposal",
            date: "1 week ago",
            teaser: """
                Thank you for sending over the proposal. I've reviewed it and have some thoughts.
                Could we schedule a meeting to discuss my feedback in detail?
                """
        ),
        SCSidebar09Mail(
            id: "new-project-idea",
            name: "David Lee",
            email: "davidlee@example.com",
            subject: "New Project Idea",
            date: "1 week ago",
            teaser: """
                I've been brainstorming and came up with an interesting project concept.
                Do you have time this week to discuss its potential impact and feasibility?
                """
        ),
        SCSidebar09Mail(
            id: "vacation-plans",
            name: "Olivia Wilson",
            email: "oliviawilson@example.com",
            subject: "Vacation Plans",
            date: "1 week ago",
            teaser: """
                Just a heads up that I'll be taking a two-week vacation next month.
                I'll make sure all my projects are up to date before I leave.
                """
        ),
        SCSidebar09Mail(
            id: "conference-registration",
            name: "James Martin",
            email: "jamesmartin@example.com",
            subject: "Re: Conference Registration",
            date: "1 week ago",
            teaser: """
                I've completed the registration for the upcoming tech conference.
                Let me know if you need any additional information from my end.
                """
        ),
        SCSidebar09Mail(
            id: "team-dinner",
            name: "Sophia White",
            email: "sophiawhite@example.com",
            subject: "Team Dinner",
            date: "1 week ago",
            teaser: """
                To celebrate our recent project success, I'd like to organize a team dinner.
                Are you available next Friday evening? Please let me know your preferences.
                """
        ),
    ]
}

public enum SCSidebar09Action: Hashable, Sendable {
    case openOrganization
    case openAllInboxes
    case selectFolder(String)
    case setUnreadsOnly(Bool)
    case search(String)
    case selectMail(String)
    case user(SCSidebarUserAction)
}

/// A functional two-pane mail sidebar. Folder, unread, search, and mail state
/// may be caller-controlled; the application supplies the real detail surface.
public struct SCSidebar09Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalFolderID: String
    @State private var internalSearch = ""
    @State private var internalUnreadsOnly = false
    @State private var internalSelectedMailID: String?
    @State private var sidebarState: SCSidebarState

    private let data: SCSidebar09Data
    private let externalFolderID: Binding<String>?
    private let externalSearch: Binding<String>?
    private let externalUnreadsOnly: Binding<Bool>?
    private let externalSelectedMailID: Binding<String?>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar09Action) -> Void
    private let detail: (String, String?) -> Detail

    public init(
        data: SCSidebar09Data = .sidebar09,
        folderID: Binding<String>? = nil,
        search: Binding<String>? = nil,
        unreadsOnly: Binding<Bool>? = nil,
        selectedMailID: Binding<String?>? = nil,
        persistenceKey: String? = "sc.sidebar09.open",
        onAction: @escaping (SCSidebar09Action) -> Void,
        @ViewBuilder detail: @escaping (_ folderID: String, _ selectedMailID: String?) -> Detail
    ) {
        self.data = data
        self.externalFolderID = folderID
        self.externalSearch = search
        self.externalUnreadsOnly = unreadsOnly
        self.externalSelectedMailID = selectedMailID
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail

        let initialFolder = folderID?.wrappedValue ?? Self.initialFolderID(in: data)
        let initialOpen =
            persistenceKey.flatMap {
                UserDefaults.standard.object(forKey: $0) as? Bool
            } ?? true
        _internalFolderID = State(initialValue: initialFolder)
        _internalSearch = State(initialValue: search?.wrappedValue ?? "")
        _internalUnreadsOnly = State(initialValue: unreadsOnly?.wrappedValue ?? false)
        _internalSelectedMailID = State(initialValue: selectedMailID?.wrappedValue)
        _sidebarState = State(
            initialValue: SCSidebarState(isOpen: initialOpen, collapsible: .icon)
        )
    }

    public init(
        data: SCSidebar09Data = .sidebar09,
        folderID: Binding<String>? = nil,
        search: Binding<String>? = nil,
        unreadsOnly: Binding<Bool>? = nil,
        selectedMailID: Binding<String?>? = nil,
        persistenceKey: String? = "sc.sidebar09.open",
        onAction: @escaping (SCSidebar09Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            folderID: folderID,
            search: search,
            unreadsOnly: unreadsOnly,
            selectedMailID: selectedMailID,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _, _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: .icon,
            persistenceKey: persistenceKey,
            expandedWidth: 350,
            collapsedWidth: 56,
            state: sidebarState
        ) {
            SCSidebar09NestedSidebar(
                data: data,
                activeFolderID: folderIDValue,
                search: searchBinding,
                unreadsOnly: unreadsOnlyBinding,
                selectedMailID: selectedMailIDValue,
                mails: filteredMails,
                onOpenOrganization: { onAction(.openOrganization) },
                onSelectFolder: selectFolder,
                onSelectMail: selectMail,
                onUserAction: { onAction(.user($0)) }
            )
        } detail: {
            VStack(spacing: 0) {
                topBar
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                    .accessibilityHidden(true)
                detail(folderIDValue, selectedMailIDValue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
        .onChange(of: searchValue) { _, value in onAction(.search(value)) }
        .onChange(of: unreadsOnlyValue) { _, value in onAction(.setUnreadsOnly(value)) }
    }

    private var folderIDValue: String {
        externalFolderID?.wrappedValue ?? internalFolderID
    }

    private var searchValue: String {
        externalSearch?.wrappedValue ?? internalSearch
    }

    private var unreadsOnlyValue: Bool {
        externalUnreadsOnly?.wrappedValue ?? internalUnreadsOnly
    }

    private var selectedMailIDValue: String? {
        externalSelectedMailID?.wrappedValue ?? internalSelectedMailID
    }

    private var searchBinding: Binding<String> {
        externalSearch ?? $internalSearch
    }

    private var unreadsOnlyBinding: Binding<Bool> {
        externalUnreadsOnly ?? $internalUnreadsOnly
    }

    private var activeFolder: SCSidebar09Folder? {
        data.folders.first { $0.id == folderIDValue }
    }

    private var filteredMails: [SCSidebar09Mail] {
        let allowedIDs = Set(activeFolder?.mailIDs ?? [])
        let query = searchValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return data.mails.filter { mail in
            guard allowedIDs.contains(mail.id) else { return false }
            guard !unreadsOnlyValue || mail.isUnread else { return false }
            guard !query.isEmpty else { return true }
            return mail.name.localizedCaseInsensitiveContains(query)
                || mail.email.localizedCaseInsensitiveContains(query)
                || mail.subject.localizedCaseInsensitiveContains(query)
                || mail.teaser.localizedCaseInsensitiveContains(query)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true).frame(height: 16)
            ViewThatFits(in: .horizontal) {
                SCBreadcrumb {
                    SCBreadcrumbList {
                        SCBreadcrumbItem {
                            SCBreadcrumbLink(
                                action: { onAction(.openAllInboxes) },
                                label: { Text("All Inboxes") }
                            )
                        }
                        SCBreadcrumbSeparator()
                        SCBreadcrumbItem {
                            SCBreadcrumbPage(activeFolder?.title ?? folderIDValue)
                        }
                    }
                }
                SCBreadcrumb {
                    SCBreadcrumbList {
                        SCBreadcrumbItem {
                            SCBreadcrumbPage(activeFolder?.title ?? folderIDValue)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(minHeight: 64)
    }

    private func selectFolder(_ id: String) {
        if let externalFolderID {
            externalFolderID.wrappedValue = id
        } else {
            internalFolderID = id
        }
        setSelectedMail(nil)
        sidebarState.setOpen(true)
        onAction(.selectFolder(id))
    }

    private func selectMail(_ id: String) {
        setSelectedMail(id)
        onAction(.selectMail(id))
    }

    private func setSelectedMail(_ id: String?) {
        if let externalSelectedMailID {
            externalSelectedMailID.wrappedValue = id
        } else {
            internalSelectedMailID = id
        }
    }

    private static func initialFolderID(in data: SCSidebar09Data) -> String {
        if data.folders.contains(where: { $0.id == data.defaultFolderID }) {
            return data.defaultFolderID
        }
        return data.folders.first?.id ?? ""
    }
}

private struct SCSidebar09NestedSidebar: View {
    @Environment(\.scSidebarIconRail) private var iconRail
    @Environment(\.theme) private var theme

    let data: SCSidebar09Data
    let activeFolderID: String
    @Binding var search: String
    @Binding var unreadsOnly: Bool
    let selectedMailID: String?
    let mails: [SCSidebar09Mail]
    let onOpenOrganization: () -> Void
    let onSelectFolder: (String) -> Void
    let onSelectMail: (String) -> Void
    let onUserAction: (SCSidebarUserAction) -> Void

    var body: some View {
        HStack(spacing: 0) {
            folderRail
            if !iconRail {
                mailPane
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var folderRail: some View {
        VStack(spacing: 0) {
            Button(action: onOpenOrganization) {
                RoundedRectangle(
                    cornerRadius: max(theme.radius - 2, 4),
                    style: .continuous
                )
                .fill(theme.sidebarPrimary)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: data.organization.systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.sidebarPrimaryForeground)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 56, height: 56)
            .scTooltip(data.organization.name, edge: .trailing)
            .accessibilityLabel("Open \(data.organization.name)")

            ScrollView {
                SCSidebarMenu {
                    ForEach(data.folders) { folder in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                folder.title,
                                systemImage: folder.systemImage,
                                isActive: folder.id == activeFolderID,
                                action: { onSelectFolder(folder.id) }
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            SCSidebarUserMenu(user: data.user, onAction: onUserAction)
                .padding(6)
        }
        .environment(\.scSidebarIconRail, true)
        .frame(width: 56)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .trailing) {
            Rectangle().fill(theme.sidebarBorder).frame(width: 1)
        }
    }

    private var mailPane: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text(activeFolderTitle)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("Unreads")
                        .font(.subheadline)
                    SCSwitch("Unreads only", isOn: $unreadsOnly, size: .small)
                }
                SCSidebarInput("Type to search...", text: $search)
            }
            .padding(16)

            Rectangle().fill(theme.sidebarBorder).frame(height: 1)

            if mails.isEmpty {
                ContentUnavailableView(
                    "No messages",
                    systemImage: "tray",
                    description: Text("Change the search or unread filter.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(mails) { mail in
                            mailButton(mail)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var activeFolderTitle: String {
        data.folders.first(where: { $0.id == activeFolderID })?.title ?? activeFolderID
    }

    private func mailButton(_ mail: SCSidebar09Mail) -> some View {
        Button {
            onSelectMail(mail.id)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(mail.name)
                        .font(.subheadline.weight(mail.isUnread ? .semibold : .regular))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(mail.date)
                        .font(.caption2)
                        .foregroundStyle(theme.sidebarForeground.opacity(0.65))
                }
                Text(mail.subject)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(mail.teaser)
                    .font(.caption)
                    .foregroundStyle(theme.sidebarForeground.opacity(0.72))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            selectedMailID == mail.id ? theme.sidebarAccent : .clear
        )
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.sidebarBorder).frame(height: 1)
        }
        .accessibilityLabel("\(mail.name), \(mail.subject), \(mail.date)")
        .accessibilityAddTraits(selectedMailID == mail.id ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-09") {
    @Previewable @State var lastAction = "Choose a folder, filter, or message."

    SCPreview {
        SCSidebar09Block(
            onAction: { lastAction = String(describing: $0) },
            detail: { folderID, selectedMailID in
                VStack(alignment: .leading, spacing: 12) {
                    Text(selectedMailID ?? folderID).scH2()
                    Text(lastAction).scMuted()
                    Spacer()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        )
        .frame(width: 1100, height: 720)
    }
}
