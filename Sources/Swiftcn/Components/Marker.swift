// ============================================================
// Marker.swift — swiftcn-ui
// Depends on: Theme/
//
// SwiftUI port of shadcn/ui's Marker (June 2026 chat release):
// status updates, system notes, bordered rows, and labeled
// separators inside a conversation. Upstream parts: Marker ·
// MarkerIcon · MarkerContent. Pair the content with
// `.scShimmer()` for live status, exactly like upstream pairs
// `MarkerContent` with the `shimmer` utility.
//
//     SCMarker {
//         SCMarkerIcon { SCSpinner(size: 16) }
//         SCMarkerContent("Thinking…")
//     }
// ============================================================
import Accessibility
import SwiftUI

// MARK: - Variants

/// The layout style of a marker — shadcn's `variant` prop.
nonisolated public enum SCMarkerVariant: Hashable, Sendable {
    /// An inline marker for status and notes.
    case `default`
    /// An inline marker with a bottom border for row separation.
    case border
    /// A centered label between decorative divider lines.
    case separator
}

public enum SCMarkerAlignment: CaseIterable, Equatable, Hashable, Sendable {
    case leading
    case center
    case trailing
}

public enum SCMarkerRole: CaseIterable, Equatable, Hashable, Sendable {
    case note
    case status
}

// MARK: - Marker

/// A conversation marker — shadcn's `Marker`. Renders status updates,
/// system notes, bordered rows, and labeled separators. Upstream's `render`
/// prop (link/button markers) maps to the native `SCMarkerButton`,
/// `SCMarkerLink`, and `SCMarkerNavigationLink` roots.
///
///     SCMarker { SCMarkerContent("Explored 4 files") }
///     SCMarker(variant: .separator) { SCMarkerContent("Today") }
public struct SCMarker<Content: View>: View {
    @Environment(\.theme) private var theme

    private let variant: SCMarkerVariant
    private let axis: Axis
    private let alignment: SCMarkerAlignment
    private let spacing: CGFloat
    private let role: SCMarkerRole
    private let statusAnnouncement: String?
    private let content: Content

    /// Creates a marker.
    /// - Parameters:
    ///   - variant: `.default`, `.border`, or `.separator`.
    ///   - content: An optional `SCMarkerIcon` followed by `SCMarkerContent`.
    public init(
        variant: SCMarkerVariant = .default,
        axis: Axis = .horizontal,
        alignment: SCMarkerAlignment = .leading,
        spacing: CGFloat = 8,
        role: SCMarkerRole = .note,
        statusAnnouncement: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.role = role
        self.statusAnnouncement = statusAnnouncement
        self.content = content()
    }

    public var body: some View {
        row
            .font(.subheadline)
            .foregroundStyle(theme.mutedForeground)
            .frame(minHeight: 16)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .accessibilityElement(children: .contain)
            .modifier(SCMarkerAccessibilityLabel(label: statusAnnouncement))
            .onAppear { announceStatus(statusAnnouncement) }
            .onChange(of: statusAnnouncement) { _, announcement in
                announceStatus(announcement)
            }
    }

    @ViewBuilder private var row: some View {
        switch variant {
        case .default:
            arrangedContent
        case .border:
            VStack(spacing: 0) {
                arrangedContent
                    .frame(maxWidth: .infinity, alignment: frameAlignment)
                    .padding(.bottom, 8)
                theme.border
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
        case .separator:
            HStack(spacing: spacing) {
                hairline
                content
                hairline
            }
        }
    }

    @ViewBuilder private var arrangedContent: some View {
        switch axis {
        case .horizontal:
            HStack(spacing: spacing) { content }
        case .vertical:
            VStack(alignment: stackAlignment, spacing: spacing) { content }
        }
    }

    private var stackAlignment: HorizontalAlignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    private var frameAlignment: Alignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    private func announceStatus(_ announcement: String?) {
        guard role == .status, let announcement, !announcement.isEmpty else { return }
        AccessibilityNotification.Announcement(announcement).post()
    }

    private var hairline: some View {
        theme.border
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
    }
}

private struct SCMarkerAccessibilityLabel: ViewModifier {
    let label: String?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(Text(label))
        } else {
            content
        }
    }
}

// MARK: - Native interactive roots

/// A real native Button marker using the same root and public parts.
public struct SCMarkerButton<Content: View>: View {
    private let variant: SCMarkerVariant
    private let axis: Axis
    private let alignment: SCMarkerAlignment
    private let role: ButtonRole?
    private let action: () -> Void
    private let content: Content

    public init(
        variant: SCMarkerVariant = .default,
        axis: Axis = .horizontal,
        alignment: SCMarkerAlignment = .leading,
        role: ButtonRole? = nil,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.axis = axis
        self.alignment = alignment
        self.role = role
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(role: role, action: action) {
            SCMarker(variant: variant, axis: axis, alignment: alignment) { content }
        }
        .buttonStyle(.plain)
    }
}

/// A real native external Link marker using the same root and public parts.
public struct SCMarkerLink<Content: View>: View {
    private let destination: URL
    private let variant: SCMarkerVariant
    private let axis: Axis
    private let alignment: SCMarkerAlignment
    private let content: Content

    public init(
        destination: URL,
        variant: SCMarkerVariant = .default,
        axis: Axis = .horizontal,
        alignment: SCMarkerAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.destination = destination
        self.variant = variant
        self.axis = axis
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        Link(destination: destination) {
            SCMarker(variant: variant, axis: axis, alignment: alignment) { content }
        }
        .buttonStyle(.plain)
    }
}

/// A real native in-app NavigationLink marker using the same root and parts.
public struct SCMarkerNavigationLink<Destination: View, Content: View>: View {
    private let variant: SCMarkerVariant
    private let axis: Axis
    private let alignment: SCMarkerAlignment
    private let destination: Destination
    private let content: Content

    public init(
        variant: SCMarkerVariant = .default,
        axis: Axis = .horizontal,
        alignment: SCMarkerAlignment = .leading,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.axis = axis
        self.alignment = alignment
        self.destination = destination()
        self.content = content()
    }

    public var body: some View {
        NavigationLink {
            destination
        } label: {
            SCMarker(variant: variant, axis: axis, alignment: alignment) { content }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon

/// The decorative icon slot of a marker — shadcn's `MarkerIcon`. Hidden
/// from assistive technologies, exactly like upstream's `aria-hidden`.
///
///     SCMarkerIcon { Image(systemName: "checkmark") }
public struct SCMarkerIcon<Content: View>: View {
    @ViewBuilder var content: Content

    /// Creates the icon slot. Put a small image or spinner inside.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .font(.caption)
            .frame(width: 16, height: 16)
            .accessibilityHidden(true)
    }
}

// MARK: - Content

/// The text content of a marker — shadcn's `MarkerContent`.
///
///     SCMarkerContent("Running tests")
///     SCMarkerContent { Text("Compacting conversation") }
public struct SCMarkerContent<Content: View>: View {
    @ViewBuilder var content: Content

    /// Creates marker content with arbitrary views.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension SCMarkerContent where Content == Text {
    /// Creates text content — the primary form.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

// MARK: - Previews

#Preview("Marker · variants") {
    SCPreview {
        VStack(spacing: 24) {
            SCMarker {
                SCMarkerIcon { Image(systemName: "checkmark") }
                SCMarkerContent("Explored 4 files")
            }
            SCMarker(variant: .border) {
                SCMarkerContent("Yesterday")
            }
            SCMarker(variant: .separator) {
                SCMarkerContent("Today")
            }
        }
        .frame(width: 340)
    }
}

#Preview("Marker · status") {
    SCPreview {
        VStack(spacing: 24) {
            SCMarker(role: .status, statusAnnouncement: "Compacting conversation") {
                SCMarkerIcon { SCSpinner(size: 16) }
                SCMarkerContent("Compacting conversation")
            }
            SCMarker(
                variant: .separator,
                role: .status,
                statusAnnouncement: "Running tests"
            ) {
                SCMarkerIcon { SCSpinner(size: 16) }
                SCMarkerContent("Running tests")
            }
        }
        .frame(width: 340)
    }
}

#Preview("Marker · composition") {
    @Previewable @State var lastAction = "No action"

    SCPreview {
        VStack(spacing: 24) {
            SCMarker(axis: .vertical, alignment: .center) {
                SCMarkerIcon { Image(systemName: "doc.text") }
                SCMarkerContent("Icon at the top")
            }
            SCMarkerButton(
                action: { lastAction = "Marker activated" },
                content: {
                    SCMarkerIcon { Image(systemName: "clock") }
                    SCMarkerContent("Marker as a native button")
                    SCMarkerIcon { Image(systemName: "chevron.right") }
                }
            )
            SCMarker(variant: .separator) {
                SCMarkerContent {
                    Button("Nested action") { lastAction = "Nested action" }
                        .buttonStyle(.sc(.outline, size: .sm))
                }
            }
            Text(lastAction).scMuted()
        }
        .frame(width: 340)
    }
}

#Preview("Marker · shimmer") {
    SCPreview {
        VStack(spacing: 24) {
            SCMarker {
                SCMarkerIcon { SCSpinner(size: 16) }
                SCMarkerContent("Thinking…").scShimmer()
            }
            SCMarker(variant: .separator) {
                SCMarkerContent("Reading 4 files").scShimmer()
            }
        }
        .frame(width: 340)
    }
}
