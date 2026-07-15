// ============================================================
// Toast.swift — swiftcn-ui
// Depends on: Theme/ · Button.swift · Spinner.swift
// ============================================================
import Accessibility
import Observation
import SwiftUI

// MARK: - Public model

public enum SCToastVariant: CaseIterable, Hashable, Sendable {
    case `default`, success, error, warning, info, loading

    fileprivate var systemImage: String? {
        switch self {
        case .default, .loading: nil
        case .success: "checkmark.circle.fill"
        case .error: "xmark.octagon.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        }
    }
}

/// Screen position of a toast stack. `.top` and `.bottom` are center aliases
/// retained for existing callers.
public enum SCToastPosition: CaseIterable, Hashable, Sendable {
    case top, bottom
    case topLeading, topTrailing
    case bottomLeading, bottomTrailing

    var alignment: Alignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }

    fileprivate var edge: Edge {
        switch self {
        case .top, .topLeading, .topTrailing: .top
        case .bottom, .bottomLeading, .bottomTrailing: .bottom
        }
    }

    fileprivate var defaultSwipeDirection: SCToastSwipeDirection {
        edge == .top ? .top : .bottom
    }
}

public enum SCToastSwipeDirection: CaseIterable, Hashable, Sendable {
    case top, bottom, leading, trailing
}

/// Presentation defaults for either `.scToaster` or `SCSonnerToaster`.
public struct SCToasterConfiguration: Hashable, Sendable {
    public var position: SCToastPosition
    public var visibleToasts: Int
    public var expand: Bool
    public var gap: CGFloat
    public var showsCloseButton: Bool
    public var pauseOnHover: Bool
    public var swipeDirections: Set<SCToastSwipeDirection>

    public init(
        position: SCToastPosition = .bottom,
        visibleToasts: Int = 3,
        expand: Bool = false,
        gap: CGFloat = 8,
        showsCloseButton: Bool = true,
        pauseOnHover: Bool = true,
        swipeDirections: Set<SCToastSwipeDirection> = []
    ) {
        self.position = position
        self.visibleToasts = max(visibleToasts, 1)
        self.expand = expand
        self.gap = max(gap, 0)
        self.showsCloseButton = showsCloseButton
        self.pauseOnHover = pauseOnHover
        self.swipeDirections = swipeDirections
    }

    fileprivate var resolvedSwipeDirections: Set<SCToastSwipeDirection> {
        swipeDirections.isEmpty ? [position.defaultSwipeDirection] : swipeDirections
    }
}

/// A real button action rendered inside a toast. Running it dismisses the toast.
public struct SCToastAction: Sendable {
    public var label: String
    public var handler: @Sendable () -> Void

    public init(_ label: String, handler: @escaping @Sendable () -> Void) {
        self.label = label
        self.handler = handler
    }
}

/// A single notification in the shared Toast/Sonner queue.
public struct SCToast: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var variant: SCToastVariant
    /// `nil` keeps the toast visible until it is explicitly dismissed or updated.
    public var duration: Duration?
    public var action: SCToastAction?
    public var cancel: SCToastAction?
    public var isDismissible: Bool
    public var showsCloseButton: Bool?
    public var onDismiss: (@Sendable (UUID) -> Void)?
    public var onAutoClose: (@Sendable (UUID) -> Void)?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        variant: SCToastVariant = .default,
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil,
        cancel: SCToastAction? = nil,
        isDismissible: Bool = true,
        showsCloseButton: Bool? = nil,
        onDismiss: (@Sendable (UUID) -> Void)? = nil,
        onAutoClose: (@Sendable (UUID) -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.variant = variant
        self.duration = duration
        self.action = action
        self.cancel = cancel
        self.isDismissible = isDismissible
        self.showsCloseButton = showsCloseButton
        self.onDismiss = onDismiss
        self.onAutoClose = onAutoClose
    }

    fileprivate var announcement: String {
        [title, description].compactMap { $0 }.joined(separator: ". ")
    }
}

// MARK: - Shared queue engine

/// The one observable queue used by both the compatibility Toast API and the
/// current Sonner API. Showing an existing ID updates it in place.
@MainActor
@Observable
public final class SCToastCenter {
    public static let shared = SCToastCenter()

    public private(set) var toasts: [SCToast] = []
    /// Compatibility default read by existing hosts.
    public var maxVisible = 3

    @ObservationIgnored private var dismissTasks: [UUID: Task<Void, Never>] = [:]
    @ObservationIgnored private var remainingDurations: [UUID: Duration] = [:]
    @ObservationIgnored private var timerStartInstants: [UUID: ContinuousClock.Instant] = [:]

    public init() {}

    /// Inserts or updates a toast and returns its stable identifier.
    @discardableResult
    public func show(_ toast: SCToast) -> UUID {
        if let index = toasts.firstIndex(where: { $0.id == toast.id }) {
            toasts[index] = toast
        } else {
            toasts.append(toast)
        }
        scheduleAutoDismiss(for: toast, resetting: true)
        AccessibilityNotification.Announcement(toast.announcement).post()
        return toast.id
    }

    /// Convenience matching Sonner's common message/description call.
    @discardableResult
    public func show(
        title: String,
        description: String? = nil,
        variant: SCToastVariant = .default,
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil,
        cancel: SCToastAction? = nil
    ) -> UUID {
        show(
            SCToast(
                title: title,
                description: description,
                variant: variant,
                duration: duration,
                action: action,
                cancel: cancel
            )
        )
    }

    /// Mutates an existing toast in place and restarts its timer.
    public func update(_ id: UUID, _ update: (inout SCToast) -> Void) {
        guard let index = toasts.firstIndex(where: { $0.id == id }) else { return }
        update(&toasts[index])
        let toast = toasts[index]
        scheduleAutoDismiss(for: toast, resetting: true)
        AccessibilityNotification.Announcement(toast.announcement).post()
    }

    public func pause(_ id: UUID) {
        guard
            let remaining = remainingDurations[id],
            let startedAt = timerStartInstants[id]
        else { return }

        dismissTasks.removeValue(forKey: id)?.cancel()
        timerStartInstants.removeValue(forKey: id)
        let elapsed = startedAt.duration(to: ContinuousClock.now)
        remainingDurations[id] = max(remaining - elapsed, .zero)
    }

    public func resume(_ id: UUID) {
        guard dismissTasks[id] == nil, let remaining = remainingDurations[id] else { return }
        startTimer(for: id, duration: remaining)
    }

    public func dismiss(_ id: UUID) {
        remove(id, automatically: false)
    }

    public func dismissAll() {
        let currentToasts = toasts
        for toast in currentToasts {
            remove(toast.id, automatically: false)
        }
    }

    private func scheduleAutoDismiss(for toast: SCToast, resetting: Bool) {
        dismissTasks.removeValue(forKey: toast.id)?.cancel()
        timerStartInstants.removeValue(forKey: toast.id)
        if resetting { remainingDurations.removeValue(forKey: toast.id) }
        guard let duration = toast.duration else { return }
        remainingDurations[toast.id] = duration
        startTimer(for: toast.id, duration: duration)
    }

    private func startTimer(for id: UUID, duration: Duration) {
        guard duration > .zero else {
            remove(id, automatically: true)
            return
        }
        timerStartInstants[id] = ContinuousClock.now
        dismissTasks[id] = Task { [weak self] in
            try? await Task.sleep(for: duration)
            guard !Task.isCancelled else { return }
            self?.remove(id, automatically: true)
        }
    }

    private func remove(_ id: UUID, automatically: Bool) {
        guard let toast = toasts.first(where: { $0.id == id }) else { return }
        dismissTasks.removeValue(forKey: id)?.cancel()
        remainingDurations.removeValue(forKey: id)
        timerStartInstants.removeValue(forKey: id)
        toasts.removeAll { $0.id == id }
        if automatically {
            toast.onAutoClose?(id)
        } else {
            toast.onDismiss?(id)
        }
    }
}

// MARK: - Compatibility host

extension View {
    /// Hosts the shared queue. Existing Toast callers and the current Sonner
    /// facade render through the same `SCToastStack` implementation.
    public func scToaster(position: SCToastPosition = .bottom) -> some View {
        scToaster(configuration: SCToasterConfiguration(position: position))
    }

    public func scToaster(configuration: SCToasterConfiguration) -> some View {
        overlay(alignment: configuration.position.alignment) {
            SCToastStack(center: .shared, configuration: configuration)
        }
    }
}

// MARK: - Shared stack

struct SCToastStack: View {
    let center: SCToastCenter
    let configuration: SCToasterConfiguration

    @State private var isHovered = false

    var body: some View {
        let visible = Array(center.toasts.suffix(configuration.visibleToasts))
        Group {
            if configuration.expand || isHovered {
                expandedStack(visible)
            } else {
                collapsedStack(visible)
            }
        }
        .padding(16)
        .onHover { isHovered = $0 }
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: center.toasts.map(\.id)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: isHovered)
    }

    private func expandedStack(_ toasts: [SCToast]) -> some View {
        VStack(spacing: configuration.gap) {
            ForEach(toasts) { toast in card(for: toast) }
        }
    }

    private func collapsedStack(_ toasts: [SCToast]) -> some View {
        ZStack(alignment: configuration.position.alignment) {
            ForEach(Array(toasts.enumerated()), id: \.element.id) { index, toast in
                let depth = toasts.count - 1 - index
                card(for: toast)
                    .scaleEffect(
                        pow(0.95, CGFloat(depth)),
                        anchor: configuration.position.edge == .bottom ? .bottom : .top
                    )
                    .offset(
                        y: CGFloat(depth)
                            * (configuration.position.edge == .bottom ? -configuration.gap : configuration.gap)
                    )
                    .zIndex(Double(index))
            }
        }
    }

    private func card(for toast: SCToast) -> some View {
        SCToastCard(
            toast: toast,
            configuration: configuration,
            onPause: { center.pause(toast.id) },
            onResume: { center.resume(toast.id) },
            onDismiss: { center.dismiss(toast.id) }
        )
        .transition(.move(edge: configuration.position.edge).combined(with: .opacity))
    }
}

// MARK: - Shared card

private struct SCToastCard: View {
    @Environment(\.theme) private var theme

    let toast: SCToast
    let configuration: SCToasterConfiguration
    let onPause: () -> Void
    let onResume: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        HStack(spacing: 10) {
            icon
            content
            actions
            closeButton
        }
        .padding(14)
        .frame(maxWidth: 380)
        .background(theme.popover, in: shape)
        .overlay(shape.strokeBorder(theme.border))
        .shadow(radius: 12, y: 4)
        .offset(dragOffset)
        .gesture(swipeGesture)
        .onHover { hovering in
            guard configuration.pauseOnHover else { return }
            if hovering {
                onPause()
            } else {
                onResume()
            }
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var icon: some View {
        if toast.variant == .loading {
            SCSpinner(size: 16, lineWidth: 1.5)
                .accessibilityHidden(true)
        } else if let systemImage = toast.variant.systemImage {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(toast.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.popoverForeground)
            if let description = toast.description {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(theme.mutedForeground)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var actions: some View {
        if let action = toast.action {
            Button(action.label) {
                action.handler()
                onDismiss()
            }
            .buttonStyle(.sc(.outline, size: .sm))
        }
        if let cancel = toast.cancel {
            Button(cancel.label) {
                cancel.handler()
                onDismiss()
            }
            .buttonStyle(.sc(.ghost, size: .sm))
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        if toast.isDismissible && (toast.showsCloseButton ?? configuration.showsCloseButton) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.mutedForeground)
                    .padding(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss notification")
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }

    private var iconColor: Color {
        toast.variant == .error ? theme.destructive : theme.foreground
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard toast.isDismissible else { return }
                dragOffset = allowedOffset(for: value.translation)
            }
            .onEnded { _ in
                guard toast.isDismissible else { return }
                if dismissalProgress(for: dragOffset) > 40 {
                    onDismiss()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func allowedOffset(for translation: CGSize) -> CGSize {
        let directions = configuration.resolvedSwipeDirections
        let horizontal: CGFloat
        if translation.width < 0, directions.contains(.leading) {
            horizontal = translation.width
        } else if translation.width > 0, directions.contains(.trailing) {
            horizontal = translation.width
        } else {
            horizontal = 0
        }

        let vertical: CGFloat
        if translation.height < 0, directions.contains(.top) {
            vertical = translation.height
        } else if translation.height > 0, directions.contains(.bottom) {
            vertical = translation.height
        } else {
            vertical = 0
        }
        return CGSize(width: horizontal, height: vertical)
    }

    private func dismissalProgress(for offset: CGSize) -> CGFloat {
        max(abs(offset.width), abs(offset.height))
    }
}

// MARK: - Compatibility preview

#Preview("Toast compatibility API") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Default") {
                SCToastCenter.shared.show(
                    title: "Event has been created",
                    description: "Monday, January 3rd at 6:00pm"
                )
            }
            .buttonStyle(.sc(.outline))

            Button("With action") {
                SCToastCenter.shared.show(
                    SCToast(
                        title: "Message archived",
                        action: SCToastAction("Undo") {}
                    )
                )
            }
            .buttonStyle(.sc(.outline))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        .scToaster()
    }
}
