// ============================================================
// ButtonGroup.swift — swiftcn-ui
// Depends on: Theme/, Button.swift, Separator.swift
// ============================================================
import SwiftUI

// MARK: - Configuration

public enum SCButtonGroupOrientation: CaseIterable, Sendable {
    case horizontal, vertical
}

/// Compatibility styling for the original array convenience API.
public enum SCButtonGroupVariant: CaseIterable, Sendable {
    case outline, secondary
}

/// Compatibility sizing for the original array convenience API.
public enum SCButtonGroupSize: CaseIterable, Sendable {
    case `default`, sm
}

// MARK: - Root

/// An attached group of arbitrary controls, text, separators, or nested groups.
public struct SCButtonGroup: View {
    @Environment(\.theme) private var theme

    private let orientation: SCButtonGroupOrientation
    private let accessibilityLabel: String?
    private let content: AnyView

    public init<Content: View>(
        orientation: SCButtonGroupOrientation = .horizontal,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.orientation = orientation
        self.accessibilityLabel = accessibilityLabel
        self.content = AnyView(content())
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal:
                HStack(spacing: -1) { content }
            case .vertical:
                SCVerticalButtonGroupLayout(overlap: 1) { content }
            }
        }
        .clipShape(groupShape)
        .environment(
            \.scGroupedControlOrientation,
            orientation == .horizontal ? .horizontal : .vertical
        )
        .accessibilityElement(children: .contain)
        .modifier(SCOptionalAccessibilityLabel(label: accessibilityLabel))
    }

    private var groupShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

private struct SCOptionalAccessibilityLabel: ViewModifier {
    var label: String?

    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(Text(label))
        } else {
            content
        }
    }
}

/// Makes every vertical child use the widest intrinsic child width.
private struct SCVerticalButtonGroupLayout: Layout {
    var overlap: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let intrinsicWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        let width = min(intrinsicWidth, proposal.width ?? intrinsicWidth)
        let sizes = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: width, height: nil))
        }
        let height = max(
            sizes.reduce(CGFloat.zero) { $0 + $1.height }
                - overlap * CGFloat(max(sizes.count - 1, 0)),
            0
        )
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        var y = bounds.minY
        for subview in subviews {
            let size = subview.sizeThatFits(
                ProposedViewSize(width: bounds.width, height: nil)
            )
            subview.place(
                at: CGPoint(x: bounds.minX, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: size.height)
            )
            y += size.height - overlap
        }
    }
}

// MARK: - Text

/// Arbitrary static text or label content attached to a button group.
public struct SCButtonGroupText<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content.scButtonGroupText()
    }
}

extension SCButtonGroupText where Content == Text {
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Reusable ButtonGroupText chrome for a native Label or other caller-owned view.
public struct SCButtonGroupTextModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.scGroupedControlOrientation) private var groupOrientation

    public init() {}

    public func body(content: Content) -> some View {
        HStack(spacing: 6) {
            content
        }
        .font(.subheadline.weight(.medium))
        .lineLimit(1)
        .padding(.horizontal, 12)
        .frame(minHeight: 36)
        .frame(maxWidth: groupOrientation == .vertical ? .infinity : nil, alignment: .leading)
        .background(theme.muted, in: shape)
        .overlay { shape.strokeBorder(theme.border) }
        .foregroundStyle(theme.mutedForeground)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: groupOrientation == nil ? theme.radius : 0,
            style: .continuous
        )
    }
}

extension View {
    /// Styles a caller-owned view as ButtonGroupText.
    public func scButtonGroupText() -> some View {
        modifier(SCButtonGroupTextModifier())
    }
}

// MARK: - Separator

/// A separator sized for an attached group. It is vertical by default.
public struct SCButtonGroupSeparator: View {
    private let orientation: SCButtonGroupOrientation

    public init(orientation: SCButtonGroupOrientation = .vertical) {
        self.orientation = orientation
    }

    public var body: some View {
        switch orientation {
        case .horizontal:
            SCSeparator(.horizontal, isDecorative: true)
                .padding(.horizontal, 1)
        case .vertical:
            SCSeparator(.vertical, isDecorative: true)
                .padding(.vertical, 1)
        }
    }
}

// MARK: - Array convenience

/// One real native button used by the original array convenience API.
public struct SCButtonGroupItem: Identifiable {
    public let id: UUID
    fileprivate let label: String?
    fileprivate let systemImage: String?
    fileprivate let isDisabled: Bool
    fileprivate let action: () -> Void

    public init(
        id: UUID = UUID(),
        label: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.label = label
        systemImage = nil
        self.isDisabled = isDisabled
        self.action = action
    }

    public init(
        id: UUID = UUID(),
        systemImage: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        label = nil
        self.systemImage = systemImage
        self.isDisabled = isDisabled
        self.action = action
    }

    public init(
        id: UUID = UUID(),
        label: String,
        systemImage: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.label = label
        self.systemImage = systemImage
        self.isDisabled = isDisabled
        self.action = action
    }
}

extension SCButtonGroup {
    public init(
        variant: SCButtonGroupVariant = .outline,
        size: SCButtonGroupSize = .default,
        orientation: SCButtonGroupOrientation = .horizontal,
        accessibilityLabel: String? = nil,
        items: [SCButtonGroupItem]
    ) {
        self.init(orientation: orientation, accessibilityLabel: accessibilityLabel) {
            SCButtonGroupItems(items: items, variant: variant, size: size)
        }
    }
}

private struct SCButtonGroupItems: View {
    var items: [SCButtonGroupItem]
    var variant: SCButtonGroupVariant
    var size: SCButtonGroupSize

    var body: some View {
        ForEach(items) { item in
            Button(action: item.action) {
                HStack(spacing: 6) {
                    if let systemImage = item.systemImage {
                        Image(systemName: systemImage)
                    }
                    if let label = item.label {
                        Text(label)
                    }
                }
            }
            .buttonStyle(
                .sc(
                    variant == .outline ? .outline : .secondary,
                    size: size == .sm ? .sm : .default
                )
            )
            .disabled(item.isDisabled)
        }
    }
}

// MARK: - Previews

#Preview("ButtonGroup · composition") {
    @Previewable @State var value = ""
    @Previewable @State var lastAction = "No action yet"

    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            SCButtonGroup(accessibilityLabel: "Editing actions") {
                Button("Copy") { lastAction = "Copied" }.buttonStyle(.sc(.outline))
                Button("Paste") { lastAction = "Pasted" }.buttonStyle(.sc(.outline))
            }
            SCButtonGroup {
                SCButtonGroupText("GPU Size")
                TextField("Value", text: $value)
                    .textFieldStyle(.roundedBorder)
                Button("Apply") { lastAction = value }.buttonStyle(.sc(.outline))
            }
            Text(lastAction).scMuted()
        }
    }
}

#Preview("ButtonGroup · vertical and compatibility") {
    @Previewable @State var count = 0

    SCPreview {
        HStack(spacing: 16) {
            SCButtonGroup(orientation: .vertical, accessibilityLabel: "Counter") {
                Button {
                    count += 1
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.sc(.outline, size: .icon))
                Button {
                    count -= 1
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(.sc(.outline, size: .icon))
            }
            SCButtonGroup(
                size: .sm,
                items: [
                    .init(systemImage: "minus") { count -= 1 },
                    .init(systemImage: "plus") { count += 1 },
                ]
            )
            Text("Count: \(count)").scMuted()
        }
    }
}
