import Charts
// ============================================================
// DashboardBlock.swift — swiftcn-ui
// Depends on: Theme/, Components/ (Sidebar, Card, Chart, Item,
//             Avatar, Button, Typography)
//
// Swiftcn-native analytics dashboard — an analytics screen behind
// a collapsible icon-rail sidebar: stat cards,
// a revenue bar chart, and a recent-sales list:
//
//     SCDashboardBlock()
// ============================================================
import SwiftUI

// MARK: - Block

/// A Swiftcn-native analytics block as a ready-made screen: an
/// `SCSidebarLayout(collapsible: .icon)` with a compact navigation
/// sidebar and a scrolling detail pane of stat cards (adaptive grid:
/// four across on regular widths, 2×2 on compact), an "Overview" bar
/// chart card, and a "Recent Sales" card. All data is hardcoded demo
/// data, matching the shadcn block model of blocks as copy-and-edit
/// starting points.
///
/// Sidebar navigation is controlled or internal: pass `selection` to
/// own the selected section, and `onNavigate` fires for every sidebar
/// choice. The detail header follows the selection.
///
///     SCDashboardBlock(onNavigate: { section in route(section) })
public struct SCDashboardBlock: View {
    @Environment(\.theme) private var theme

    @State private var internalSelection: String

    private let externalSelection: Binding<String>?
    private let onNavigate: ((String) -> Void)?
    private let onDownload: (() -> Void)?

    public init(
        selection: Binding<String>? = nil,
        defaultSelection: String = "Dashboard",
        onNavigate: ((String) -> Void)? = nil,
        onDownload: (() -> Void)? = nil
    ) {
        self.externalSelection = selection
        self._internalSelection = State(initialValue: defaultSelection)
        self.onNavigate = onNavigate
        self.onDownload = onDownload
    }

    private var selection: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private func navigate(to label: String) {
        if let externalSelection {
            externalSelection.wrappedValue = label
        } else {
            internalSelection = label
        }
        onNavigate?(label)
    }

    public var body: some View {
        SCSidebarLayout(collapsible: .icon, persistenceKey: nil) {
            SCSidebarHeader {
                DashboardBlockIdentity()
            }
            SCSidebarContent {
                SCSidebarGroup {
                    SCSidebarMenu {
                        row("Dashboard", icon: "square.grid.2x2")
                        row("Analytics", icon: "chart.bar")
                        row("Reports", icon: "doc.text")
                        row("Settings", icon: "gearshape")
                    }
                }
            }
        } detail: {
            detailPane
        }
    }

    private func row(_ label: String, icon: String) -> some View {
        SCSidebarMenuButton(label, systemImage: icon, isActive: selection == label) {
            navigate(to: label)
        }
    }

    // MARK: - Detail

    private var detailPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerRow
                statGrid
                overviewCard
                recentSalesCard
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }

    private var headerRow: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            Text(selection).scH2()
            Spacer()
            if let onDownload {
                Button("Download", action: onDownload)
                    .buttonStyle(.sc(.outline, size: .sm))
            }
        }
    }

    // MARK: - Stat cards

    /// Four across on regular widths, 2×2 on compact — the adaptive
    /// column minimum picks the count from the available width.
    private var statGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150), spacing: 16)],
            spacing: 16
        ) {
            ForEach(DashboardData.stats) { stat in
                DashboardStatCard(stat: stat)
            }
        }
    }

    // MARK: - Overview chart

    private var overviewCard: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Overview")
            }
            SCCardContent {
                Chart(DashboardData.revenue) { point in
                    BarMark(
                        x: .value("Month", point.month),
                        y: .value("Revenue", point.total)
                    )
                    .foregroundStyle(theme.chart1)
                    .cornerRadius(4)
                }
                .scChartStyle()
                .frame(height: 240)
            }
        }
    }

    // MARK: - Recent sales

    private var recentSalesCard: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Recent Sales")
                SCCardDescription("You made 265 sales this month.")
            }
            SCCardContent {
                VStack(spacing: 0) {
                    ForEach(DashboardData.sales) { sale in
                        SCItem(sale.name, description: sale.email) {
                            SCAvatar(url: nil, fallback: sale.initials, size: .sm)
                        } trailing: {
                            Text(sale.amount)
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Subcomponents

/// One stat tile: title and icon on top, big value, muted trend caption.
private struct DashboardStatCard: View {
    @Environment(\.theme) private var theme

    let stat: DashboardData.Stat

    var body: some View {
        SCCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(stat.title)
                        .font(.footnote.weight(.medium))
                    Spacer(minLength: 8)
                    Image(systemName: stat.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.mutedForeground)
                }
                Text(stat.value)
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(stat.trend)
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
            }
        }
    }
}

/// Sidebar header tile — logo square plus app name, collapsing to just
/// the tile on the icon rail.
private struct DashboardBlockIdentity: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                .fill(theme.sidebarPrimary)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.sidebarPrimaryForeground)
                }
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Acme Inc")
                        .font(.subheadline.weight(.semibold))
                    Text("Analytics")
                        .font(.caption2)
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
                .lineLimit(1)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
    }
}

// MARK: - Data

/// Sample data for Swiftcn's compact analytics block.
private enum DashboardData {
    struct Stat: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let trend: String
        let icon: String
    }

    struct RevenuePoint: Identifiable {
        let id = UUID()
        let month: String
        let total: Double
    }

    struct Sale: Identifiable {
        let id = UUID()
        let name: String
        let email: String
        let amount: String

        var initials: String {
            name.split(separator: " ").compactMap(\.first).prefix(2).map(String.init).joined()
        }
    }

    static let stats: [Stat] = [
        .init(
            title: "Total Revenue",
            value: "$45,231.89",
            trend: "+20.1% from last month",
            icon: "dollarsign"
        ),
        .init(
            title: "Subscriptions",
            value: "+2,350",
            trend: "+180.1% from last month",
            icon: "person.2"
        ),
        .init(
            title: "Sales",
            value: "+12,234",
            trend: "+19% from last month",
            icon: "creditcard"
        ),
        .init(
            title: "Active Now",
            value: "+573",
            trend: "+201 since last hour",
            icon: "chart.line.uptrend.xyaxis"
        ),
    ]

    static let revenue: [RevenuePoint] = [
        .init(month: "Jan", total: 4200), .init(month: "Feb", total: 3100),
        .init(month: "Mar", total: 5300), .init(month: "Apr", total: 4700),
        .init(month: "May", total: 3900), .init(month: "Jun", total: 5800),
        .init(month: "Jul", total: 4400), .init(month: "Aug", total: 5100),
        .init(month: "Sep", total: 6200), .init(month: "Oct", total: 5600),
        .init(month: "Nov", total: 4900), .init(month: "Dec", total: 6800),
    ]

    static let sales: [Sale] = [
        .init(name: "Olivia Martin", email: "olivia.martin@email.com", amount: "+$1,999.00"),
        .init(name: "Jackson Lee", email: "jackson.lee@email.com", amount: "+$39.00"),
        .init(name: "Isabella Nguyen", email: "isabella.nguyen@email.com", amount: "+$299.00"),
        .init(name: "William Kim", email: "will@email.com", amount: "+$99.00"),
        .init(name: "Sofia Davis", email: "sofia.davis@email.com", amount: "+$39.00"),
    ]
}

// MARK: - Previews

#Preview("DashboardBlock · analytics") {
    @Previewable @State var lastAction = "Use the dashboard actions."

    SCPreview {
        VStack(spacing: 8) {
            SCDashboardBlock(
                onNavigate: { lastAction = "Navigate: \($0)" },
                onDownload: { lastAction = "Download requested" }
            )
            .frame(width: 1000, height: 700)
            Text(lastAction).scMuted()
        }
    }
}

#Preview("DashboardBlock · controlled selection") {
    @Previewable @State var selection = "Analytics"

    SCPreview {
        VStack(spacing: 8) {
            SCDashboardBlock(selection: $selection)
                .frame(width: 1000, height: 640)
            Text("Selected: \(selection)").scMuted()
        }
    }
}
