// ============================================================
// OverlayDemos.swift — Swiftcn Showcase
// Live demos for the Overlays category. Each overlay attaches
// to a bounded stage so the scrim covers the demo box, not the
// whole app.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Stage

/// A bounded container overlays attach to. `.scDialog` & friends overlay the
/// view they're applied to, so the stage defines the scrim's reach.
private struct OverlayStage<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
    }
}

// MARK: - Dialog

struct DialogDemo: View {
    @State private var isPresented = false

    var body: some View {
        OverlayStage {
            Button("Open dialog") { isPresented = true }
                .buttonStyle(.sc(.outline))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scDialog(isPresented: $isPresented) {
            SCDialogContent {
                SCDialogHeader {
                    SCDialogTitle("Edit profile")
                    SCDialogDescription("Make changes to your profile here. Click save when you're done.")
                }
                SCDialogFooter {
                    Button("Cancel") { isPresented = false }
                        .buttonStyle(.sc(.outline))
                    Button("Save changes") { isPresented = false }
                        .buttonStyle(.sc())
                }
            }
        }
    }
}

// MARK: - Alert Dialog

struct AlertDialogDemo: View {
    @State private var isPresented = false
    @State private var lastChoice: String?

    var body: some View {
        OverlayStage {
            VStack(spacing: 12) {
                Button("Delete account") { isPresented = true }
                    .buttonStyle(.sc(.destructive))
                if let lastChoice {
                    Text(lastChoice)
                        .scMuted()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scAlertDialog(
            isPresented: $isPresented,
            title: "Delete account?",
            message: "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
            confirmLabel: "Delete",
            role: .destructive
        ) {
            lastChoice = "Confirmed at \(Date.now.formatted(date: .omitted, time: .standard))"
        }
    }
}

// MARK: - Sheet

struct SheetDemo: View {
    @State private var isPresented = false
    @State private var notifications = true
    @State private var autoSave = false

    var body: some View {
        OverlayStage {
            Button("Open sheet") { isPresented = true }
                .buttonStyle(.sc(.outline))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scSheet(isPresented: $isPresented) {
            SCSheetContent {
                SCSheetHeader {
                    SCSheetTitle("Settings")
                    SCSheetDescription("Manage your account preferences.")
                }

                Toggle("Notifications", isOn: $notifications)
                    .toggleStyle(.scSwitch)
                Toggle("Auto-save", isOn: $autoSave)
                    .toggleStyle(.scSwitch)

                Button("Save changes") { isPresented = false }
                    .buttonStyle(.sc())
            }
        }
    }
}

// MARK: - Drawer

struct DrawerDemo: View {
    @State private var isOpen = false

    var body: some View {
        OverlayStage {
            Button("Open drawer") { isOpen = true }
                .buttonStyle(.sc(.outline))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scDrawer(isPresented: $isOpen) {
            SCDrawerContent {
                SCDrawerHeader {
                    SCDrawerTitle("Are you absolutely sure?")
                    SCDrawerDescription("This action cannot be undone. This will permanently remove your data from our servers.")
                }
                SCDrawerFooter {
                    Button { isOpen = false } label: {
                        Text("Confirm").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.sc())
                    Button { isOpen = false } label: {
                        Text("Cancel").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.sc(.outline))
                }
            }
        }
    }
}

// MARK: - Popover

struct PopoverDemo: View {
    @Environment(\.theme) private var theme
    @State private var isPresented = false

    var body: some View {
        OverlayStage {
            Button("Open popover") { isPresented.toggle() }
                .buttonStyle(.sc(.outline))
                .scPopover(isPresented: $isPresented) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dimensions")
                                .font(.subheadline.weight(.semibold))
                            Text("Set the dimensions for the layer.")
                                .font(.footnote)
                                .foregroundStyle(theme.mutedForeground)
                        }
                        HStack {
                            Text("Width").font(.footnote)
                            Spacer()
                            Text("100%").font(.footnote.weight(.medium))
                        }
                        HStack {
                            Text("Height").font(.footnote)
                            Spacer()
                            Text("25px").font(.footnote.weight(.medium))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
