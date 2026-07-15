// ============================================================
// Chart.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import Charts
import SwiftUI

// MARK: - Configuration

extension Theme {
    /// The chart series palette as an array, in order (`chart1…chart5`).
    public var chartColors: [Color] { [chart1, chart2, chart3, chart4, chart5] }
}

/// Defines one series in a reusable native Swift Charts composition.
public struct SCChartSeriesConfiguration: Identifiable {
    public let key: String
    public let color: Color?
    public let label: AnyView
    public let icon: AnyView?

    public var id: String { key }

    public init<Label: View, Icon: View>(
        key: String,
        color: Color? = nil,
        @ViewBuilder label: () -> Label,
        @ViewBuilder icon: () -> Icon
    ) {
        self.key = key
        self.color = color
        self.label = AnyView(label())
        self.icon = AnyView(icon())
    }

    public init<Label: View>(
        key: String,
        color: Color? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.key = key
        self.color = color
        self.label = AnyView(label())
        self.icon = nil
    }

    public init(
        key: String,
        label: String,
        color: Color? = nil,
        systemImage: String? = nil
    ) {
        self.key = key
        self.color = color
        self.label = AnyView(Text(label))
        self.icon = systemImage.map { AnyView(Image(systemName: $0)) }
    }

    /// Creates the native equivalent of shadcn's light/dark `theme` colors.
    public init(
        key: String,
        label: String,
        lightColor: Color,
        darkColor: Color,
        systemImage: String? = nil
    ) {
        self.init(
            key: key,
            label: label,
            color: .adaptive(light: lightColor, dark: darkColor),
            systemImage: systemImage
        )
    }
}

/// Ordered chart configuration used by the container, tooltip, and legend.
public struct SCChartConfiguration {
    public let series: [SCChartSeriesConfiguration]

    public init(_ series: [SCChartSeriesConfiguration]) {
        var seen: Set<String> = []
        self.series = series.filter { seen.insert($0.key).inserted }
    }

    public subscript(key: String) -> SCChartSeriesConfiguration? {
        series.first { $0.key == key }
    }

    public var keys: [String] { series.map(\.key) }
}

private struct SCChartConfigurationKey: EnvironmentKey {
    static var defaultValue: SCChartConfiguration { SCChartConfiguration([]) }
}

extension EnvironmentValues {
    fileprivate var scChartConfiguration: SCChartConfiguration {
        get { self[SCChartConfigurationKey.self] }
        set { self[SCChartConfigurationKey.self] = newValue }
    }
}

// MARK: - Container and style

/// A responsive Swift Charts container that provides shared series configuration.
public struct SCChartContainer<Content: View>: View {
    private let configuration: SCChartConfiguration
    private let aspectRatio: CGFloat?
    private let accessibilityLabel: String?
    private let content: Content

    public init(
        configuration: SCChartConfiguration,
        aspectRatio: CGFloat? = 1.6,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.aspectRatio = aspectRatio.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        content
            .scChartStyle()
            .aspectRatio(aspectRatio, contentMode: .fit)
            .environment(\.scChartConfiguration, configuration)
            .modifier(SCChartOptionalAccessibilityLabel(label: accessibilityLabel))
    }
}

private struct SCChartOptionalAccessibilityLabel: ViewModifier {
    var label: String?

    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(Text(label))
        } else {
            content
        }
    }
}

/// Applies semantic axes, grid lines, and the configured series palette.
public struct SCChartStyle: ViewModifier {
    @Environment(\.scChartConfiguration) private var configuration
    @Environment(\.theme) private var theme

    public init() {}

    public func body(content: Content) -> some View {
        content
            .chartForegroundStyleScale(range: configuredColors)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(theme.border.opacity(0.6))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
    }

    private var configuredColors: [Color] {
        let colors = configuration.series.compactMap(\.color)
        return colors.isEmpty ? theme.chartColors : colors
    }
}

extension View {
    /// Applies swiftcn's semantic Swift Charts style.
    public func scChartStyle() -> some View {
        modifier(SCChartStyle())
    }
}

// MARK: - Native tooltip integration

/// Positions caller-owned tooltip content over a selected Swift Charts x value.
public struct SCChartTooltip<Selection: Plottable, Tooltip: View>: ViewModifier {
    @Binding private var selection: Selection?
    private let content: (Selection) -> Tooltip

    public init(
        selection: Binding<Selection?>,
        @ViewBuilder content: @escaping (Selection) -> Tooltip
    ) {
        self._selection = selection
        self.content = content
    }

    public func body(content chart: Content) -> some View {
        chart
            .chartXSelection(value: $selection)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let selection {
                        if let plotAnchor = proxy.plotFrame {
                            if let position = proxy.position(forX: selection) {
                                let plotFrame = geometry[plotAnchor]
                                content(selection)
                                    .fixedSize()
                                    .position(
                                        x: min(max(plotFrame.minX + position, plotFrame.minX), plotFrame.maxX),
                                        y: plotFrame.minY
                                    )
                                    .offset(y: -8)
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            }
    }
}

extension View {
    /// Adds real Swift Charts selection and a caller-composed overlay tooltip.
    public func scChartTooltip<Selection: Plottable, Tooltip: View>(
        selection: Binding<Selection?>,
        @ViewBuilder content: @escaping (Selection) -> Tooltip
    ) -> some View {
        modifier(SCChartTooltip(selection: selection, content: content))
    }
}

public enum SCChartTooltipIndicator: CaseIterable, Sendable {
    case dot, line, dashed
}

public enum SCChartPayloadValue: Sendable, Equatable {
    case number(Double)
    case text(String)

    public func formatted(locale: Locale = .current) -> String {
        switch self {
        case .number(let value):
            return value.formatted(.number.locale(locale))
        case .text(let value):
            return value
        }
    }
}

/// One typed row from a chart selection payload.
public struct SCChartTooltipPayload: Identifiable, Sendable {
    public let key: String
    public let configurationKey: String?
    public let fallbackName: String
    public let value: SCChartPayloadValue
    public let color: Color?
    public let isHidden: Bool

    public var id: String { key }

    public init(
        key: String,
        configurationKey: String? = nil,
        fallbackName: String,
        value: SCChartPayloadValue,
        color: Color? = nil,
        isHidden: Bool = false
    ) {
        self.key = key
        self.configurationKey = configurationKey
        self.fallbackName = fallbackName
        self.value = value
        self.color = color
        self.isHidden = isHidden
    }
}

/// The styled, configuration-aware tooltip content used inside `scChartTooltip`.
public struct SCChartTooltipContent: View {
    @Environment(\.locale) private var locale
    @Environment(\.scChartConfiguration) private var configuration
    @Environment(\.theme) private var theme

    private let isActive: Bool
    private let label: AnyView?
    private let payload: [SCChartTooltipPayload]
    private let indicator: SCChartTooltipIndicator
    private let hideLabel: Bool
    private let hideIndicator: Bool
    private let indicatorColor: Color?
    private let formatter: ((SCChartTooltipPayload, Int) -> AnyView)?

    public init<Label: View>(
        isActive: Bool = true,
        payload: [SCChartTooltipPayload],
        indicator: SCChartTooltipIndicator = .dot,
        hideLabel: Bool = false,
        hideIndicator: Bool = false,
        indicatorColor: Color? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.isActive = isActive
        self.label = AnyView(label())
        self.payload = payload
        self.indicator = indicator
        self.hideLabel = hideLabel
        self.hideIndicator = hideIndicator
        self.indicatorColor = indicatorColor
        self.formatter = nil
    }

    public init(
        isActive: Bool = true,
        label: String? = nil,
        payload: [SCChartTooltipPayload],
        indicator: SCChartTooltipIndicator = .dot,
        hideLabel: Bool = false,
        hideIndicator: Bool = false,
        indicatorColor: Color? = nil
    ) {
        self.isActive = isActive
        self.label = label.map { AnyView(Text($0)) }
        self.payload = payload
        self.indicator = indicator
        self.hideLabel = hideLabel
        self.hideIndicator = hideIndicator
        self.indicatorColor = indicatorColor
        self.formatter = nil
    }

    public init<Formatted: View>(
        isActive: Bool = true,
        label: String? = nil,
        payload: [SCChartTooltipPayload],
        indicator: SCChartTooltipIndicator = .dot,
        hideLabel: Bool = false,
        hideIndicator: Bool = false,
        indicatorColor: Color? = nil,
        @ViewBuilder formatter: @escaping (SCChartTooltipPayload, Int) -> Formatted
    ) {
        self.isActive = isActive
        self.label = label.map { AnyView(Text($0)) }
        self.payload = payload
        self.indicator = indicator
        self.hideLabel = hideLabel
        self.hideIndicator = hideIndicator
        self.indicatorColor = indicatorColor
        self.formatter = { item, index in AnyView(formatter(item, index)) }
    }

    public var body: some View {
        if isActive, !visiblePayload.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if !hideLabel, let label {
                    label.font(.caption.weight(.medium))
                }
                ForEach(Array(visiblePayload.enumerated()), id: \.offset) { index, item in
                    if let formatter {
                        formatter(item, index)
                    } else {
                        payloadRow(item, index: index)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minWidth: 128, alignment: .leading)
            .background(theme.popover, in: shape)
            .overlay { shape.strokeBorder(theme.border.opacity(0.6)) }
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .accessibilityElement(children: .combine)
        }
    }

    private var visiblePayload: [SCChartTooltipPayload] {
        payload.filter { !$0.isHidden }
    }

    private func payloadRow(_ item: SCChartTooltipPayload, index: Int) -> some View {
        let itemConfiguration = resolve(item)
        let color =
            indicatorColor
            ?? item.color
            ?? itemConfiguration?.color
            ?? theme.chartColors[index % theme.chartColors.count]
        return HStack(alignment: .center, spacing: 8) {
            if let icon = itemConfiguration?.icon {
                icon
                    .font(.caption2)
                    .foregroundStyle(theme.mutedForeground)
            } else if !hideIndicator {
                indicatorView(color: color)
            }
            VStack(alignment: .leading, spacing: 2) {
                if indicator != .dot, visiblePayload.count == 1, !hideLabel, let label {
                    label.font(.caption.weight(.medium))
                }
                if let configuredLabel = itemConfiguration?.label {
                    configuredLabel
                        .font(.caption)
                        .foregroundStyle(theme.mutedForeground)
                } else {
                    Text(item.fallbackName)
                        .font(.caption)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
            Spacer(minLength: 12)
            Text(item.value.formatted(locale: locale))
                .font(.caption.monospacedDigit().weight(.medium))
                .foregroundStyle(theme.foreground)
        }
    }

    @ViewBuilder
    private func indicatorView(color: Color) -> some View {
        switch indicator {
        case .dot:
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 10)
        case .line:
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 4, height: 14)
        case .dashed:
            RoundedRectangle(cornerRadius: 2)
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                .frame(width: 4, height: 14)
        }
    }

    private func resolve(_ payload: SCChartTooltipPayload) -> SCChartSeriesConfiguration? {
        configuration[payload.configurationKey ?? payload.key] ?? configuration[payload.key]
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Legend

public enum SCChartLegendAlignment: CaseIterable, Sendable {
    case top, bottom
}

/// A configuration-aware legend matching the official ChartLegendContent role.
public struct SCChartLegendContent: View {
    @Environment(\.scChartConfiguration) private var configuration
    @Environment(\.theme) private var theme

    private let keys: [String]?
    private let hideIcon: Bool
    private let alignment: SCChartLegendAlignment

    public init(
        keys: [String]? = nil,
        hideIcon: Bool = false,
        alignment: SCChartLegendAlignment = .bottom
    ) {
        self.keys = keys
        self.hideIcon = hideIcon
        self.alignment = alignment
    }

    public var body: some View {
        HStack(spacing: 16) {
            ForEach(Array(entries.enumerated()), id: \.element.key) { index, entry in
                HStack(spacing: 6) {
                    if let icon = entry.icon, !hideIcon {
                        icon
                            .font(.caption)
                            .foregroundStyle(theme.mutedForeground)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(entry.color ?? theme.chartColors[index % theme.chartColors.count])
                            .frame(width: 8, height: 8)
                    }
                    entry.label.font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(alignment == .top ? .bottom : .top, 12)
        .accessibilityElement(children: .combine)
    }

    private var entries: [SCChartSeriesConfiguration] {
        guard let keys else { return configuration.series }
        return keys.compactMap { configuration[$0] }
    }
}

// MARK: - Previews

private struct SCChartPreviewPoint: Identifiable {
    let id = UUID()
    let month: String
    let desktop: Double
    let mobile: Double
}

#Preview("Chart · container, tooltip, legend") {
    @Previewable @State var selection: String?
    let data = [
        SCChartPreviewPoint(month: "Jan", desktop: 186, mobile: 80),
        SCChartPreviewPoint(month: "Feb", desktop: 305, mobile: 200),
        SCChartPreviewPoint(month: "Mar", desktop: 237, mobile: 120),
    ]
    let configuration = SCChartConfiguration([
        .init(key: "desktop", label: "Desktop", color: Theme.default.chart1),
        .init(key: "mobile", label: "Mobile", color: Theme.default.chart2),
    ])

    SCPreview {
        VStack(spacing: 0) {
            SCChartContainer(
                configuration: configuration,
                aspectRatio: nil,
                accessibilityLabel: "Device usage"
            ) {
                Chart(data) { point in
                    BarMark(
                        x: .value("Month", point.month),
                        y: .value("Desktop", point.desktop)
                    )
                    .foregroundStyle(by: .value("Series", "Desktop"))
                    BarMark(
                        x: .value("Month", point.month),
                        y: .value("Mobile", point.mobile)
                    )
                    .foregroundStyle(by: .value("Series", "Mobile"))
                }
                .scChartTooltip(selection: $selection) { month in
                    let point = data.first { $0.month == month }
                    SCChartTooltipContent(
                        label: month,
                        payload: [
                            .init(
                                key: "desktop",
                                fallbackName: "Desktop",
                                value: .number(point?.desktop ?? 0)
                            ),
                            .init(
                                key: "mobile",
                                fallbackName: "Mobile",
                                value: .number(point?.mobile ?? 0)
                            ),
                        ]
                    )
                }
                .frame(height: 240)
            }
            SCChartLegendContent()
                .environment(\.scChartConfiguration, configuration)
        }
    }
}
