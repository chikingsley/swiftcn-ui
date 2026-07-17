import Charts
import SwiftUI
import Swiftcn

/// A bar chart and a line chart, both wrapped in `SCChartContainer` with a
/// real series configuration, a caller-owned `chartXSelection` binding
/// driving `SCChartTooltipContent` (one default-rendered with a hidden
/// payload row, one with a custom formatter), and `SCChartLegendContent`
/// nested inside each container's own content — the only place the legend
/// can see the container's configuration, since `scChartConfiguration` is a
/// `fileprivate` environment key private to Chart.swift. Selection is driven
/// by real buttons rather than a synthesized chart gesture, because the
/// gesture recognition Swift Charts installs for `chartXSelection` is
/// framework-owned and this scene must stay deterministic.
struct ChartValidationScene: View {
    @State private var selection: String?
    @State private var lineSelection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Bar selection: \(selection ?? "none")")
                .accessibilityIdentifier("chart-selection-echo")
            Text("Line selection: \(lineSelection ?? "none")")
                .accessibilityIdentifier("chart-line-selection-echo")

            HStack(spacing: 8) {
                Button("Select Feb") { selection = "Feb" }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("chart-select-feb-button")
                Button("Clear selection") { selection = nil }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("chart-clear-button")
                Button("Select Feb (line)") { lineSelection = "Feb" }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("chart-line-select-feb-button")
                Button("Clear line selection") { lineSelection = nil }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("chart-line-clear-button")
            }

            SCChartContainer(
                configuration: Self.barConfiguration,
                aspectRatio: nil,
                accessibilityLabel: "Device usage by month"
            ) {
                VStack(spacing: 8) {
                    Chart(Self.points) { point in
                        BarMark(x: .value("Month", point.month), y: .value("Desktop", point.desktop))
                            .foregroundStyle(by: .value("Series", "desktop"))
                        BarMark(x: .value("Month", point.month), y: .value("Mobile", point.mobile))
                            .foregroundStyle(by: .value("Series", "mobile"))
                    }
                    .scChartTooltip(selection: $selection) { month in
                        barTooltip(for: month)
                    }
                    .frame(height: 200)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("chart-bar-plot")

                    SCChartLegendContent()
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("chart-bar")

            SCChartContainer(
                configuration: Self.lineConfiguration,
                aspectRatio: 2.2,
                accessibilityLabel: "Desktop trend"
            ) {
                VStack(spacing: 8) {
                    Chart(Self.points) { point in
                        LineMark(x: .value("Month", point.month), y: .value("Desktop", point.desktop))
                            .foregroundStyle(by: .value("Series", "desktop"))
                    }
                    .scChartTooltip(selection: $lineSelection) { month in
                        lineTooltip(for: month)
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("chart-line-plot")

                    SCChartLegendContent(hideIcon: true, alignment: .top)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("chart-line")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func barTooltip(for month: String) -> some View {
        let point = Self.points.first { $0.month == month }
        SCChartTooltipContent(
            label: month,
            payload: [
                .init(key: "desktop", fallbackName: "Desktop", value: .number(point?.desktop ?? 0)),
                .init(key: "mobile", fallbackName: "Mobile", value: .number(point?.mobile ?? 0)),
                .init(key: "hidden", fallbackName: "Hidden", value: .number(0), isHidden: true),
            ]
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("chart-bar-tooltip")
    }

    @ViewBuilder
    private func lineTooltip(for month: String) -> some View {
        let point = Self.points.first { $0.month == month }
        SCChartTooltipContent(
            label: month,
            payload: [.init(key: "desktop", fallbackName: "Desktop", value: .number(point?.desktop ?? 0))],
            indicator: .dashed
        ) { item, _ in
            Text("\(item.fallbackName) total: \(item.value.formatted())")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("chart-line-tooltip")
    }

    private struct Point: Identifiable {
        let id = UUID()
        let month: String
        let desktop: Double
        let mobile: Double
    }

    private static let points: [Point] = [
        Point(month: "Jan", desktop: 186, mobile: 80),
        Point(month: "Feb", desktop: 305, mobile: 200),
        Point(month: "Mar", desktop: 237, mobile: 120),
    ]

    private static let barConfiguration = SCChartConfiguration([
        .init(key: "desktop", label: "Desktop", color: Theme.default.chart1),
        .init(key: "mobile", label: "Mobile", color: Theme.default.chart2),
    ])

    private static let lineConfiguration = SCChartConfiguration([
        .init(key: "desktop", label: "Desktop", color: Theme.default.chart1)
    ])
}
