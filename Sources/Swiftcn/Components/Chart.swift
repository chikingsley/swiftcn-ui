// ============================================================
// Chart.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI
import Charts

// MARK: - Theme access

public extension Theme {
    /// The chart series palette as an array, in order (`chart1…chart5`).
    var chartColors: [Color] { [chart1, chart2, chart3, chart4, chart5] }
}

// MARK: - Modifier

/// Applies swiftcn's chart theming to a Swift Charts `Chart`: the theme's
/// series palette, muted axis marks, and hairline grid lines.
///
///     Chart(data) { BarMark(x: .value("Month", $0.month), y: .value("Total", $0.total)) }
///         .scChartStyle()
private struct SCChartStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .chartForegroundStyleScale(range: theme.chartColors)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(theme.border)
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
    }
}

public extension View {
    func scChartStyle() -> some View {
        modifier(SCChartStyle())
    }
}

// MARK: - Previews

#Preview("Chart") {
    struct Point: Identifiable {
        let id = UUID()
        let month: String
        let desktop: Double
        let mobile: Double
    }
    let data: [Point] = [
        .init(month: "Jan", desktop: 186, mobile: 80),
        .init(month: "Feb", desktop: 305, mobile: 200),
        .init(month: "Mar", desktop: 237, mobile: 120),
        .init(month: "Apr", desktop: 73, mobile: 190),
        .init(month: "May", desktop: 209, mobile: 130),
        .init(month: "Jun", desktop: 214, mobile: 140),
    ]

    return SCPreview("Bar chart") {
        Chart(data) { point in
            BarMark(
                x: .value("Month", point.month),
                y: .value("Desktop", point.desktop)
            )
            .foregroundStyle(by: .value("Series", "Desktop"))
            .cornerRadius(3)

            BarMark(
                x: .value("Month", point.month),
                y: .value("Mobile", point.mobile)
            )
            .foregroundStyle(by: .value("Series", "Mobile"))
            .cornerRadius(3)
        }
        .scChartStyle()
        .frame(height: 240)
    }
}
