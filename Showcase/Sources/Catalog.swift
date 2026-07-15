// ============================================================
// Catalog.swift — Swiftcn macOS Showcase
// The registry: one entry per component, block, and effect.
// AnyView is deliberately permitted here — this is the app's
// internal heterogeneous catalog, not library API.
// ============================================================
import SwiftUI
import Swiftcn

// This registry intentionally keeps every searchable showcase entry together.
// swiftlint:disable file_length

// MARK: - Category

enum Category: String, CaseIterable, Identifiable {
    case formsAndInput
    case display
    case feedback
    case navigation
    case overlays
    case audio
    case blocks
    case effects

    var id: String { rawValue }

    var title: String {
        switch self {
        case .formsAndInput: "Forms & Input"
        case .display: "Display"
        case .feedback: "Feedback"
        case .navigation: "Navigation"
        case .overlays: "Overlays"
        case .audio: "Audio"
        case .blocks: "Blocks"
        case .effects: "Effects"
        }
    }

    var systemImage: String {
        switch self {
        case .formsAndInput: "square.and.pencil"
        case .display: "square.grid.2x2"
        case .feedback: "bell.badge"
        case .navigation: "sidebar.leading"
        case .overlays: "square.stack"
        case .audio: "waveform"
        case .blocks: "cube"
        case .effects: "sparkles"
        }
    }
}

// MARK: - Entry

struct ComponentEntry: Identifiable {
    let id: String
    let name: String
    let category: Category
    /// Sidebar row icon (SF Symbol) — keeps the icon rail meaningful.
    let icon: String
    /// One-line description shown at the top of the detail page.
    let description: String
    /// A 2–4 line usage snippet rendered as monospaced text.
    let usage: String
    /// Builds the live demo for the detail page.
    let demoView: @MainActor () -> AnyView
}

// MARK: - Catalog

enum Catalog {
    @MainActor static let all: [ComponentEntry] = coreEntries + audioEntries

    /// Entries for one sidebar group, in catalog order.
    @MainActor static func entries(in category: Category) -> [ComponentEntry] {
        all.filter { $0.category == category }
    }
}

// MARK: - Core entries

// The entry literals live in extensions so the Catalog body stays inside
// the type-body-length budget; sidebar grouping order comes from Category,
// not from position in `all`.
extension Catalog {
    @MainActor fileprivate static let coreEntries: [ComponentEntry] = [

        // MARK: Forms & Input

        ComponentEntry(
            id: "button",
            name: "Button",
            category: .formsAndInput,
            icon: "hand.tap",
            description: "Six variants and eight sizes, styled onto the native SwiftUI Button.",
            usage: """
                Button("Continue") { continueFlow() }.buttonStyle(.sc())
                Button("Delete") { deleteItem() }.buttonStyle(.sc(.destructive))
                Button("Cancel") { cancel() }.buttonStyle(.sc(.outline, size: .sm))
                """,
            demoView: { AnyView(ButtonDemo()) }
        ),
        ComponentEntry(
            id: "button-group",
            name: "Button Group",
            category: .formsAndInput,
            icon: "rectangle.split.3x1",
            description: "A row of attached buttons sharing one bordered container.",
            usage: """
                SCButtonGroup(items: [
                    .init(label: "Copy") { copy() },
                    .init(label: "Paste") { paste() },
                    .init(systemImage: "ellipsis") { showMoreActions() },
                ])
                """,
            demoView: { AnyView(ButtonGroupDemo()) }
        ),
        ComponentEntry(
            id: "calendar",
            name: "Calendar",
            category: .formsAndInput,
            icon: "calendar",
            description: "A locale-aware month grid with single-date and range selection.",
            usage: """
                SCCalendar(selection: $date)                     // single date
                SCCalendar(range: $stay)                         // date range
                SCCalendar(selection: $date, bounds: today...max)
                """,
            demoView: { AnyView(CalendarDemo()) }
        ),
        ComponentEntry(
            id: "checkbox",
            name: "Checkbox",
            category: .formsAndInput,
            icon: "checkmark.square",
            description: "A square check control for native Toggles — behavior stays native.",
            usage: """
                Toggle("Accept terms and conditions", isOn: $accepted)
                    .toggleStyle(.scCheckbox)
                """,
            demoView: { AnyView(CheckboxDemo()) }
        ),
        ComponentEntry(
            id: "combobox",
            name: "Combobox",
            category: .formsAndInput,
            icon: "text.magnifyingglass",
            description: "A searchable select: a field trigger opening a filtered option list.",
            usage: """
                SCCombobox(selection: $framework,
                           options: ["Next.js", "SvelteKit", "Nuxt.js", "Remix", "Astro"])
                """,
            demoView: { AnyView(ComboboxDemo()) }
        ),
        ComponentEntry(
            id: "date-picker",
            name: "Date Picker",
            category: .formsAndInput,
            icon: "calendar.badge.clock",
            description: "An input-look trigger that opens an SCCalendar in a popover.",
            usage: """
                SCDatePicker(selection: $date)
                SCDatePicker("Date of birth", selection: $birthday, in: earliest...Date())
                """,
            demoView: { AnyView(DatePickerDemo()) }
        ),
        ComponentEntry(
            id: "field",
            name: "Field",
            category: .formsAndInput,
            icon: "rectangle.and.pencil.and.ellipsis",
            description: "Stacks a label, any control, and a description or error caption.",
            usage: """
                SCField("Email", required: true, error: "Enter a valid email.") {
                    SCInput("you@example.com", text: $email)
                }
                """,
            demoView: { AnyView(FieldDemo()) }
        ),
        ComponentEntry(
            id: "input",
            name: "Input",
            category: .formsAndInput,
            icon: "character.cursor.ibeam",
            description: "A themed single-line text field with icon and trailing accessory slots.",
            usage: """
                SCInput("Email", text: $email, icon: "envelope")
                SCInput("Age", value: $age)      // Int -> number pad
                SCInput("Price", value: $price)  // Double -> decimal pad
                """,
            demoView: { AnyView(InputDemo()) }
        ),
        ComponentEntry(
            id: "input-otp",
            name: "Input OTP",
            category: .formsAndInput,
            icon: "ellipsis.rectangle",
            description: "One-time-code entry with grouped digit boxes and native autofill.",
            usage: """
                SCInputOTP(code: $code)                             // 6 digits, 3 + 3
                SCInputOTP(code: $code, length: 4, groupSize: nil)  // 4, ungrouped
                """,
            demoView: { AnyView(InputOTPDemo()) }
        ),
        ComponentEntry(
            id: "label",
            name: "Label",
            category: .formsAndInput,
            icon: "tag",
            description: "A form label with an optional destructive required asterisk.",
            usage: """
                SCLabel("Email")
                SCLabel("Password", required: true)
                """,
            demoView: { AnyView(LabelDemo()) }
        ),
        ComponentEntry(
            id: "radio-group",
            name: "Radio Group",
            category: .formsAndInput,
            icon: "smallcircle.filled.circle",
            description: "A set of mutually exclusive option rows bound to one selection.",
            usage: """
                SCRadioGroup(selection: $density) {
                    SCRadio("Default", value: "default")
                    SCRadio("Comfortable", value: "comfortable")
                }
                """,
            demoView: { AnyView(RadioGroupDemo()) }
        ),
        ComponentEntry(
            id: "select",
            name: "Select",
            category: .formsAndInput,
            icon: "chevron.up.chevron.down",
            description: "A dropdown styled like an input, built on the native Menu.",
            usage: """
                SCSelect(selection: $fruit,
                         placeholder: "Select a fruit",
                         options: ["Apple", "Banana", "Blueberry"])
                """,
            demoView: { AnyView(SelectDemo()) }
        ),
        ComponentEntry(
            id: "slider",
            name: "Slider",
            category: .formsAndInput,
            icon: "slider.horizontal.3",
            description: "A themed range input with optional stepping and native accessibility.",
            usage: """
                SCSlider(value: $volume)
                SCSlider(value: $rating, in: 0...100, step: 10)
                """,
            demoView: { AnyView(SliderDemo()) }
        ),
        ComponentEntry(
            id: "switch",
            name: "Switch",
            category: .formsAndInput,
            icon: "switch.2",
            description: "shadcn's capsule switch appearance for native Toggles.",
            usage: """
                Toggle("Airplane Mode", isOn: $airplaneMode)
                    .toggleStyle(.scSwitch)
                """,
            demoView: { AnyView(SwitchDemo()) }
        ),
        ComponentEntry(
            id: "textarea",
            name: "Textarea",
            category: .formsAndInput,
            icon: "text.alignleft",
            description: "A themed multi-line text area with a muted placeholder.",
            usage: """
                SCTextarea("Type your message here.", text: $message)
                SCTextarea("Bio", text: $bio, minHeight: 140)
                """,
            demoView: { AnyView(TextareaDemo()) }
        ),
        ComponentEntry(
            id: "toggle",
            name: "Toggle",
            category: .formsAndInput,
            icon: "bold",
            description: "A two-state pressed button — think a toolbar Bold control.",
            usage: """
                Toggle("Bold", systemImage: "bold", isOn: $isBold)
                    .toggleStyle(.scToggle())
                    .labelStyle(.iconOnly)
                """,
            demoView: { AnyView(ToggleDemo()) }
        ),
        ComponentEntry(
            id: "toggle-group",
            name: "Toggle Group",
            category: .formsAndInput,
            icon: "text.aligncenter",
            description: "Attached toggle cells with single- or multi-select bindings.",
            usage: """
                SCToggleGroup(selection: $alignment, items: [
                    .init(value: "left", systemImage: "text.alignleft"),
                    .init(value: "center", systemImage: "text.aligncenter"),
                ])
                """,
            demoView: { AnyView(ToggleGroupDemo()) }
        ),

        // MARK: Display

        ComponentEntry(
            id: "accordion",
            name: "Accordion",
            category: .display,
            icon: "chevron.down.circle",
            description: "Vertically stacked headings that each reveal a section of content.",
            usage: """
                SCAccordion {
                    SCAccordionItem("Is it accessible?", content: "Yes.")
                    SCAccordionItem("Is it styled?", content: "Yes.")
                }
                """,
            demoView: { AnyView(AccordionDemo()) }
        ),
        ComponentEntry(
            id: "avatar",
            name: "Avatar",
            category: .display,
            icon: "person.crop.circle",
            description: "An async image with initials fallback, plus overlapping groups.",
            usage: """
                SCAvatar(url: URL(string: "https://github.com/shadcn.png"),
                         fallback: "CN")
                SCAvatarGroup(avatars: [(nil, "AB"), (nil, "CD")], max: 2)
                """,
            demoView: { AnyView(AvatarDemo()) }
        ),
        ComponentEntry(
            id: "badge",
            name: "Badge",
            category: .display,
            icon: "seal",
            description: "A small status pill in four variants, with a free-form content slot.",
            usage: """
                SCBadge("New")
                SCBadge("Beta", variant: .secondary)
                SCBadge(variant: .outline) { Label("Verified", systemImage: "checkmark.seal") }
                """,
            demoView: { AnyView(BadgeDemo()) }
        ),
        ComponentEntry(
            id: "card",
            name: "Card",
            category: .display,
            icon: "rectangle.inset.filled",
            description: "A themed surface composed from header, content, and footer slots.",
            usage: """
                SCCard {
                    SCCardHeader {
                        SCCardTitle("Create project")
                        SCCardDescription("Deploy your new project in one click.")
                    }
                }
                """,
            demoView: { AnyView(CardDemo()) }
        ),
        ComponentEntry(
            id: "carousel",
            name: "Carousel",
            category: .display,
            icon: "rectangle.stack",
            description: "A horizontally paging scroller with dot indicators and chevron controls.",
            usage: """
                SCCarousel(items: slides) { slide in
                    SCCard { SCCardTitle(slide.title) }
                }
                """,
            demoView: { AnyView(CarouselDemo()) }
        ),
        ComponentEntry(
            id: "chart",
            name: "Chart",
            category: .display,
            icon: "chart.bar",
            description: "Theme series palette, muted axes, and hairline grid for Swift Charts.",
            usage: """
                Chart(data) { point in
                    BarMark(x: .value("Month", point.month),
                            y: .value("Total", point.total))
                }
                .scChartStyle()
                """,
            demoView: { AnyView(ChartDemo()) }
        ),
        ComponentEntry(
            id: "attachment",
            name: "Attachment",
            category: .display,
            icon: "paperclip",
            description: "Files and images with media, metadata, upload state, actions, and a full-card trigger.",
            usage: """
                SCAttachment(state: .uploading) {
                    SCAttachmentMedia { Image(systemName: "doc.text") }
                    SCAttachmentContent {
                        SCAttachmentTitle("quarterly-report.pdf")
                        SCAttachmentDescription("Uploading · 72%")
                    }
                }
                """,
            demoView: { AnyView(AttachmentDemo()) }
        ),
        ComponentEntry(
            id: "bubble",
            name: "Bubble",
            category: .display,
            icon: "bubble.left",
            description: "The message surface: seven variants, start/end alignment, groups, and reactions.",
            usage: """
                SCBubble(variant: .muted) {
                    SCBubbleContent("Alright, let me take a look.")
                }
                .scBubbleReactions { Text("👍") }
                """,
            demoView: { AnyView(BubbleDemo()) }
        ),
        ComponentEntry(
            id: "marker",
            name: "Marker",
            category: .display,
            icon: "text.insert",
            description: "Status updates, system notes, bordered rows, and labeled separators for conversations.",
            usage: """
                SCMarker {
                    SCMarkerIcon { SCSpinner(size: 16) }
                    SCMarkerContent("Thinking…").scShimmer()
                }
                SCMarker(variant: .separator) { SCMarkerContent("Today") }
                """,
            demoView: { AnyView(MarkerDemo()) }
        ),
        ComponentEntry(
            id: "message",
            name: "Message",
            category: .display,
            icon: "bubble.left.and.bubble.right",
            description: "A conversation row: avatar, alignment, header, content, footer, and grouped messages.",
            usage: """
                SCMessage(align: .end) {
                    SCMessageAvatar { SCAvatar(url: nil, fallback: "ME", size: .sm) }
                    SCMessageContent {
                        SCBubble { SCBubbleContent("It's a one-line change.") }
                        SCMessageFooter { Text("Delivered") }
                    }
                }
                """,
            demoView: { AnyView(MessageDemo()) }
        ),
        ComponentEntry(
            id: "message-scroller",
            name: "Message Scroller",
            category: .display,
            icon: "arrow.up.arrow.down.square",
            description: "The conversation viewport: anchored turns, streaming follow, history, and scroll controls.",
            usage: """
                SCMessageScroller {
                    SCMessageScrollerViewport {
                        SCMessageScrollerContent {
                            SCMessageScrollerItem(messageId: id, scrollAnchor: true) { SCMessage { … } }
                        }
                    }
                    SCMessageScrollerButton()
                }
                """,
            demoView: { AnyView(MessageScrollerDemo()) }
        ),
        ComponentEntry(
            id: "response",
            name: "Response",
            category: .display,
            icon: "doc.richtext",
            description: "Markdown rendering for AI responses, theme-mapped via MarkdownUI.",
            usage: """
                SCResponse("**Hello!** How can I help you today?")
                SCResponse(message.markdown)  // headings, lists, code, tables, …
                """,
            demoView: { AnyView(ResponseDemo()) }
        ),
        ComponentEntry(
            id: "collapsible",
            name: "Collapsible",
            category: .display,
            icon: "rectangle.expand.vertical",
            description: "An interactive panel that expands and collapses, controlled or not.",
            usage: """
                SCCollapsible {
                    Text("@peduarte starred 3 repositories")
                } content: {
                    Text("@radix-ui/primitives")
                }
                """,
            demoView: { AnyView(CollapsibleDemo()) }
        ),
        ComponentEntry(
            id: "empty",
            name: "Empty",
            category: .display,
            icon: "tray",
            description: "A centered empty state with icon, copy, and action slots.",
            usage: """
                SCEmpty("No results", systemImage: "magnifyingglass",
                        description: "Try adjusting your search.") {
                    Button("Clear filters") { clearFilters() }.buttonStyle(.sc(.outline))
                }
                """,
            demoView: { AnyView(EmptyDemo()) }
        ),
        ComponentEntry(
            id: "item",
            name: "Item",
            category: .display,
            icon: "list.bullet.rectangle",
            description: "A generic list row: leading media, title, description, accessory.",
            usage: """
                SCItem("Notifications", description: "Manage alert settings.") {
                    Image(systemName: "bell")
                } trailing: {
                    Image(systemName: "chevron.right")
                }
                """,
            demoView: { AnyView(ItemDemo()) }
        ),
        ComponentEntry(
            id: "kbd",
            name: "Kbd",
            category: .display,
            icon: "keyboard",
            description: "Keycap chips for displaying keyboard shortcuts.",
            usage: """
                SCKbd("⌘")
                SCKbdGroup(["⌘", "⇧", "P"])
                """,
            demoView: { AnyView(KbdDemo()) }
        ),
        ComponentEntry(
            id: "resizable",
            name: "Resizable",
            category: .display,
            icon: "rectangle.split.2x1",
            description: "A two-pane split view with a draggable divider — nestable for layouts.",
            usage: """
                SCResizableSplit(fraction: 0.3, range: 0.2...0.6) {
                    SidebarPane()
                } second: {
                    DetailPane()
                }
                """,
            demoView: { AnyView(ResizableDemo()) }
        ),
        ComponentEntry(
            id: "separator",
            name: "Separator",
            category: .display,
            icon: "minus",
            description: "A 1pt rule — horizontal, vertical, or labeled.",
            usage: """
                SCSeparator()
                SCSeparator(.vertical)
                SCSeparator(label: "or continue with")
                """,
            demoView: { AnyView(SeparatorDemo()) }
        ),
        ComponentEntry(
            id: "table",
            name: "Table",
            category: .display,
            icon: "tablecells",
            description: "A themed data grid with sortable columns, row selection, and a caption.",
            usage: """
                SCTable(rows: invoices, columns: [
                    SCTableColumn("Invoice") { $0.id },
                    SCTableColumn("Status") { $0.status },
                ], caption: "A list of your recent invoices.")
                """,
            demoView: { AnyView(TableDemo()) }
        ),
        ComponentEntry(
            id: "typography",
            name: "Typography",
            category: .display,
            icon: "textformat",
            description: "shadcn's type scale as chainable view modifiers.",
            usage: """
                Text("Taxing Laughter").scH1()
                Text("Enter your email address.").scMuted()
                Text("swift build").scInlineCode()
                """,
            demoView: { AnyView(TypographyDemo()) }
        ),

        // MARK: Feedback

        ComponentEntry(
            id: "alert",
            name: "Alert",
            category: .feedback,
            icon: "exclamationmark.triangle",
            description: "An inline callout banner — default or destructive, with slots.",
            usage: """
                SCAlert(icon: "terminal", title: "Heads up!",
                        description: "You can add components using the CLI.")
                """,
            demoView: { AnyView(AlertDemo()) }
        ),
        ComponentEntry(
            id: "progress",
            name: "Progress",
            category: .feedback,
            icon: "timelapse",
            description: "A linear progress bar for native ProgressViews, with an indeterminate sweep.",
            usage: """
                ProgressView(value: 0.6).progressViewStyle(.scLinear)
                ProgressView("Uploading…", value: 0.3).progressViewStyle(.scLinear)
                ProgressView().progressViewStyle(.scLinear)  // indeterminate
                """,
            demoView: { AnyView(ProgressDemo()) }
        ),
        ComponentEntry(
            id: "skeleton",
            name: "Skeleton",
            category: .feedback,
            icon: "rectangle.dashed",
            description: "Loading placeholders with a shimmer sweep, block or redaction based.",
            usage: """
                SCSkeleton(width: 200, height: 14)
                articleView.scSkeleton(when: isLoading)
                """,
            demoView: { AnyView(SkeletonDemo()) }
        ),
        ComponentEntry(
            id: "spinner",
            name: "Spinner",
            category: .feedback,
            icon: "rays",
            description: "An indeterminate rotating arc that fades into the primary color.",
            usage: """
                SCSpinner()
                SCSpinner(size: 32, lineWidth: 3)
                """,
            demoView: { AnyView(SpinnerDemo()) }
        ),
        ComponentEntry(
            id: "toast",
            name: "Toast",
            category: .feedback,
            icon: "bell",
            description: "Sonner-style stacked notifications dispatched from a global center.",
            usage: """
                SCToastCenter.shared.show(title: "Changes saved", variant: .success)
                // Host the stack once, near the root:
                ContentView().scToaster()
                """,
            demoView: { AnyView(ToastDemo()) }
        ),

        // MARK: Navigation

        ComponentEntry(
            id: "breadcrumb",
            name: "Breadcrumb",
            category: .navigation,
            icon: "chevron.right",
            description: "The path to the current resource, with optional middle truncation.",
            usage: """
                SCBreadcrumb(items: [
                    SCBreadcrumbItem("Home") { },
                    SCBreadcrumbItem("Components") { },
                    SCBreadcrumbItem("Breadcrumb"),
                ])
                """,
            demoView: { AnyView(BreadcrumbDemo()) }
        ),
        ComponentEntry(
            id: "command",
            name: "Command",
            category: .navigation,
            icon: "command",
            description: "A filterable, keyboard-navigable command list — inline or as a ⌘K palette.",
            usage: """
                .scCommandPalette(isPresented: $showPalette, groups: [
                    SCCommandGroup(label: "Settings", items: [
                        SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") { openProfile() },
                    ]),
                ])
                """,
            demoView: { AnyView(CommandDemo()) }
        ),
        ComponentEntry(
            id: "pagination",
            name: "Pagination",
            category: .navigation,
            icon: "123.rectangle",
            description: "Previous/next links around a windowed row of page numbers.",
            usage: """
                SCPagination(current: $page, total: 10)
                SCPagination(current: $page, total: 42, maxVisible: 9)
                """,
            demoView: { AnyView(PaginationDemo()) }
        ),
        ComponentEntry(
            id: "tabs",
            name: "Tabs",
            category: .navigation,
            icon: "square.split.2x1",
            description: "Segmented or underline tab strips with a sliding indicator — no AnyView.",
            usage: """
                SCTabs(selection: $tab, tabs: [
                    SCTabItem(value: Section.account, label: "Account"),
                    SCTabItem(value: Section.password, label: "Password"),
                ]) { tab in panel(for: tab) }
                """,
            demoView: { AnyView(TabsDemo()) }
        ),
        ComponentEntry(
            id: "sidebar",
            name: "Sidebar",
            category: .navigation,
            icon: "sidebar.leading",
            description: "The flagship: a composable, collapsible app sidebar. This app's shell is one.",
            usage: """
                SCSidebarLayout(collapsible: .icon, persistenceKey: nil) {
                    SCSidebarHeader { identity }
                    SCSidebarContent { groups }
                } detail: { mainView }
                """,
            demoView: { AnyView(SidebarComponentDemo()) }
        ),

        // MARK: Overlays

        ComponentEntry(
            id: "dialog",
            name: "Dialog",
            category: .overlays,
            icon: "rectangle.center.inset.filled",
            description: "A centered modal dialog rendered as a pure SwiftUI overlay.",
            usage: """
                .scDialog(isPresented: $showDialog) {
                    SCDialogContent {
                        SCDialogTitle("Edit profile")
                    }
                }
                """,
            demoView: { AnyView(DialogDemo()) }
        ),
        ComponentEntry(
            id: "alert-dialog",
            name: "Alert Dialog",
            category: .overlays,
            icon: "exclamationmark.bubble",
            description: "A modal confirmation that interrupts — the user must choose.",
            usage: """
                .scAlertDialog(isPresented: $showDelete,
                               title: "Delete account?",
                               message: "This action cannot be undone.",
                               confirmLabel: "Delete", role: .destructive) { delete() }
                """,
            demoView: { AnyView(AlertDialogDemo()) }
        ),
        ComponentEntry(
            id: "sheet",
            name: "Sheet",
            category: .overlays,
            icon: "sidebar.trailing",
            description: "A panel that slides in from any container edge — a slide-over.",
            usage: """
                .scSheet(isPresented: $showSettings, edge: .trailing) {
                    SCSheetContent {
                        SCSheetHeader { SCSheetTitle("Settings") }
                    }
                }
                """,
            demoView: { AnyView(SheetDemo()) }
        ),
        ComponentEntry(
            id: "drawer",
            name: "Drawer",
            category: .overlays,
            icon: "rectangle.bottomthird.inset.filled",
            description: "A vaul-style bottom drawer with drag-to-dismiss.",
            usage: """
                .scDrawer(isPresented: $showDrawer) {
                    SCDrawerContent {
                        SCDrawerHeader { SCDrawerTitle("Are you sure?") }
                    }
                }
                """,
            demoView: { AnyView(DrawerDemo()) }
        ),
        ComponentEntry(
            id: "popover",
            name: "Popover",
            category: .overlays,
            icon: "bubble.middle.top",
            description: "A themed anchored popover on the native primitive — stays a popover on iPhone.",
            usage: """
                Button("Open popover") { isPresented = true }
                    .scPopover(isPresented: $isPresented) {
                        Text("Place content for the popover here.")
                    }
                """,
            demoView: { AnyView(PopoverDemo()) }
        ),
        ComponentEntry(
            id: "tooltip",
            name: "Tooltip",
            category: .overlays,
            icon: "bubble.middle.bottom",
            description: "A small text bubble beside any view — hover on pointer, long-press on touch.",
            usage: """
                SCTooltip("Add to library") {
                    Button("Add to library") { addToLibrary() }
                        .buttonStyle(.sc(.outline))
                }
                """,
            demoView: { AnyView(TooltipDemo()) }
        ),
        ComponentEntry(
            id: "hover-card",
            name: "Hover Card",
            category: .overlays,
            icon: "rectangle.on.rectangle",
            description: "A rich preview card in a native popover — hover to open, long-press on touch.",
            usage: """
                Text("@swiftcn")
                    .scHoverCard {
                        Text("shadcn/ui for SwiftUI — themed by design tokens.")
                    }
                """,
            demoView: { AnyView(HoverCardDemo()) }
        ),

        // MARK: Extended official component coverage

        ComponentEntry(
            id: "aspect-ratio",
            name: "Aspect Ratio",
            category: .display,
            icon: "rectangle",
            description: "Constrains arbitrary content to a stable width-to-height ratio.",
            usage: "SCAspectRatio(ratio: 16 / 9) { mediaView }",
            demoView: { AnyView(AspectRatioDemo()) }
        ),
        ComponentEntry(
            id: "context-menu",
            name: "Context Menu",
            category: .overlays,
            icon: "cursorarrow.click.2",
            description: "Composable right-click and long-press actions, checks, radios, and submenus.",
            usage: "SCContextMenu { content } content: { SCContextMenuItem(\"Copy\") { copy() } }",
            demoView: { AnyView(ContextMenuDemo()) }
        ),
        ComponentEntry(
            id: "data-table",
            name: "Data Table",
            category: .display,
            icon: "tablecells",
            description: "A sortable, searchable, paginated table with caller-defined columns.",
            usage: "SCDataTable(rows: rows, columns: columns, controller: controller)",
            demoView: { AnyView(DataTableDemo()) }
        ),
        ComponentEntry(
            id: "direction",
            name: "Direction",
            category: .navigation,
            icon: "textformat.characters.arrow.left.and.right",
            description: "Scopes left-to-right or right-to-left layout and exposes the current direction.",
            usage: "SCDirectionProvider(.rtl) { arabicInterface }",
            demoView: { AnyView(DirectionDemo()) }
        ),
        ComponentEntry(
            id: "dropdown-menu",
            name: "Dropdown Menu",
            category: .overlays,
            icon: "list.bullet.rectangle",
            description: "A composable menu with groups, checks, radios, submenus, and destructive actions.",
            usage: "SCDropdownMenu { trigger } content: { SCDropdownMenuContent { items } }",
            demoView: { AnyView(DropdownMenuDemo()) }
        ),
        ComponentEntry(
            id: "input-group",
            name: "Input Group",
            category: .formsAndInput,
            icon: "rectangle.and.text.magnifyingglass",
            description: "Inputs, textareas, addons, labels, and actions sharing one focus-aware control.",
            usage: "SCInputGroup { SCInputGroupInput(\"Search\", text: $query); addon }",
            demoView: { AnyView(InputGroupDemo()) }
        ),
        ComponentEntry(
            id: "menubar",
            name: "Menubar",
            category: .navigation,
            icon: "menubar.rectangle",
            description: "A desktop-ready menu bar with nested, checked, radio, and keyboard actions.",
            usage: "SCMenubar { SCMenubarMenu { trigger } content: { menuItems } }",
            demoView: { AnyView(MenubarDemo()) }
        ),
        ComponentEntry(
            id: "native-select",
            name: "Native Select",
            category: .formsAndInput,
            icon: "chevron.up.chevron.down.square",
            description: "A platform-native picker with options, groups, disabled values, and validation.",
            usage: "SCNativeSelect(selection: $food) { SCNativeSelectOption(\"Apple\", value: .apple) }",
            demoView: { AnyView(NativeSelectDemo()) }
        ),
        ComponentEntry(
            id: "navigation-menu",
            name: "Navigation Menu",
            category: .navigation,
            icon: "rectangle.3.group.bubble",
            description: "A controlled application navigation menu with anchored composable panels.",
            usage: "SCNavigationMenu(value: $openItem) { SCNavigationMenuList { items } }",
            demoView: { AnyView(NavigationMenuDemo()) }
        ),
        ComponentEntry(
            id: "scroll-area",
            name: "Scroll Area",
            category: .display,
            icon: "scroll",
            description: "A themed scroll container with configurable native scrollbars.",
            usage: "SCScrollArea(isBordered: true) { longContent }",
            demoView: { AnyView(ScrollAreaDemo()) }
        ),
        ComponentEntry(
            id: "sonner",
            name: "Sonner",
            category: .feedback,
            icon: "bell.and.waves.left.and.right",
            description: "The current toast API, including action, loading, and promise lifecycles.",
            usage: "SCSonner.show(\"Saved\"); root.scSonnerToaster()",
            demoView: { AnyView(SonnerDemo()) }
        ),

        // Searchable usage snippets stay on one line in this registry.
        // swiftlint:disable line_length

        // MARK: Blocks

        ComponentEntry(
            id: "dashboard-01",
            name: "Dashboard 01",
            category: .blocks,
            icon: "rectangle.3.group",
            description:
                "The complete shadcn dashboard shell with real navigation, chart, table, editing, and account actions.",
            usage: "SCDashboard01Block(onAction: handleDashboardAction)",
            demoView: { AnyView(DashboardBlockDemo()) }
        ),
        ComponentEntry(
            id: "login-01",
            name: "Login 01",
            category: .blocks,
            icon: "person.badge.key",
            description: "The shadcn login-01 card with email, password, recovery, Google, and sign-up actions.",
            usage: """
                    SCLoginBlock(
                        onSubmit: { email, password in signIn(email, password) },
                        onForgotPassword: resetPassword,
                        onSignUp: showSignUp,
                        onGoogle: signInWithGoogle
                    )
                """,
            demoView: { AnyView(LoginBlockDemo()) }
        ),
        ComponentEntry(
            id: "login-02",
            name: "Login 02",
            category: .blocks,
            icon: "rectangle.split.2x1",
            description:
                "A split login screen with functional credentials, recovery, GitHub, sign-up, and replaceable media.",
            usage: "SCLogin02Block(onSubmit: signIn, onForgotPassword: reset, onGitHub: github, onSignUp: signUp)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "login-02")) }
        ),
        ComponentEntry(
            id: "login-03",
            name: "Login 03",
            category: .blocks,
            icon: "rectangle.center.inset.filled",
            description: "A centered branded login card with Apple, Google, terms, privacy, and account navigation.",
            usage:
                "SCLogin03Block(onSubmit: signIn, onForgotPassword: reset, onApple: apple, onGoogle: google, onSignUp: signUp, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "login-03")) }
        ),
        ComponentEntry(
            id: "login-04",
            name: "Login 04",
            category: .blocks,
            icon: "rectangle.split.2x1.fill",
            description: "A wide split-card login with Apple, Google, Meta, legal links, and replaceable media.",
            usage:
                "SCLogin04Block(onSubmit: signIn, onForgotPassword: reset, onApple: apple, onGoogle: google, onMeta: meta, onSignUp: signUp, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "login-04")) }
        ),
        ComponentEntry(
            id: "login-05",
            name: "Login 05",
            category: .blocks,
            icon: "envelope.badge.person.crop",
            description: "An email-first login flow with social providers, sign-up, terms, and privacy actions.",
            usage:
                "SCLogin05Block(onSubmit: requestLogin, onApple: apple, onGoogle: google, onSignUp: signUp, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "login-05")) }
        ),
        ComponentEntry(
            id: "signup-01",
            name: "Signup 01",
            category: .blocks,
            icon: "person.crop.circle.badge.plus",
            description: "The shadcn signup-01 form with validated account details, Google, and sign-in navigation.",
            usage: "SCSignup01Block(onSubmit: createAccount, onGoogle: google, onSignIn: signIn)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "signup-01")) }
        ),
        ComponentEntry(
            id: "signup-02",
            name: "Signup 02",
            category: .blocks,
            icon: "rectangle.split.2x1",
            description: "A split signup screen with account validation, GitHub, sign-in, and replaceable media.",
            usage: "SCSignup02Block(onSubmit: createAccount, onGitHub: github, onSignIn: signIn)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "signup-02")) }
        ),
        ComponentEntry(
            id: "signup-03",
            name: "Signup 03",
            category: .blocks,
            icon: "person.text.rectangle",
            description: "A centered branded signup card with account validation and legal navigation.",
            usage: "SCSignup03Block(onSubmit: createAccount, onSignIn: signIn, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "signup-03")) }
        ),
        ComponentEntry(
            id: "signup-04",
            name: "Signup 04",
            category: .blocks,
            icon: "rectangle.split.2x1.fill",
            description: "A wide split-card signup with Apple, Google, Meta, legal links, and replaceable media.",
            usage:
                "SCSignup04Block(onSubmit: createAccount, onApple: apple, onGoogle: google, onMeta: meta, onSignIn: signIn, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "signup-04")) }
        ),
        ComponentEntry(
            id: "signup-05",
            name: "Signup 05",
            category: .blocks,
            icon: "envelope.badge.person.crop",
            description: "An email-first signup flow with social providers, sign-in, terms, and privacy actions.",
            usage:
                "SCSignup05Block(onSubmit: createAccount, onApple: apple, onGoogle: google, onSignIn: signIn, onTerms: terms, onPrivacy: privacy)",
            demoView: { AnyView(OfficialAuthBlockDemo(blockID: "signup-05")) }
        ),
        ComponentEntry(
            id: "sidebar-01",
            name: "Sidebar 01",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "Documentation navigation with version switching, search, grouped links, breadcrumbs, and off-canvas collapse.",
            usage: "SCSidebar01Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-01")) }
        ),
        ComponentEntry(
            id: "sidebar-02",
            name: "Sidebar 02",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "The second documentation layout with controlled version, search, selection, and real navigation actions.",
            usage: "SCSidebar02Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-02")) }
        ),
        ComponentEntry(
            id: "sidebar-03",
            name: "Sidebar 03",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "A documentation sidebar with expandable submenus, controlled selection, breadcrumbs, and off-canvas collapse.",
            usage: "SCSidebar03Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-03")) }
        ),
        ComponentEntry(
            id: "sidebar-04",
            name: "Sidebar 04",
            category: .blocks,
            icon: "sidebar.left",
            description: "A flush submenu documentation layout with genuine disclosure and selection state.",
            usage: "SCSidebar04Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-04")) }
        ),
        ComponentEntry(
            id: "sidebar-05",
            name: "Sidebar 05",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "A searchable inset documentation sidebar with controlled navigation and functional breadcrumbs.",
            usage: "SCSidebar05Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-05")) }
        ),
        ComponentEntry(
            id: "sidebar-07",
            name: "Sidebar 07",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "The complete application sidebar with team switching, nested navigation, projects, account actions, and icon collapse.",
            usage: "SCSidebarBlock(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(SidebarBlockDemo()) }
        ),
        ComponentEntry(
            id: "sidebar-08",
            name: "Sidebar 08",
            category: .blocks,
            icon: "sidebar.left",
            description:
                "An organization application sidebar with functional navigation, projects, account actions, and off-canvas collapse.",
            usage: "SCSidebar08Block(onAction: handleSidebarAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-08")) }
        ),
        ComponentEntry(
            id: "sidebar-09",
            name: "Sidebar 09",
            category: .blocks,
            icon: "envelope.badge",
            description:
                "A mail workspace with nested folders, search, unread filtering, message selection, and icon collapse.",
            usage: "SCSidebar09Block(onAction: handleMailAction) { folderID, mailID in mailDetail(folderID, mailID) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-09")) }
        ),
        ComponentEntry(
            id: "sidebar-10",
            name: "Sidebar 10",
            category: .blocks,
            icon: "square.grid.2x2",
            description:
                "A workspace sidebar with team switching, favorites, nested pages, actions, and caller-owned detail content.",
            usage: "SCSidebar10Block(onAction: handleWorkspaceAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-10")) }
        ),
        ComponentEntry(
            id: "sidebar-11",
            name: "Sidebar 11",
            category: .blocks,
            icon: "folder.badge.gearshape",
            description:
                "A source-control file tree with changes, expandable folders, selection, actions, and caller-owned file detail.",
            usage: "SCSidebar11Block(onAction: handleFileAction) { selection in fileDetail(selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-11")) }
        ),
        ComponentEntry(
            id: "sidebar-12",
            name: "Sidebar 12",
            category: .blocks,
            icon: "calendar",
            description:
                "A calendar workspace with month navigation, date selection, calendar groups, toggles, creation, and account actions.",
            usage:
                "SCSidebar12Block(onAction: handleCalendarAction) { date, calendars in calendarDetail(date, calendars) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-12")) }
        ),
        ComponentEntry(
            id: "sidebar-13",
            name: "Sidebar 13",
            category: .blocks,
            icon: "gearshape",
            description:
                "A responsive settings dialog with the complete navigation set, controlled presentation, and caller-owned panes.",
            usage: "SCSidebar13Block(onAction: handleSettingsAction) { selection in settingsPane(selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-13")) }
        ),
        ComponentEntry(
            id: "sidebar-14",
            name: "Sidebar 14",
            category: .blocks,
            icon: "sidebar.right",
            description:
                "A right-side table of contents with every upstream section, controlled selection, and real breadcrumbs.",
            usage: "SCSidebar14Block(onAction: handlePageAction) { selection in documentationPage(selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-14")) }
        ),
        ComponentEntry(
            id: "sidebar-15",
            name: "Sidebar 15",
            category: .blocks,
            icon: "rectangle.split.3x1",
            description:
                "The dual-sidebar composition combining the complete workspace and calendar systems around caller-owned content.",
            usage:
                "SCSidebar15Block(onAction: handleWorkspaceAction) { selection, date, calendars in workspace(selection, date, calendars) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-15")) }
        ),
        ComponentEntry(
            id: "sidebar-16",
            name: "Sidebar 16",
            category: .blocks,
            icon: "rectangle.topthird.inset.filled",
            description:
                "A persistent searchable site header sharing collapse state with a fully functional application sidebar.",
            usage: "SCSidebar16Block(onAction: handleAppAction) { selection in destination(for: selection) }",
            demoView: { AnyView(OfficialSidebarBlockDemo(blockID: "sidebar-16")) }
        ),
        ComponentEntry(
            id: "settings-block",
            name: "Settings (Swiftcn)",
            category: .blocks,
            icon: "gearshape",
            description:
                "A Swiftcn-specific grouped settings screen retained outside the official shadcn block catalog.",
            usage: "SCSettingsBlock(onEditProfile: editProfile, onDeleteAccount: confirmAccountDeletion)",
            demoView: { AnyView(SettingsBlockDemo()) }
        ),

        // swiftlint:enable line_length

        // MARK: Effects

        ComponentEntry(
            id: "aurora",
            name: "Aurora",
            category: .effects,
            icon: "sun.haze",
            description: "A soft, slowly drifting color wash of blurred theme-tinted blobs.",
            usage: """
                ZStack {
                    SCAuroraBackground()
                    heroContent
                }
                """,
            demoView: { AnyView(AuroraDemo()) }
        ),
        ComponentEntry(
            id: "dot-pattern",
            name: "Dot Pattern",
            category: .effects,
            icon: "circle.grid.3x3",
            description: "A Canvas-drawn dotted background with an optional radial fade.",
            usage: """
                ZStack {
                    SCDotPattern(fade: true)
                    heroContent
                }
                """,
            demoView: { AnyView(DotPatternDemo()) }
        ),
        ComponentEntry(
            id: "marquee",
            name: "Marquee",
            category: .effects,
            icon: "arrow.left.arrow.right",
            description: "Scrolls content in an endless horizontal loop, fading at the edges.",
            usage: """
                SCMarquee {
                    HStack(spacing: 32) {
                        ForEach(stack, id: \\.self) { SCBadge($0, variant: .secondary) }
                    }
                }
                """,
            demoView: { AnyView(MarqueeDemo()) }
        ),
        ComponentEntry(
            id: "number-ticker",
            name: "Number Ticker",
            category: .effects,
            icon: "number",
            description: "Rolls each digit into place when a numeric value changes.",
            usage: """
                SCNumberTicker(value: downloads)
                    .scH2()
                SCNumberTicker(value: revenue, format: .number.precision(.fractionLength(2)))
                """,
            demoView: { AnyView(NumberTickerDemo()) }
        ),
        ComponentEntry(
            id: "scroll-fade",
            name: "Scroll Fade",
            category: .effects,
            icon: "square.fill.and.line.vertical.and.square",
            description: "Scroll-aware edge fades for scroll containers — the scroll-fade utility.",
            usage: """
                ScrollView { transcript }.scScrollFade()
                ScrollView(.horizontal) { chips }.scScrollFade(.horizontal)
                """,
            demoView: { AnyView(ScrollFadeDemo()) }
        ),
        ComponentEntry(
            id: "shimmer",
            name: "Shimmer",
            category: .effects,
            icon: "sparkles",
            description: "A text shimmer for live status — the shimmer utility, masked to any shape.",
            usage: """
                SCMarkerContent("Thinking…").scShimmer()
                Text("Introducing swiftcn 2.0").scShimmer(duration: 3)
                """,
            demoView: { AnyView(ShimmerDemo()) }
        ),
        ComponentEntry(
            id: "shimmer-button",
            name: "Shimmer Button",
            category: .effects,
            icon: "button.programmable",
            description: "A call-to-action whose border a highlight endlessly laps.",
            usage: """
                SCShimmerButton(text: "Get Started") { start() }
                """,
            demoView: { AnyView(ShimmerButtonDemo()) }
        ),
    ]
}

// MARK: - Audio entries

extension Catalog {
    @MainActor fileprivate static let audioEntries: [ComponentEntry] = [
        ComponentEntry(
            id: "live-waveform",
            name: "Live Waveform",
            category: .audio,
            icon: "waveform",
            description: "A real-time audio waveform with static, scrolling, processing, and idle states.",
            usage: """
                SCLiveWaveform(active: isRecording, levels: microphoneLevels)
                SCLiveWaveform(processing: isTranscribing)
                SCLiveWaveform(active: true, levels: engine, mode: .scrolling)
                """,
            demoView: { AnyView(LiveWaveformDemo()) }
        ),
        ComponentEntry(
            id: "bar-visualizer",
            name: "Bar Visualizer",
            category: .audio,
            icon: "chart.bar.fill",
            description: "A frequency-band visualizer with sequenced highlights for five voice-agent states.",
            usage: """
                SCBarVisualizer(state: .listening, levels: microphoneLevels)
                SCBarVisualizer(state: .speaking, barCount: 20, demo: true)
                """,
            demoView: { AnyView(BarVisualizerDemo()) }
        ),
        ComponentEntry(
            id: "speech-input",
            name: "Speech Input",
            category: .audio,
            icon: "mic",
            description: "A mic button that expands into a recording bar with cancel, live preview, and stop.",
            usage: """
                SCSpeechInput(session: scribeSession, onChange: { draft = $0.transcript }) {
                    SCSpeechInputCancelButton()
                    SCSpeechInputPreview()
                    SCSpeechInputRecordButton()
                }
                """,
            demoView: { AnyView(SpeechInputDemo()) }
        ),
        ComponentEntry(
            id: "scrub-bar",
            name: "Scrub Bar",
            category: .audio,
            icon: "slider.horizontal.3",
            description: "A compound playback scrubber with a draggable track, progress, thumb, and time labels.",
            usage: """
                SCScrubBarContainer(duration: duration, value: currentTime, onScrub: seek) {
                    SCScrubBarTrack {
                        SCScrubBarProgress()
                        SCScrubBarThumb()
                    }
                }
                """,
            demoView: { AnyView(ScrubBarDemo()) }
        ),
        ComponentEntry(
            id: "transcript-viewer",
            name: "Transcript Viewer",
            category: .audio,
            icon: "captions.bubble",
            description: "A time-synced transcript whose words follow an injected playback clock.",
            usage: """
                SCTranscriptViewerContainer(player: player, alignment: alignment) {
                    SCTranscriptViewerWords()
                    SCTranscriptViewerScrubBar()
                    SCTranscriptViewerPlayPauseButton()
                }
                """,
            demoView: { AnyView(TranscriptViewerDemo()) }
        ),
        ComponentEntry(
            id: "waveform",
            name: "Waveform",
            category: .audio,
            icon: "waveform.path",
            description: "Static, scrolling, microphone, recording, and seekable audio waveforms.",
            usage: """
                SCWaveform(data: amplitudes)
                SCAudioScrubber(data: amplitudes, currentTime: time, duration: duration, onSeek: seek)
                """,
            demoView: { AnyView(WaveformDemo()) }
        ),
    ]
}
