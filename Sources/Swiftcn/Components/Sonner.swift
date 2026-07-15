// ============================================================
// Sonner.swift — swiftcn-ui
// Depends on: Toast.swift
// ============================================================
import SwiftUI

/// A promise handle returned by `SCSonner.promise`. The toast uses the same ID
/// for loading, success, and failure while the caller can still await `value`.
public struct SCSonnerPromise<Value: Sendable>: Sendable {
    public let id: UUID
    private let task: Task<Value, Error>

    init(id: UUID, task: Task<Value, Error>) {
        self.id = id
        self.task = task
    }

    public var value: Value {
        get async throws { try await task.value }
    }

    public func cancel() {
        task.cancel()
    }
}

/// The current Sonner-shaped notification API. It is a typed facade over
/// `SCToastCenter`; it does not own another queue or presentation engine.
@MainActor
public enum SCSonner {
    @discardableResult
    public static func show(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil,
        cancel: SCToastAction? = nil,
        isDismissible: Bool = true,
        showsCloseButton: Bool? = nil,
        onDismiss: (@Sendable (UUID) -> Void)? = nil,
        onAutoClose: (@Sendable (UUID) -> Void)? = nil
    ) -> UUID {
        SCToastCenter.shared.show(
            SCToast(
                id: id,
                title: title,
                description: description,
                duration: duration,
                action: action,
                cancel: cancel,
                isDismissible: isDismissible,
                showsCloseButton: showsCloseButton,
                onDismiss: onDismiss,
                onAutoClose: onAutoClose
            )
        )
    }

    @discardableResult
    public static func success(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil
    ) -> UUID {
        showVariant(
            .success,
            title: title,
            description: description,
            id: id,
            duration: duration,
            action: action
        )
    }

    @discardableResult
    public static func info(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil
    ) -> UUID {
        showVariant(
            .info,
            title: title,
            description: description,
            id: id,
            duration: duration,
            action: action
        )
    }

    @discardableResult
    public static func warning(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil
    ) -> UUID {
        showVariant(
            .warning,
            title: title,
            description: description,
            id: id,
            duration: duration,
            action: action
        )
    }

    @discardableResult
    public static func error(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        duration: Duration? = .seconds(4),
        action: SCToastAction? = nil
    ) -> UUID {
        showVariant(
            .error,
            title: title,
            description: description,
            id: id,
            duration: duration,
            action: action
        )
    }

    /// Shows a persistent loading toast. Reuse the returned ID with another
    /// variant or use `promise` to update it automatically.
    @discardableResult
    public static func loading(
        _ title: String,
        description: String? = nil,
        id: UUID = UUID(),
        isDismissible: Bool = true
    ) -> UUID {
        SCToastCenter.shared.show(
            SCToast(
                id: id,
                title: title,
                description: description,
                variant: .loading,
                duration: nil,
                isDismissible: isDismissible
            )
        )
    }

    /// Updates any fields of an active toast without changing its queue position.
    public static func update(_ id: UUID, _ update: (inout SCToast) -> Void) {
        SCToastCenter.shared.update(id, update)
    }

    public static func dismiss(_ id: UUID) {
        SCToastCenter.shared.dismiss(id)
    }

    public static func dismissAll() {
        SCToastCenter.shared.dismissAll()
    }

    /// Runs asynchronous work while one stable toast transitions from loading
    /// to success or error. The returned handle preserves the original result.
    @discardableResult
    public static func promise<Value: Sendable>(
        _ operation: @escaping @Sendable () async throws -> Value,
        loading: String,
        success: @escaping @Sendable (Value) -> String,
        failure: @escaping @Sendable (Error) -> String,
        description: String? = nil,
        duration: Duration? = .seconds(4)
    ) -> SCSonnerPromise<Value> {
        let id = self.loading(loading, description: description, isDismissible: false)
        let task = Task { try await operation() }

        Task { @MainActor in
            do {
                let result = try await task.value
                showVariant(
                    .success,
                    title: success(result),
                    description: description,
                    id: id,
                    duration: duration
                )
            } catch {
                showVariant(
                    .error,
                    title: failure(error),
                    description: description,
                    id: id,
                    duration: duration
                )
            }
        }

        return SCSonnerPromise(id: id, task: task)
    }

    @discardableResult
    private static func showVariant(
        _ variant: SCToastVariant,
        title: String,
        description: String?,
        id: UUID,
        duration: Duration?,
        action: SCToastAction? = nil
    ) -> UUID {
        SCToastCenter.shared.show(
            SCToast(
                id: id,
                title: title,
                description: description,
                variant: variant,
                duration: duration,
                action: action
            )
        )
    }
}

/// The SwiftUI analog of shadcn's exported `<Toaster />`.
public struct SCSonnerToaster: View {
    private let configuration: SCToasterConfiguration

    public init(configuration: SCToasterConfiguration = SCToasterConfiguration()) {
        self.configuration = configuration
    }

    public var body: some View {
        SCToastStack(center: .shared, configuration: configuration)
    }
}

extension View {
    /// Hosts the Sonner stack once near the app/window root.
    public func scSonnerToaster(
        configuration: SCToasterConfiguration = SCToasterConfiguration()
    ) -> some View {
        overlay(alignment: configuration.position.alignment) {
            SCSonnerToaster(configuration: configuration)
        }
    }
}

#Preview("Sonner") {
    SCPreview {
        VStack(spacing: 12) {
            Button("Show toast") {
                SCSonner.show(
                    "Event has been created",
                    description: "Monday, January 3rd at 6:00pm"
                )
            }
            .buttonStyle(.sc(.outline))

            Button("Show promise") {
                SCSonner.promise(
                    {
                        try await Task.sleep(for: .seconds(1))
                        return "Report"
                    },
                    loading: "Saving…",
                    success: { "\($0) saved" },
                    failure: { $0.localizedDescription }
                )
            }
            .buttonStyle(.sc(.outline))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        .scSonnerToaster()
    }
}
