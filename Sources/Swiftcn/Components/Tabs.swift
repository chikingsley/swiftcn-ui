// ============================================================
// Tabs.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCTabsVariant: CaseIterable, Sendable {
    /// shadcn's default look: a muted strip in which a raised pill slides
    /// under the selected tab.
    case segmented
    /// Transparent strip with a full-width hairline; a 2pt primary underline
    /// bar slides under the selected tab.
    case underline
}

// MARK: - Item

/// One entry in an `SCTabs` strip: a selection value plus its label and an
/// optional SF Symbol.
public struct SCTabItem<Value: Hashable>: Identifiable {
    public var value: Value
    public var label: String
    public var systemImage: String?

    public var id: Value { value }

    public init(value: Value, label: String, systemImage: String? = nil) {
        self.value = value
        self.label = label
        self.systemImage = systemImage
    }
}

// MARK: - Component

/// A set of layered sections of content — the swiftcn Tabs. The strip is
/// data-driven from `[SCTabItem]`; the panel below renders whatever the
/// `content` builder returns for the current selection. No `AnyView`.
///
///     enum Section { case account, password }
///
///     SCTabs(selection: $tab, tabs: [
///         SCTabItem(value: Section.account, label: "Account"),
///         SCTabItem(value: Section.password, label: "Password"),
///     ]) { tab in
///         switch tab {
///         case .account:  AccountView()
///         case .password: PasswordView()
///         }
///     }
public struct SCTabs<Value: Hashable, Content: View>: View {
    @Environment(\.theme) private var theme
    @Namespace private var namespace

    @Binding var selection: Value
    var variant: SCTabsVariant
    var tabs: [SCTabItem<Value>]
    @ViewBuilder var content: (Value) -> Content

    /// - Parameters:
    ///   - selection: The currently selected tab value.
    ///   - variant: Strip appearance; defaults to `.segmented`.
    ///   - tabs: The tab strip entries, in display order.
    ///   - content: Builds the panel for the selected value.
    public init(
        selection: Binding<Value>,
        variant: SCTabsVariant = .segmented,
        tabs: [SCTabItem<Value>],
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self._selection = selection
        self.variant = variant
        self.tabs = tabs
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            strip
            content(selection)
                .foregroundStyle(theme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Strip

    @ViewBuilder private var strip: some View {
        switch variant {
        case .segmented:
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    cell(for: tab)
                }
            }
            .padding(4)
            .background(theme.muted, in: RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
            .animation(.snappy(duration: 0.25), value: selection)
        case .underline:
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    cell(for: tab)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottom) {
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
            }
            .animation(.snappy(duration: 0.25), value: selection)
        }
    }

    private func cell(for tab: SCTabItem<Value>) -> some View {
        let isSelected = tab.value == selection
        return Button {
            selection = tab.value
        } label: {
            label(for: tab)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(isSelected ? theme.foreground : theme.mutedForeground)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: variant == .segmented ? .infinity : nil)
                .background {
                    if variant == .segmented, isSelected {
                        pill
                    }
                }
                .overlay(alignment: .bottom) {
                    if variant == .underline, isSelected {
                        underlineBar
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private func label(for tab: SCTabItem<Value>) -> some View {
        if let systemImage = tab.systemImage {
            Label(tab.label, systemImage: systemImage)
        } else {
            Text(tab.label)
        }
    }

    private var pill: some View {
        RoundedRectangle(cornerRadius: max(theme.radius - 4, 2), style: .continuous)
            .fill(theme.background)
            .shadow(color: theme.foreground.opacity(0.08), radius: 2, y: 1)
            .matchedGeometryEffect(id: "tab", in: namespace)
    }

    private var underlineBar: some View {
        Rectangle()
            .fill(theme.primary)
            .frame(height: 2)
            .matchedGeometryEffect(id: "tab", in: namespace)
    }
}

// MARK: - Previews

private enum PreviewTab: String, CaseIterable {
    case account, password, settings

    var item: SCTabItem<PreviewTab> {
        SCTabItem(value: self, label: rawValue.capitalized)
    }
}

#Preview("Tabs · segmented") {
    @Previewable @State var tab: PreviewTab = .account
    SCPreview {
        SCTabs(selection: $tab, tabs: PreviewTab.allCases.map(\.item)) { tab in
            switch tab {
            case .account:
                Text("Make changes to your account here.")
            case .password:
                Text("Change your password here.")
            case .settings:
                Text("Edit your notification settings.")
            }
        }
        .font(.subheadline)
    }
}

#Preview("Tabs · underline") {
    @Previewable @State var tab: PreviewTab = .account
    SCPreview {
        SCTabs(selection: $tab, variant: .underline, tabs: PreviewTab.allCases.map(\.item)) { tab in
            switch tab {
            case .account:
                Text("Make changes to your account here.")
            case .password:
                Text("Change your password here.")
            case .settings:
                Text("Edit your notification settings.")
            }
        }
        .font(.subheadline)
    }
}

#Preview("Tabs · icons") {
    @Previewable @State var tab = "music"
    SCPreview {
        SCTabs(
            selection: $tab,
            tabs: [
                SCTabItem(value: "music", label: "Music", systemImage: "music.note"),
                SCTabItem(value: "podcasts", label: "Podcasts", systemImage: "mic"),
            ]
        ) { tab in
            switch tab {
            case "podcasts":
                Text("Your podcasts live here.")
            default:
                Text("Your music lives here.")
            }
        }
        .font(.subheadline)
    }
}
