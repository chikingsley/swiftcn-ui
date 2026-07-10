// ============================================================
// Toast.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (SCButtonStyle)
// ============================================================
import Observation
import SwiftUI

// MARK: - Variants

public enum SCToastVariant: CaseIterable, Sendable {
    case `default`, success, error, warning, info

    var systemImage: String? {
        switch self {
        case .default: nil
        case .success: "checkmark.circle.fill"
        case .error:   "xmark.octagon.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info:    "info.circle.fill"
        }
    }
}

/// Which screen edge the toast stack grows from.
public enum SCToastPosition: Sendable {
    case top, bottom

    var alignment: Alignment { self == .top ? .top : .bottom }
    var edge: Edge { self == .top ? .top : .bottom }
}

// MARK: - Toast

/// A single toast notification — swiftcn's port of a Sonner toast.
///
///     SCToastCenter.shared.show(title: "Event created", variant: .success)
public struct SCToast: Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var variant: SCToastVariant
    /// How long the toast stays on screen before auto-dismissing.
    public var duration: Duration
    public var action: SCToastAction?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        variant: SCToastVariant = .default,
        duration: Duration = .seconds(4),
        action: SCToastAction? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.variant = variant
        self.duration = duration
        self.action = action
    }
}

/// A tappable action rendered as a small outline button on the toast card.
/// Running the action dismisses the toast.
public struct SCToastAction: Sendable {
    public var label: String
    public var handler: @Sendable () -> Void

    public init(_ label: String, handler: @escaping @Sendable () -> Void) {
        self.label = label
        self.handler = handler
    }
}

// MARK: - Center

/// The toast dispatcher — Sonner's `toast()` as an observable singleton.
///
/// Call `show` from anywhere on the main actor; every view hierarchy wrapped
/// in `scToaster(position:)` renders the queue. Each toast auto-dismisses
/// after its `duration` (4s by default); manual dismissal cancels the timer.
@MainActor
@Observable
public final class SCToastCenter {
    public static let shared = SCToastCenter()

    /// All queued toasts, oldest first. `scToaster` renders the newest
    /// `maxVisible` as a stack; older toasts stay queued until their
    /// timers expire.
    public private(set) var toasts: [SCToast] = []

    /// How many toasts the stack shows at once.
    public var maxVisible = 3

    @ObservationIgnored private var dismissTasks: [UUID: Task<Void, Never>] = [:]

    public init() {}

    /// Enqueues a toast and schedules its auto-dismissal.
    public func show(_ toast: SCToast) {
        toasts.append(toast)
        scheduleAutoDismiss(for: toast)
    }

    /// Convenience for the common title/description case.
    public func show(
        title: String,
        description: String? = nil,
        variant: SCToastVariant = .default
    ) {
        show(SCToast(title: title, description: description, variant: variant))
    }

    /// Removes a toast immediately and cancels its auto-dismiss timer.
    public func dismiss(_ id: UUID) {
        dismissTasks.removeValue(forKey: id)?.cancel()
        toasts.removeAll { $0.id == id }
    }

    /// Clears the whole queue.
    public func dismissAll() {
        dismissTasks.values.forEach { $0.cancel() }
        dismissTasks.removeAll()
        toasts.removeAll()
    }

    private func scheduleAutoDismiss(for toast: SCToast) {
        dismissTasks[toast.id] = Task { [weak self] in
            try? await Task.sleep(for: toast.duration)
            guard !Task.isCancelled else { return }
            self?.dismiss(toast.id)
        }
    }
}

// MARK: - Modifier

public extension View {
    /// Hosts the toast stack fed by `SCToastCenter.shared` — Sonner's
    /// `<Toaster />`. Apply once, near the root of the view hierarchy.
    ///
    ///     WindowGroup {
    ///         ContentView().scToaster()
    ///     }
    func scToaster(position: SCToastPosition = .bottom) -> some View {
        modifier(SCToasterModifier(position: position))
    }
}

private struct SCToasterModifier: ViewModifier {
    var position: SCToastPosition

    func body(content: Content) -> some View {
        content.overlay(alignment: position.alignment) {
            SCToastStack(position: position)
        }
    }
}

// MARK: - Stack

private struct SCToastStack: View {
    var position: SCToastPosition

    var body: some View {
        let center = SCToastCenter.shared
        let visible = Array(center.toasts.suffix(center.maxVisible))

        ZStack(alignment: position.alignment) {
            ForEach(Array(visible.enumerated()), id: \.element.id) { index, toast in
                // Newest toast sits flush with the edge; older ones scale
                // down and peek out 8pt behind it, Sonner-style.
                let depth = visible.count - 1 - index
                SCToastCard(toast: toast, position: position) {
                    center.dismiss(toast.id)
                }
                .scaleEffect(
                    pow(0.95, CGFloat(depth)),
                    anchor: position == .bottom ? .bottom : .top
                )
                .offset(y: CGFloat(depth) * (position == .bottom ? -8 : 8))
                .zIndex(Double(index))
                .transition(.move(edge: position.edge).combined(with: .opacity))
            }
        }
        .padding(16)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: center.toasts.map(\.id)
        )
    }
}

// MARK: - Card

private struct SCToastCard: View {
    @Environment(\.theme) private var theme

    let toast: SCToast
    var position: SCToastPosition
    var onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 10) {
            if let systemImage = toast.variant.systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(iconColor)
            }

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

            if let action = toast.action {
                Button(action.label) {
                    action.handler()
                    onDismiss()
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.mutedForeground)
                    .padding(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(14)
        .frame(maxWidth: 380)
        .background(theme.popover, in: shape)
        .overlay(shape.strokeBorder(theme.border))
        .shadow(radius: 12, y: 4)
        .offset(y: dragOffset)
        .gesture(swipe)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }

    private var iconColor: Color {
        toast.variant == .error ? theme.destructive : theme.foreground
    }

    /// Swiping toward the stack's edge dismisses the toast; swipes away
    /// from the edge are ignored.
    private var swipe: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                dragOffset = position == .bottom
                    ? max(0, translation)
                    : min(0, translation)
            }
            .onEnded { value in
                let towardEdge = position == .bottom
                    ? value.translation.height
                    : -value.translation.height
                if towardEdge > 40 {
                    onDismiss()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        dragOffset = 0
                    }
                }
            }
    }
}

// MARK: - Previews

#Preview("Toast") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Default") {
                SCToastCenter.shared.show(
                    title: "Event has been created",
                    description: "Sunday, December 03, 2023 at 9:00 AM"
                )
            }
            .buttonStyle(.sc(.outline))

            Button("Success") {
                SCToastCenter.shared.show(title: "Changes saved", variant: .success)
            }
            .buttonStyle(.sc(.outline))

            Button("Error") {
                SCToastCenter.shared.show(
                    title: "Something went wrong",
                    description: "Your changes could not be saved.",
                    variant: .error
                )
            }
            .buttonStyle(.sc(.outline))

            Button("Warning") {
                SCToastCenter.shared.show(title: "Storage almost full", variant: .warning)
            }
            .buttonStyle(.sc(.outline))

            Button("Info") {
                SCToastCenter.shared.show(title: "A new version is available", variant: .info)
            }
            .buttonStyle(.sc(.outline))

            Button("With action") {
                SCToastCenter.shared.show(SCToast(
                    title: "Message archived",
                    action: SCToastAction("Undo") { print("undo") }
                ))
            }
            .buttonStyle(.sc(.outline))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        .scToaster()
    }
}
