// ============================================================
// Avatar.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Configuration

/// Preset avatar diameters, with an escape hatch for app-specific sizes.
public enum SCAvatarSize: Sendable, Equatable {
    case sm
    case `default`
    case lg
    case custom(CGFloat)

    /// Readable aliases for the shadcn-compatible abbreviated cases.
    public static var small: Self { .sm }
    public static var large: Self { .lg }

    public var points: CGFloat {
        switch self {
        case .sm: 32
        case .default: 40
        case .lg: 56
        case .custom(let side): max(side, 0)
        }
    }
}

/// The observable loading states exposed by the official Avatar primitive.
public enum SCAvatarImageLoadingStatus: Sendable, Equatable {
    case idle
    case loading
    case loaded
    case error
}

private struct SCAvatarConfiguration {
    var size: SCAvatarSize = .default
    var isGrouped = false
}

private struct SCAvatarConfigurationKey: EnvironmentKey {
    static let defaultValue = SCAvatarConfiguration()
}

private struct SCAvatarLoadingStatusKey: EnvironmentKey {
    static let defaultValue: Binding<SCAvatarImageLoadingStatus>? = nil
}

extension EnvironmentValues {
    fileprivate var scAvatarConfiguration: SCAvatarConfiguration {
        get { self[SCAvatarConfigurationKey.self] }
        set { self[SCAvatarConfigurationKey.self] = newValue }
    }

    fileprivate var scAvatarLoadingStatus: Binding<SCAvatarImageLoadingStatus>? {
        get { self[SCAvatarLoadingStatusKey.self] }
        set { self[SCAvatarLoadingStatusKey.self] = newValue }
    }
}

// MARK: - Root

/// A composable avatar root that coordinates image and fallback loading state.
public struct SCAvatar<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAvatarConfiguration) private var inheritedConfiguration

    @State private var loadingStatus: SCAvatarImageLoadingStatus = .idle

    private let size: SCAvatarSize
    private let content: Content

    public init(
        size: SCAvatarSize = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.content = content()
    }

    public var body: some View {
        ZStack {
            Circle().fill(theme.muted)
            Circle().strokeBorder(theme.border.opacity(0.75), lineWidth: 1)
            content
        }
        .frame(width: size.points, height: size.points)
        .background {
            if inheritedConfiguration.isGrouped {
                Circle().stroke(theme.background, lineWidth: 4)
            }
        }
        .environment(
            \.scAvatarConfiguration,
            SCAvatarConfiguration(size: size, isGrouped: inheritedConfiguration.isGrouped)
        )
        .environment(\.scAvatarLoadingStatus, $loadingStatus)
    }
}

/// Compatibility initializer for the original URL-and-initials API.
extension SCAvatar where Content == TupleView<(SCAvatarImage, SCAvatarFallback<Text>)> {
    public init(url: URL?, fallback: String, size: SCAvatarSize = .default) {
        self.init(size: size) {
            SCAvatarImage(url: url, accessibilityLabel: fallback)
            SCAvatarFallback { Text(fallback) }
        }
    }
}

// MARK: - Image

/// The remotely loaded image inside an `SCAvatar`.
public struct SCAvatarImage: View {
    @Environment(\.scAvatarLoadingStatus) private var loadingStatus

    private let url: URL?
    private let scale: CGFloat
    private let contentMode: ContentMode
    private let accessibilityLabel: String?
    private let onLoadingStatusChange: ((SCAvatarImageLoadingStatus) -> Void)?

    public init(
        url: URL?,
        scale: CGFloat = 1,
        contentMode: ContentMode = .fill,
        accessibilityLabel: String? = nil,
        onLoadingStatusChange: ((SCAvatarImageLoadingStatus) -> Void)? = nil
    ) {
        self.url = url
        self.scale = scale
        self.contentMode = contentMode
        self.accessibilityLabel = accessibilityLabel
        self.onLoadingStatusChange = onLoadingStatusChange
    }

    public var body: some View {
        Group {
            if let url {
                AsyncImage(url: url, scale: scale) { phase in
                    phaseView(phase)
                }
            } else {
                Color.clear
                    .onAppear { report(.error) }
            }
        }
        .clipShape(Circle())
        .accessibilityLabel(Text(accessibilityLabel ?? ""))
        .accessibilityHidden(accessibilityLabel == nil)
    }

    @ViewBuilder
    private func phaseView(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            Color.clear
                .onAppear { report(.loading) }
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .transition(.opacity)
                .onAppear { report(.loaded) }
        case .failure:
            Color.clear
                .onAppear { report(.error) }
        @unknown default:
            Color.clear
                .onAppear { report(.error) }
        }
    }

    private func report(_ status: SCAvatarImageLoadingStatus) {
        guard loadingStatus?.wrappedValue != status else { return }
        loadingStatus?.wrappedValue = status
        onLoadingStatusChange?(status)
    }
}

// MARK: - Fallback

/// Arbitrary fallback content shown until the avatar image has loaded.
public struct SCAvatarFallback<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAvatarConfiguration) private var avatar
    @Environment(\.scAvatarLoadingStatus) private var loadingStatus

    @State private var delayElapsed = false

    private let delay: TimeInterval
    private let content: Content

    /// - Parameter delay: Seconds to wait before revealing the fallback.
    public init(
        delay: TimeInterval = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.delay = max(delay, 0)
        self.content = content()
    }

    public var body: some View {
        Group {
            if loadingStatus?.wrappedValue != .loaded, delayElapsed {
                content
                    .font(fallbackFont)
                    .foregroundStyle(theme.mutedForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }
        }
        .task(id: delay) {
            if delay > 0 {
                let nanoseconds = UInt64(min(delay, 60 * 60) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
            }
            guard !Task.isCancelled else { return }
            delayElapsed = true
        }
    }

    private var fallbackFont: Font {
        switch avatar.size {
        case .sm: .caption
        case .default: .footnote
        case .lg, .custom: .body
        }
    }
}

extension SCAvatarFallback where Content == Text {
    public init(_ text: String, delay: TimeInterval = 0) {
        self.init(delay: delay) { Text(text) }
    }
}

// MARK: - Badge

/// A status badge placed at the avatar's bottom-trailing edge.
public struct SCAvatarBadge<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAvatarConfiguration) private var avatar

    private let color: Color?
    private let content: Content

    public init(
        color: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.content = content()
    }

    public var body: some View {
        content
            .font(.system(size: max(badgeLength - 4, 6), weight: .bold))
            .foregroundStyle(theme.primaryForeground)
            .frame(width: badgeLength, height: badgeLength)
            .background(color ?? theme.primary, in: Circle())
            .overlay { Circle().stroke(theme.background, lineWidth: 2) }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .accessibilityElement(children: .combine)
    }

    private var badgeLength: CGFloat {
        switch avatar.size {
        case .sm: 8
        case .default: 10
        case .lg, .custom: 12
        }
    }
}

extension SCAvatarBadge where Content == EmptyView {
    public init(color: Color? = nil) {
        self.init(color: color) { EmptyView() }
    }
}

// MARK: - Group

/// An overlapping row of arbitrary avatar and group-count children.
public struct SCAvatarGroup<Content: View>: View {
    private let size: SCAvatarSize
    private let overlap: CGFloat
    private let content: Content

    public init(
        size: SCAvatarSize = .default,
        overlap: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.overlap = max(overlap, 0)
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: -overlap) {
            content
        }
        .environment(
            \.scAvatarConfiguration,
            SCAvatarConfiguration(size: size, isGrouped: true)
        )
    }
}

/// Compatibility content used by the original array-based group initializer.
public struct SCAvatarGroupItems: View {
    fileprivate let avatars: [(URL?, String)]
    fileprivate let size: SCAvatarSize
    fileprivate let maxCount: Int?

    public var body: some View {
        ForEach(Array(visible.enumerated()), id: \.offset) { _, avatar in
            SCAvatar(url: avatar.0, fallback: avatar.1, size: size)
        }
        if overflowCount > 0 {
            SCAvatarGroupCount(size: size) {
                Text("+\(overflowCount)")
            }
            .accessibilityLabel(Text("\(overflowCount) more"))
        }
    }

    private var visible: [(URL?, String)] {
        guard let maxCount else { return avatars }
        return Array(avatars.prefix(max(maxCount, 0)))
    }

    private var overflowCount: Int { avatars.count - visible.count }
}

extension SCAvatarGroup where Content == SCAvatarGroupItems {
    public init(
        avatars: [(URL?, String)],
        size: SCAvatarSize = .default,
        max maxCount: Int? = nil,
        overlap: CGFloat = 12
    ) {
        self.init(size: size, overlap: overlap) {
            SCAvatarGroupItems(avatars: avatars, size: size, maxCount: maxCount)
        }
    }
}

/// Arbitrary count or icon content that terminates an avatar group.
public struct SCAvatarGroupCount<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAvatarConfiguration) private var group

    private let explicitSize: SCAvatarSize?
    private let content: Content

    public init(
        size: SCAvatarSize? = nil,
        @ViewBuilder content: () -> Content
    ) {
        explicitSize = size
        self.content = content()
    }

    public var body: some View {
        content
            .font(countFont)
            .foregroundStyle(theme.mutedForeground)
            .frame(width: size.points, height: size.points)
            .background(theme.muted, in: Circle())
            .overlay { Circle().stroke(theme.background, lineWidth: 4) }
            .accessibilityElement(children: .combine)
    }

    private var size: SCAvatarSize { explicitSize ?? group.size }

    private var countFont: Font {
        switch size {
        case .sm: .caption2.weight(.medium)
        case .default: .caption.weight(.medium)
        case .lg, .custom: .footnote.weight(.medium)
        }
    }
}

extension SCAvatarGroupCount where Content == Text {
    public init(_ text: String, size: SCAvatarSize? = nil) {
        self.init(size: size) { Text(text) }
    }
}

// MARK: - Previews

#Preview("Avatar · composition") {
    SCPreview {
        HStack(spacing: 12) {
            SCAvatar(size: .small) {
                SCAvatarImage(
                    url: URL(string: "https://github.com/shadcn.png"),
                    accessibilityLabel: "shadcn"
                )
                SCAvatarFallback("CN")
                SCAvatarBadge()
            }
            SCAvatar(size: .large) {
                SCAvatarFallback("AB")
                SCAvatarBadge { Image(systemName: "checkmark") }
            }
        }
    }
}

#Preview("Avatar · group") {
    SCPreview {
        SCAvatarGroup(size: .default) {
            SCAvatar(url: nil, fallback: "CN")
            SCAvatar(url: nil, fallback: "AB")
            SCAvatar(url: nil, fallback: "CD")
            SCAvatarGroupCount("+3")
        }
    }
}
