// ============================================================
// DatePicker.swift — swiftcn-ui
// Depends on: Theme/ · Calendar.swift
// ============================================================
import SwiftUI

// MARK: - Component

/// An input-look trigger that opens an `SCCalendar` in a popover — shadcn's
/// Date Picker composition. Picking a date closes the popover.
///
///     SCDatePicker(selection: $date)
///     SCDatePicker("Date of birth", selection: $birthday, in: earliest...Date())
public struct SCDatePicker: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: Date?
    private let placeholder: String
    private let bounds: ClosedRange<Date>?

    @State private var isPresented = false

    /// Creates a date picker.
    ///
    /// - Parameters:
    ///   - placeholder: Muted text shown while no date is selected.
    ///   - selection: The selected day, written at the picked day's midnight.
    ///   - bounds: Days outside this range are disabled in the calendar.
    public init(
        _ placeholder: String = "Pick a date",
        selection: Binding<Date?>,
        in bounds: ClosedRange<Date>? = nil
    ) {
        self.placeholder = placeholder
        self._selection = selection
        self.bounds = bounds
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            trigger
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented) {
            SCCalendar(selection: dismissingSelection, bounds: bounds)
                .padding(12)
                .presentationBackground(theme.popover)
                .presentationCompactAdaptation(.popover)
        }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: isPresented)
    }

    private var trigger: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .foregroundStyle(theme.mutedForeground)
            if let selection {
                Text(selection, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                    .foregroundStyle(theme.foreground)
            } else {
                Text(placeholder)
                    .foregroundStyle(theme.mutedForeground)
            }
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(theme.background, in: shape)
        .overlay(shape.strokeBorder(isPresented ? theme.ring : theme.input, lineWidth: isPresented ? 1.5 : 1))
        .contentShape(shape)
    }

    /// Forwards writes to `selection` and closes the popover on any pick —
    /// including re-picking the already selected day.
    private var dismissingSelection: Binding<Date?> {
        Binding {
            selection
        } set: { newValue in
            selection = newValue
            isPresented = false
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Previews

#Preview("DatePicker") {
    @Previewable @State var date: Date? = nil
    SCPreview {
        SCDatePicker(selection: $date)
    }
    .frame(height: 420)
}

#Preview("DatePicker · states") {
    @Previewable @State var selected: Date? = Date()
    @Previewable @State var bounded: Date? = nil
    let today = Calendar.current.startOfDay(for: Date())
    let limit = Calendar.current.date(byAdding: .month, value: 1, to: today) ?? today
    SCPreview {
        VStack(spacing: 12) {
            SCDatePicker(selection: $selected)
            SCDatePicker("Within a month", selection: $bounded, in: today...limit)
            SCDatePicker(selection: .constant(nil))
                .disabled(true)
        }
    }
    .frame(height: 420)
}
