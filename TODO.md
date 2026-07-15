# TODO

This is the only project work list.

## The two gates

Every Theme, component, effect, and block has two independent checkboxes.
Neither checkbox is implied by the other.

### `CODE`

Check `CODE` only after an agent has completed an item-by-item source audit:

1. Read the current official shadcn documentation, composition tree, examples,
   and upstream source for that exact item.
2. Read the complete Swift production implementation, not just its filename,
   registry entry, preview, or symbol list.
3. Compare every meaningful upstream part, public API, state path, action, and
   composition rule with the Swift implementation.
4. Confirm state and actions are real and caller-controllable. Decorative or
   no-op controls fail the gate.
5. Confirm the API is reusable outside the Showcase and the registry declares
   the complete source/dependency set.
6. Record intentional macOS/iPadOS adaptations in the item note.

A source file existing does not pass `CODE`. `registry.json`,
`parity/shadcn.json`, and `scripts/check_shadcn_parity.py` are inventory and
consistency tools only. They cannot check a `CODE` box.

### `VALIDATION`

Check `VALIDATION` only after the accepted code has been compiled and exercised
in real macOS and iPadOS host applications. The item must receive the relevant
keyboard, focus, pointer, touch, accessibility, resizing, dismissal, state,
XCUITest, screenshot, latency, and performance checks.

There are no unit-test targets in this project. Validation means host-app,
XCUITest, accessibility, snapshot, and performance evidence.

Usage examples and previews are useful ways to inspect code, but they are not a
third completion gate and they do not pass either checkbox.

## Work next

- Component source cursors have met: all **64** current official component
  concepts have completed the item-by-item `CODE` source pass.
- Accepted in the forward source pass: **Accordion through Spinner** in official order.
- Accepted in the reverse source pass: **Typography**, **Toggle Group**, **Toggle**, **Toast**, **Textarea**, **Tabs**, **Table**, and **Switch**;
  **Tooltip** was already accepted.
- Block source cursors have met: all **26** blocks in the current official
  catalog have completed the item-by-item `CODE` source pass.
- Next: audit Theme, then build the macOS and iPadOS validation hosts and work
  through the still-independent `VALIDATION` checkboxes.

## Repository and validation infrastructure

- [x] Root Swift package exposes the reusable `Swiftcn` library.
- [x] Library platform floor is macOS 14 and iOS/iPadOS 17.
- [x] macOS Showcase is isolated in its own macOS-only package.
- [x] Official `swift format` and unpinned strict SwiftLint are configured.
- [x] Legacy v1 material is under `Archive/`.
- [x] `registry.json` is generated from the current local source tree (109 items
      at the 2026-07-14 check).
- [x] The parity ledger accounts for all 64 current official component concepts
      and 26 currently listed upstream blocks.
- [x] Run the configured official registry-schema CI gate on the latest tree.
- [ ] Replace or backstop regex-inferred registry dependencies with an explicit
      per-item contract or copied-source consumer compile gate.
- [x] Make the root library pass a Swift 6 complete-concurrency build with
      compiler warnings treated as errors, then add that command to CI. The
      root gate passed on 2026-07-14 after resolving all 23 audited error sites;
      the production source tree is also free of unchecked concurrency escape
      hatches, enforced by `scripts/check_concurrency_annotations.py`. TimberVox
      still provides the strict copied-source consumer gate.
- [ ] Automate upstream catalog drift detection; the catalog date is currently manual.
- [ ] Create the macOS XCUITest host.
- [ ] Create the iPadOS XCUITest host.
- [ ] Create the screenshot/snapshot harness for both platforms.
- [ ] Publish a versioned CLI and test installation outside this checkout.
- [ ] Publish the private canonical repository and correct package/registry URLs.
- [ ] Test source copying in real synchronized-folder Xcode projects.

## Theme

- **Theme tokens, default zinc preset, palette, adaptive colors, and environment injection**
  - [ ] `CODE` — source exists; no complete item-by-item Theme audit has been accepted.
  - [ ] `VALIDATION` — light/dark, contrast, Dynamic Type, environment override,
        macOS, and iPadOS validation not completed.

## Official components

This is one unsegmented list in the exact order shown by the current official
shadcn component catalog. “Source exists” describes inventory only; it is not
`CODE` approval.

- **Accordion**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Accordion:
        Root/Item/Trigger/Content composition, arbitrary slots, controlled or
        internal state, defaults, single/multiple/collapsible modes, disabling,
        callback, and reduced motion are implemented. Native adaptation:
        SwiftUI environment state and `Button` replace Base UI context/primitives.
  - [ ] `VALIDATION` — single/multiple state, keyboard, accessibility, macOS, and iPadOS not validated.
- **Alert**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Alert:
        Root/Title/Description/Action, arbitrary content and leading slots, and
        default/destructive variants are implemented. Native adaptation:
        SwiftUI accessibility containment replaces the web alert element;
        live-announcement behavior remains a `VALIDATION` concern.
  - [ ] `VALIDATION` — variants, arbitrary slots, Dynamic Type, and accessibility not validated.
- **Alert Dialog**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Alert Dialog:
        Root/Trigger/Overlay/Content/Header/Footer/Media/Title/Description/Action/Cancel,
        sizes, controlled presentation, non-dismissible backdrop, arbitrary
        slots, and real cancel/confirm callbacks are implemented. Native
        adaptation: the SwiftUI root overlay owns web Portal behavior.
  - [ ] `VALIDATION` — focus entry/return, Escape, cancel, confirmation, keyboard, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox presented the destructive
        delete dialog, exposed its title/message/actions through accessibility,
        and cancelled back to the expanded History card without deleting data.
- **Aspect Ratio**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Aspect Ratio:
        required positive finite ratio, arbitrary content, alignment, full-size
        overlay content, clipping, and no unnecessary production dependencies.
  - [ ] `VALIDATION` — sizing under different parent proposals, clipping,
        resizing, macOS, and iPadOS not validated.
- **Attachment**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Attachment source:
        Root/Group/Media/Content/Title/Description/Actions/Action/Trigger,
        idle/uploading/processing/error/done states, three sizes, horizontal and
        vertical layouts, arbitrary slots, real caller-owned actions, and the
        full-card trigger are implemented. Native adaptations: a native Button
        wrapper replaces the absolute web trigger, and view-aligned ScrollView
        plus `ScrollFade` replaces CSS snap and scroll-fade utilities.
  - [ ] `VALIDATION` — activation, state styling, scrolling, long content,
        disabled actions, macOS, iPadOS, and accessibility not validated.
- **Avatar**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Avatar source and API:
        Root/Image/Fallback/Badge/Group/GroupCount are independently composable;
        sm/default/lg sizes, idle/loading/loaded/error state, delayed arbitrary
        fallback content, load callbacks, arbitrary badges, group counts, and
        the original URL/initials convenience API are implemented. Native
        adaptation: `AsyncImage` and a root-scoped SwiftUI environment binding
        replace the web image element and Base UI loading context.
  - [ ] `VALIDATION` — loading, failure, fallback delay, grouping, badge layout,
        macOS, iPadOS, and accessibility not validated.
- **Badge**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Badge source and examples:
        all six variants, arbitrary inline content, invalid styling, custom color
        escape hatches, hover/pressed/disabled states, and reusable native
        Button/Link styling are implemented. Native adaptation: `ViewModifier`
        and `ButtonStyle` replace Base UI's render-prop element substitution so
        the caller's native control continues to own activation and semantics.
  - [ ] `VALIDATION` — variants, Button/Link keyboard activation, focus ring,
        invalid state, Dynamic Type, macOS, iPadOS, and accessibility not validated.
- **Breadcrumb**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Breadcrumb source:
        Root/List/Item/Link/Page/Separator/Ellipsis are independently composable;
        arbitrary slots, real action and URL links, caller-owned native navigation
        styling, current-page semantics, custom separators, accessible ellipsis,
        wrapping, RTL placement, and the original collapsing array convenience are
        implemented. Native adaptation: a SwiftUI `Layout` replaces flex wrapping.
  - [ ] `VALIDATION` — action/URL/navigation activation, wrapping, collapsed items,
        RTL, Dynamic Type, macOS, iPadOS, and accessibility not validated.
- **Bubble**
  - [x] `CODE` — accepted 2026-07-14 against the current official Bubble source:
        Group/Root/Content/Reactions are public and composable; all seven
        variants, start/end alignment, grouped bubbles, width capping, arbitrary
        content, reaction side/alignment, accessible reactions, custom colors,
        and native Button/Link content styling are implemented. Native
        adaptations: an environment value replaces variant data attributes,
        a SwiftUI `Layout` caps width, and an overlay modifier positions reactions.
  - [ ] `VALIDATION` — variants, Button/Link activation, alignment, grouping,
        reactions, long content, selection, macOS, iPadOS, and accessibility not validated.
- **Button**
  - [x] `CODE` — audited against the current official docs and registry source.
        `SCButtonStyle` covers all six variants and eight sizes on native
        SwiftUI `Button`, including hover, pressed, focus-ring, and disabled
        styling. Native labels own icon/loading composition; native controls
        retain action, role, keyboard, link, and accessibility semantics.
  - [ ] `VALIDATION` — the copied source compiles in TimberVox, and the real
        History detail back action has been visually inspected, retains its
        accessibility label, and navigates correctly with the ghost/icon-small
        style. All variants and sizes, pointer transitions, pressed and focus
        states, disabled/loading composition, Dynamic Type, VoiceOver, and
        iPadOS remain incomplete.
- **Button Group**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Button Group source
        and examples: Root/Text/Separator, horizontal/vertical orientation,
        arbitrary Buttons/Inputs/Selects/text/separators/nested groups, reusable
        text styling, group labels, disabled controls, and the array convenience
        are implemented. Compatibility items require real actions. Native
        adaptations: one-point layout overlap and shared group context replace
        CSS sibling selectors; a SwiftUI `Layout` stretches vertical children.
  - [ ] `VALIDATION` — mixed controls, nested groups, horizontal/vertical sizing,
        keyboard, disabled state, focus, macOS, iPadOS, and accessibility not validated.
- **Calendar**
  - [x] `CODE` — accepted 2026-07-14 against the current Calendar wrapper and
        official examples: single/multiple/range bindings, public custom day
        state and DayButton, controlled/internal month ownership, bounds and
        disabled dates, outside days, fixed weeks, week numbers, multiple
        months, four caption layouts, configurable navigation variant,
        locale/calendar-derived labels, optional deselection, and macOS arrow
        focus are implemented. Native adaptation: Foundation `Calendar`,
        SwiftUI bindings/focus, and typed configuration replace react-day-picker.
  - [ ] `VALIDATION` — all selection modes, range edges, controlled navigation,
        dropdowns, multiple months, custom days, locale/RTL, keyboard, VoiceOver,
        edge dates, macOS, and iPadOS not validated.
- **Card**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Card source:
        Root/Header/Title/Description/Action/Content/Footer, default/small sizes,
        arbitrary title and description content, per-region insets, arbitrary
        content/footer slots, and automatic top-trailing header action placement
        are implemented. Native adaptation: a SwiftUI `Layout` replaces the
        header's CSS grid and recognizes the Action through a layout value.
  - [ ] `VALIDATION` — action placement, long and arbitrary slots, region insets,
        Dynamic Type, RTL, macOS, iPadOS, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox exercised small Cards for
        Home statistics, Today, collapsed/expanded History records, and the
        recording-information panels. The History Card Footer remained the last
        region below playback, mode, and action content after expansion.
- **Carousel**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Carousel source:
        Root/Content/Item/Previous/Next, horizontal/vertical orientation,
        externally owned observable API state, programmatic scroll commands,
        selection callbacks, plugin lifecycle, snapping, multiple visible items,
        custom controls, disabled boundaries, keyboard arrows, adjustable
        accessibility, wrapped programmatic navigation, and the original data
        convenience are implemented. Native adaptation: SwiftUI ScrollView,
        environment state, and ID preferences replace Embla/context/hooks.
  - [ ] `VALIDATION` — pointer/touch dragging, snapping, external commands,
        plugin lifecycle, horizontal/vertical layout, keyboard, wrapped controls,
        reduced motion, macOS, iPadOS, and accessibility not validated.
- **Chart**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Chart source:
        ordered per-series configuration, adaptive colors, arbitrary labels and
        icons, shared container environment, semantic axes, real x-selection and
        overlay positioning, active/empty tooltip suppression, dot/line/dashed
        indicators, hide/color/format options, payload-to-config lookup, and
        configurable legend content are implemented. Native adaptation: Swift
        Charts, typed environment configuration, `chartXSelection`, and
        `ChartProxy` replace Recharts, React context, CSS variables, and DOM
        tooltip/legend primitives.
  - [ ] `VALIDATION` — axes, legends, selection, empty data, Dynamic Type, and VoiceOver not validated.
- **Checkbox**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Checkbox source:
        controlled checked/unchecked/mixed state, mixed-state activation,
        arbitrary label and indicator slots, unlabeled field/table composition,
        invalid and disabled styling, keyboard activation, native Toggle
        accessibility representation, Boolean binding convenience, and the
        existing `ToggleStyle` API are implemented. Native adaptation: one typed
        three-state binding replaces separate React checked/indeterminate props;
        SwiftUI environment state and accessibility representation replace DOM
        disabled/form semantics.
  - [ ] `VALIDATION` — native semantics, keyboard, touch target, and accessibility not validated.
- **Collapsible**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Collapsible:
        independently composable Root/Trigger/Content, controlled and
        uncontrolled state, default-open state, open-change callback, disabled
        interaction, state-aware builders, optional keep-mounted content,
        expanded/collapsed accessibility values, animation, reduced-motion
        suppression, and a bundled convenience are implemented. Native
        adaptation: typed environment bindings and SwiftUI Button/builders
        replace React context, data attributes, and render props; browser
        hidden-until-found has no native app equivalent.
  - [ ] `VALIDATION` — keyboard, animation, reduced motion, and accessibility not validated.
- **Combobox**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Combobox source:
        typed caller-owned single/multiple selection, controlled or uncontrolled
        query and presentation, callbacks, item-to-string synchronization,
        independently composable Input/Trigger/Value/Clear/Content/List/Item/
        Group/Label/Collection/Empty/Separator/Chips/Chip/ChipsInput, grouped and
        custom filtering, disabled rows, auto/pointer highlight, cyclic arrows,
        Return selection, Escape dismissal, invalid state, arrowless anchored
        content, wrapping chips, real removal/clear actions, and a thin
        preassembled view over the same primitive engine are implemented. Native adaptation: SwiftUI
        bindings/environment, an AppKit overlay portal on macOS, ViewBuilder
        data collections, SF Symbols, and a native Layout replace Base context,
        DOM portal/positioner/anchor refs,
        React render functions, DOM icons, and flexbox.
  - [ ] `VALIDATION` — arrows, Enter, touch, dismissal, focus return, VoiceOver, and large data not validated.
- **Command**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Command source:
        controlled/uncontrolled query, composable Root/Input/Results/Empty/
        Group/Item/Shortcut/Separator, arbitrary typed data collections,
        custom filtering and rendering, disabled-item exclusion, auto/pointer
        highlight, cyclic arrows, Return execution, scroll tracking, checked
        items, reusable modal content, title/description semantics, optional
        close control, scrim/Escape dismissal, and dismiss-before-execute palette
        behavior are implemented. `SCCommandCollection`, `SCCommandList`, and
        the palette are thin compositions over one state/filter/keyboard engine.
        Native adaptation: SwiftUI environment/focus/key handling and the shared
        Dialog replace cmdk context, DOM state attributes, browser events, and
        the portal.
  - [ ] `VALIDATION` — filtering, arrows, Enter, Escape, focus, VoiceOver, and large data not validated.
- **Context Menu**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Context Menu:
        arbitrary trigger/menu composition, native pointer context-click and
        touch long-press, real default/destructive/disabled actions,
        caller-controlled checkbox and radio state, tagged radio items, native
        groups/labels/separators, nested submenus, actual keyboard shortcuts,
        and system focus/placement/dismissal/accessibility are implemented.
        Native adaptation: `.contextMenu` collapses web Root/Trigger/Content/
        Portal/Positioner, `Menu` combines Sub/Trigger/Content, `Section`
        combines Group/Label, and the OS owns side/alignment. No decorative web
        wrapper equivalents were added.
  - [ ] `VALIDATION` — pointer/touch invocation, actions, disabled state, and accessibility not available until code passes.
- **Data Table**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Data Table guide:
        typed caller-owned query/sort/selection/visibility/pagination state,
        column search extractors or custom filtering, whole-dataset sorting,
        page-row mixed/select-all state, hideable columns, reusable toolbar,
        search, sortable/hideable column header, view-options and pagination
        controls, configurable page sizes, first/previous/next/last actions,
        selection summary, custom cells and row actions, custom empty content,
        optional controls, row activation, captions, and `SCTable` overflow are
        implemented. Native adaptation: an Observation controller and typed
        `SCTableColumn` comparators/search values replace TanStack state and row
        models; native Menu/Binding controls replace dropdown checkboxes. This
        preserves shadcn's headless-guide approach rather than imposing a rigid
        universal grid.
  - [ ] `VALIDATION` — complete data-table interaction flow not available until code passes.
- **Date Picker**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Date Picker guide:
        basic optional-date, two-click range, date-of-birth dropdown captions,
        constrained real presets, localized input and invalid feedback,
        caller-injected live natural-language parsing, combined date/time,
        controlled or internal presentation, controlled month, callbacks,
        bounds, disabled dates, optional dismissal, and inherited RTL are
        implemented. Matching upstream, there is no DatePicker root: custom
        callers compose the public Popover and Calendar, while every bundled
        picker is a convenience over those same engines. Native adaptations:
        SwiftUI DatePicker owns localized time editing and caller-injected parsing
        replaces the optional chrono-node dependency.
  - [ ] `VALIDATION` — locale, dismissal, keyboard, touch, and accessibility not validated.
- **Dialog**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Dialog source,
        API, and examples: controlled or internal Root, Trigger, Portal/Viewport
        presentation layer, arbitrary Overlay, Content, Header, responsive
        Footer, arbitrary Title/Description, Close, default/custom/no-close
        controls, open callbacks, configurable scrim/Escape dismissal, inert
        underlying content, initial and restored trigger focus hooks, reduced
        motion, three widths, constrained height, inner scroll content with
        sticky header/footer composition, inherited RTL, and the modifier
        convenience all share one engine. Native adaptations: the root owns the
        container overlay instead of a DOM portal, native Buttons replace render
        props, and SwiftUI ScrollView/focus/key handling replace browser APIs.
  - [ ] `VALIDATION` — focus entry/return, Escape, outside dismissal, stacking, and VoiceOver not validated.
- **Direction**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Direction source
        and guide: explicit LTR/RTL values, arbitrary descendant provider,
        nested overrides, public environment read equivalent to `useDirection`,
        builder reader, and modifier convenience are implemented. Native
        adaptation: all APIs use SwiftUI's `layoutDirection` as the single
        backing source, so text, semantic edges, controls, and directional
        layouts receive the real platform behavior instead of a parallel flag.
  - [ ] `VALIDATION` — nested overrides, mirrored layout, directional controls,
        macOS, iPadOS, and accessibility not validated.
- **Drawer**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Drawer source,
        API, and examples: controlled or internal Root, Trigger, Overlay,
        Content, Swipe Handle, Header, Footer, arbitrary Title/Description,
        Close, four physical edges, custom sizing, modal/non-modal/focus-scoped
        modes, pointer/Escape/swipe controls, fractional and point-based snap
        points, controlled snap state, projected axis-aware dragging, sequential
        expansion/collapse, progress-linked overlay, scrollable body composition,
        focus entry/return, reduced motion, and the view modifier convenience all
        share one presentation engine. Native adaptations: the SwiftUI root owns
        Portal/Viewport/Popup placement, DragGesture replaces browser swipe
        events, GeometryReader replaces viewport CSS variables, and native
        ScrollView/safe-area behavior provides keyboard-aware layout.
  - [ ] `VALIDATION` — detents, dragging, dismissal, focus, compact adaptation, and accessibility not validated.
- **Dropdown Menu**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Dropdown Menu
        source, API, and complete example set: arbitrary Trigger/Content,
        labeled and unlabeled Group sections, Label, default/destructive and
        disabled Items, arbitrary icon labels, real keyboard Shortcuts,
        caller-bound Checkbox Items, typed caller-bound Radio Groups/Items,
        disabled choices, nested Sub/Trigger/Content, Separators, indicator
        visibility, and ordering are implemented with native SwiftUI menu
        primitives. Native adaptation: one platform `Menu` owns Root, Portal,
        Positioner, Popup, open state, placement, collision handling, dismissal,
        keyboard/pointer/touch/focus behavior, accessibility, and RTL submenu
        direction; no fake controllable-open or web-positioning API is exposed.
  - [ ] `VALIDATION` — keyboard, pointer, touch, submenu, disabled state, dismissal, and accessibility not available until code passes.
- **Empty**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Empty source and
        complete example set: arbitrary Root content, independent Header,
        default/icon Media with accessibility control, arbitrary Title and
        Description, arbitrary Content for real actions/links/inputs, adjustable
        padding/minimum height/region width/spacing, and ordinary SwiftUI
        background/border/clipping composition are implemented. The compact
        title/description/SF Symbol/actions initializer composes those same
        public parts. Native adaptations: ViewBuilder slots replace polymorphic
        HTML children, a typed enum replaces the media class-variant helper,
        SwiftUI Link/Text replace embedded anchors, and native heading and
        accessibility containment semantics are added.
  - [ ] `VALIDATION` — arbitrary content, actions, layout, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox displayed its searchable
        History `No matches` empty state and exposed the title and description.
- **Field**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Field source and
        complete form examples: arbitrary FieldSet/Legend/Group/Field/Content,
        legend and label treatments, vertical/horizontal/responsive orientation,
        caller-set breakpoint and spacing, arbitrary Label/Title/Description,
        plain or labeled Separator, custom or deduplicated Error content,
        required indicators, and compact label/control/description/error
        composition are implemented. Invalid state propagates through a public
        environment value, disabled state disables native descendants, compact
        labels become the control's accessibility label, and string errors post
        real AccessibilityNotification announcements. Native adaptations:
        accessibility containment replaces HTML fieldset/group roles,
        ViewThatFits replaces CSS container queries, native control labels
        replace detached for/id relationships, and Divider replaces the web
        Separator dependency.
  - [ ] `VALIDATION` — relationships, invalid/disabled states, Dynamic Type, and accessibility not validated.
- **Hover Card**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Hover Card
        source, API, and examples: controlled or internal Root, arbitrary
        Trigger/Content, default-open state, caller-set hover/focus open and
        close delays, content-hover retention, disabled-state gating,
        configurable touch long press, outside dismissal, macOS Escape and
        native iPad keyboard dismissal, top/bottom/logical leading/trailing/
        physical left/right placement, reason and completion callbacks,
        imperative content dismissal, adjustable content sizing, and the
        modifier convenience share one engine. Native adaptation: an arrowless
        AppKit overlay panel owns Portal/Positioner/Popup behavior, collision
        handling, alignment, outside dismissal, and stacking on macOS; iPadOS
        retains the native popover, and touch long press is optional because
        essential information must also remain available at the trigger
        destination.
  - [ ] `VALIDATION` — pointer timing, focus alternative, dismissal, placement, and accessibility not validated.
- **Input**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Input source and
        complete type/composition examples: controlled String/Int/Double values,
        extensible typed conversion, partial numeric input, text/email/password/
        telephone/URL/search/number intent, iPad keyboard and content-type
        adaptation, secure reveal/hide, external binding synchronization,
        explicit or Field-inherited invalid state, disabled/focus/submit behavior,
        two sizes, optional symbol/trailing accessory, typed ranged Date/Time,
        and single/multiple File import with UTType filters, URL bindings, and
        callbacks are implemented. Native adaptations: a typed intent enum
        replaces HTML type strings, DatePicker preserves Date values,
        fileImporter returns native URLs, Field environment replaces
        aria-invalid, and select/button compositions remain external rather than
        being smuggled into the input itself.
  - [ ] `VALIDATION` — entry, focus, validation, selection, keyboards, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox History accepted a query,
        updated results, exposed a trailing clear action, and restored the list.
- **Input Group**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Input Group
        source and complete examples: a typed builder accepts only Input,
        Textarea, and Addon parts; inline-start/end and block-start/end addons
        are structurally reordered regardless of declaration order; the group
        owns its border, focus ring, invalid and disabled treatment; addon taps
        request focus from the real control; child invalid state propagates;
        grouped Input/Textarea reuse their editing engines while suppressing
        only standalone chrome; arbitrary Text, symbols, Kbd, Spinner, Tooltip,
        Dropdown, and Popover content composes; and real native addon Buttons
        support the official variants and four sizes. Native adaptations: a
        typed result builder replaces CSS child selectors/order, environment
        focus requests replace DOM queries, and heterogeneous parts are erased
        only after their placement has been recorded.
  - [ ] `VALIDATION` — focus, editing, actions, layout, and accessibility not available until code passes.
- **Input OTP**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Input OTP source,
        complete examples, and input-otp API: caller-controlled Root, Group,
        Slot, and Separator parts compose arbitrary group boundaries; one real
        native TextField owns typing, paste, replacement, deletion, selection,
        undo, and iPadOS one-time-code autofill; typed digit, alphanumeric,
        unrestricted, and custom patterns filter and clamp input; automatic,
        text, and numeric input modes select native iPadOS keyboards; Field or
        explicit invalid state, disabled behavior, logical RTL group corners,
        active focus rings, fake caret, configurable slot sizes, change and
        completion callbacks, coherent editable accessibility semantics, and a
        compact convenience composition are implemented. Native adaptations:
        a Sendable character predicate replaces JavaScript regex strings,
        SwiftUI environment replaces input-otp context, a typed group builder
        replaces CSS child selectors, and the visual slots are hidden from
        accessibility in favor of the single real editable field.
  - [ ] `VALIDATION` — typing, paste, deletion, focus movement, autofill, keyboard, and accessibility not validated.
- **Item**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Item source and
        complete examples: caller-composed Root, Group, Separator, Media,
        Content, Title, Description, Actions, Header, and Footer parts are
        implemented; default, outline, and muted variants and default, small,
        and extra-small sizes are typed; media supports default, icon, and
        clipped-image treatments with explicit decorative semantics; a custom
        native Layout gives header and footer full rows, preserves media and
        action controls, gives content remaining width, and mirrors placement
        for RTL; descriptions clamp or wrap; and real native Button, Link, and
        NavigationLink item roots supply activation, hover, press, focus,
        disabled, keyboard, and accessibility behavior. The concise leading,
        title, description, and trailing initializer remains a composition
        inside the same root rather than a second implementation. Native
        adaptations: explicit native interactive root types replace Base UI's
        render prop, typed enums replace cva, and SCItemSeparator reuses the
        shared Separator component.
  - [ ] `VALIDATION` — selection, actions, long content, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox exercised Items in Home
        activity rows, playback controls, and recording metadata rows.
- **Kbd**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Kbd source and
        complete examples: Kbd and KbdGroup now accept arbitrary view-builder
        content including text, symbols, icons, icon-plus-text, and sample
        output; groups accept caller composition and spacing; string-array and
        typed-key conveniences use the same parts; common macOS and iPadOS
        modifier, editing, navigation, and arrow keys have stable visual and
        spoken values; custom and icon-only keys accept explicit accessibility
        labels; grouped shortcuts produce one coherent announcement; and
        keycaps preserve the enclosing control's hit region. The visual Kbd
        intentionally installs no action: the real keyboardShortcut remains on
        the owning Button, Toggle, menu command, or command group, matching the
        upstream component's presentational role.
  - [ ] `VALIDATION` — key rendering, grouping, and accessibility labels not validated.
- **Label**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Label source,
        complete examples, and native platform constraints: Label accepts
        arbitrary view-builder content, follows disabled state, and supports a
        spoken required indicator; optional pointer, touch, and accessibility
        activation can forward to an associated checkbox or other control;
        FocusState convenience forwards activation to a real focusable input;
        and SCLabelledControl creates a native accessibility labelled-pair with
        vertical or horizontal layout and leading or trailing label placement.
        Native adaptations: accessibilityLabeledPair plus a private Namespace
        replaces HTML for/id, and an explicit action or FocusState replaces
        browser label-click forwarding instead of exposing a fake string ID.
  - [ ] `VALIDATION` — activation, Dynamic Type, and accessibility relationships not validated.
- **Marker**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Marker source
        and every complete example: Root, Icon, and Content accept arbitrary
        composition; default, border, and separator variants are implemented;
        horizontal or vertical axes and leading, centered, or trailing
        alignment cover the official layout examples; icon slots remain
        decorative; nested buttons, links, drawer triggers, and other controls
        retain independent actions and accessibility; explicit status text
        posts native announcements on appearance and change; real native
        Button, external Link, and in-app NavigationLink marker roots replace
        the render prop; and Marker composes with Accordion, Drawer, Spinner,
        Button, and Shimmer. Native adaptations: accessibility containment
        preserves nested controls, AccessibilityNotification replaces the web
        status role, and typed axis/alignment replace flex utility overrides.
  - [ ] `VALIDATION` — default/border/separator variants, live-status shimmer,
        and accessibility not validated.
- **Menubar**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Menubar source,
        full Base UI API, and complete examples: horizontal and vertical roots,
        whole-bar and per-menu disabled states, arbitrary Trigger and Content,
        native action items with default/destructive roles, controlled checkbox
        items, generic controlled radio groups, Section-backed Group/Label,
        native separators, real nested submenus, arbitrary icon/text labels,
        menu ordering, and typed shortcuts attached to real Button/Toggle
        actions are implemented. SwiftUI Menu owns popup windows, collision-safe
        placement, dismissal, focus, pointer/touch, keyboard, RTL, and
        accessibility. Native adaptations: no inert Portal or unhonored
        side/alignment API is exposed; native columns replace inset padding;
        platform traversal replaces loopFocus; and application-level macOS
        menus remain SwiftUI Commands while SCMenubar is the official in-window
        component.
  - [ ] `VALIDATION` — menus, shortcuts, focus, enabled state, and accessibility not validated.
- **Message**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Message source
        and every complete chat example: Group, Root, Avatar, Content, Header,
        and Footer accept arbitrary composition; logical start/end rows place
        avatars correctly under LTR and RTL; avatars stay footer-aware; an
        empty Avatar reserves the 32-point sender column for grouped messages;
        full-width headers and footers follow the message side while retaining
        nested actions; all structural spacing is configurable; long content
        receives remaining width and wraps; and Bubble groups, Attachments,
        Attachment groups, Markers, rich text, and real controls compose
        without flattened accessibility. Native adaptations: a local direction
        flip replaces flex-row-reverse while restoring reading direction inside
        parts, a preference replaces the footer group-has selector, and native
        frame alignment replaces justify utility classes.
  - [ ] `VALIDATION` — alignment, avatar, header/footer slots, grouping, RTL,
        selection, and accessibility not validated.
- **Message Scroller**
  - [x] `CODE` — accepted 2026-07-14 against the current Base wrapper, complete
        chat example, and published @shadcn/react 0.2.1 declarations and
        implementation: observable State replaces Provider and all three hooks;
        Root, focusable Viewport, Content, optional-ID Item, and configurable
        native Button are public; published defaults (auto-scroll off, 8-point
        edge threshold, 64-point previous-turn peek, zero margin) match;
        start/end/last-anchor opening, live-edge-only stream following, new-turn
        anchoring, multi-turn follow, optional prepend preservation, pending
        early jumps, start/center/end/nearest message alignment, per-command
        margin/animation, start/end commands, visibility/current-anchor state,
        inert scroll controls, scroll fade, and iPad keyboard dismissal are
        implemented. Native adaptations: ScrollViewReader plus computed anchors
        replaces DOM scroll positioning, geometry preferences replace observers,
        a mounted VStack preserves reliable jumps, and transient ID-less items
        remain visible without registering for jumps or visibility.
  - [ ] `VALIDATION` — anchoring, streaming follow, prepend preservation,
        jump-to-message, scroll controls, keyboard, and accessibility not validated.
- **Native Select**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Native Select
        source and every complete example: a generic Hashable Picker supports
        caller-controlled or internally managed selection, default/small sizes,
        arbitrary tagged Options, disabled options, Section-backed OptGroups,
        explicit or inherited disabled state, explicit or Field-inherited
        invalid state, accessibility labels, and change callbacks. Native focus,
        keyboard, touch, popup, selection, dismissal, and accessibility remain
        platform-owned. Native adaptations: tagged views replace option values,
        Section replaces optgroup, caller-defined placeholder values remain
        typed, and the real Picker owns its disclosure indicator instead of a
        decorative chevron being drawn over it.
  - [ ] `VALIDATION` — selection, keyboard, touch, disabled state, and accessibility not validated.
- **Navigation Menu**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Navigation Menu
        source, complete shadcn example, and Base UI API: controlled or
        internally managed active values, typed Hashable item identities,
        default values, horizontal and vertical lists, delayed hover opening
        and closing, stable Item-to-Trigger-and-Content pairing, trigger press,
        disabled and expanded states, direction-aware arrow traversal with
        wraparound, keyboard popup opening/closing and active-item switching,
        real URL Link, value-based NavigationLink, and Button action variants,
        active-link styling, close-on-activation control, caller dismissal,
        nested roots, and reusable trigger/link chrome are implemented. Native
        popovers own real anchoring, collision avoidance, outside and Escape
        dismissal, focus containment, compact iPad presentation, and logical
        top/bottom/leading/trailing placement with start/center/end attachment.
        Native adaptations: Item takes separate trigger and content builders so
        the popover content exists at its real attachment site; native popover
        replaces Portal/Popup/Viewport and unsupported DOM animation/pixel
        offset props are not exposed; AnyHashable carries Base's any-valued
        identity through the non-generic root while typed initializers preserve
        caller values.
  - [ ] `VALIDATION` — keyboard, pointer, touch, focus, resizing, dismissal,
        nested menus, and accessibility not validated.
- **Pagination**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Pagination
        source, complete docs including Simple, Icons Only, Next.js, RTL, and
        changelog examples, and registry example: caller-composed Root,
        Content, Item, Link, Previous, Next, and Ellipsis parts are implemented;
        Link supports real URL navigation or native actions and a distinct
        value-based NavigationLink preserves in-app navigation semantics; all
        paths reuse the shared Button engine for outline-current and
        ghost-inactive variants, sizes, disabled state, keyboard, pointer,
        focus, and accessibility; active-page value and selected semantics,
        localized visible and accessibility labels, automatic/visible/icon-only
        previous and next labels, logical RTL arrows, configurable navigation
        labeling/alignment/width, and a noninteractive ellipsis are implemented.
        The controlled windowed pager remains only as a composition over those
        same parts and adds localized page formatting, zero-page handling,
        activation-time bounds clamping, and change callbacks. Native
        adaptations: chevron.backward/forward and layoutDirection replace
        flipped SVGs; ViewThatFits replaces the CSS text breakpoint.
  - [ ] `VALIDATION` — boundaries, URL and in-app activation, keyboard, compact
        labels, RTL, Dynamic Type, and accessibility not validated.
- **Popover**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Popover source,
        complete examples, and Base UI API: controlled or internally managed
        presentation, independent arbitrary Trigger and Content builders, a
        real disabled native Button trigger, press and delayed-hover opening,
        native dismissal with explicit change reasons, logical and physical
        side placement, start/center/end attachment, compact popover/sheet/
        automatic adaptation, themed arbitrary rich content, Header, semantic
        Title, Description, real Close button, and caller-accessible dismissal
        are implemented. SwiftUI owns the real portal, trigger anchoring,
        collision avoidance, arrow, outside and Escape dismissal, window or
        dialog stacking, focus movement and return, and accessibility
        presentation. The `.scPopover` convenience uses that same presentation
        host rather than a second component engine. Native adaptations: the
        trigger is the real native attachment anchor; SwiftUI popover replaces
        Portal, Positioner, and Popup; logical placement follows layout
        direction; and unsupported DOM animation and pixel-offset controls are
        omitted instead of exposed as decorative API.
  - [ ] `VALIDATION` — placement, dismissal, focus return, compact adaptation, keyboard, and accessibility not validated.
- **Progress**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Progress source,
        all complete examples, and the full Base UI API: Root, Track,
        Indicator, Label, and Value are public composable parts; the default
        Root appends the official Track-and-Indicator composition while an
        explicit custom-composition path uses the same environment state;
        values are clamped across caller-defined minimum and maximum bounds;
        nil is a real indeterminate state; indeterminate, progressing, and
        complete statuses are exposed; localized percentage or number output
        and snapshot-driven custom Value content are supported; Label and
        Indicator accept arbitrary content; theming, disabled appearance,
        determinate animation, indeterminate sweep, and reduced-motion fallback
        are implemented. A native ProgressView accessibility representation
        supplies real platform progress semantics, label, range, and value.
        The existing `.scLinear` ProgressViewStyle is retained only as a
        convenience over these same parts, not a second engine. Native
        adaptations: Swift FormatStyle replaces Intl.NumberFormat; SwiftUI
        environment state replaces React context and data attributes; and
        TimelineView replaces CSS indeterminate animation.
  - [ ] `VALIDATION` — value announcements, reduced motion, appearance, and accessibility not validated.
- **Radio Group**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Radio Group and
        Radio sources plus every complete shadcn example: typed Root and Item
        parts support non-optional or optional controlled selection and
        internally managed default selection; arbitrary rich labels and
        indicator-only Field composition use the same real Button item;
        vertical, horizontal, and grid roots are implemented; root and item
        disabled, read-only, required, explicit invalid, and Field-inherited
        invalid states are real; value-change callbacks, focus rings, selected
        semantics, per-platform touch targets, reduced-motion animation, and
        wrapping RTL-aware arrow traversal that skips unavailable items are
        implemented. The existing `SCRadio` spelling is only a type alias for
        a text-labeled `SCRadioGroupItem`, not retained legacy code. Native
        adaptations: arbitrary SwiftUI label builders replace HTML id/for;
        native app state replaces hidden form inputs and name/form fields; and
        a shared focus coordinator replaces browser radio traversal.
  - [ ] `VALIDATION` — arrow keys, touch targets, disabled state, and accessibility not validated.
- **Resizable**
  - [x] `CODE` — accepted 2026-07-14 against the current Resizable source and
        every complete horizontal, vertical, handle, nested, and controlled
        example: Panel Group, Panel, and Handle are public composable parts;
        arbitrary panel counts, stable string IDs, normalized default sizes,
        controlled or internal keyed layouts, layout and per-panel callbacks,
        horizontal or vertical orientation, nested groups, minimum and maximum
        constraints, optional collapsed sizes, and adjacent-pair size
        conservation are implemented. Handles are real drag, focus, arrow-key,
        double-click-reset, pointer-cursor, and accessibility-adjustable
        controls with optional visible grip and configurable hit target. The
        previous two-pane `SCResizableSplit` now composes the same public parts
        and state engine. Native adaptations: a typed result builder replaces
        React child discovery; GeometryReader converts stable fractions to
        native geometry; and SwiftUI gesture, focus, and accessibility actions
        replace DOM pointer and separator events.
  - [ ] `VALIDATION` — drag, keyboard, pointer cursor, min/max, resize, and accessibility not validated.
- **Scroll Area**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Scroll Area
        source and complete vertical and horizontal examples: Root and Scrollbar
        are public composable parts; arbitrary viewport content, inferred or
        explicit vertical/horizontal/both axes, per-axis automatic/visible/hidden
        indicators, native thumb dragging and two-axis corner behavior, bounce,
        disabled scrolling, focus ring, border, clipping, and an accessibility
        label are implemented. The Scrollbar is a real configuration token
        consumed by the Root's typed builder, never a decorative fake thumb.
        Native adaptation: SwiftUI's platform ScrollView deliberately owns the
        Viewport, Scrollbar, Thumb, and Corner so macOS and iPad preserve native
        scrolling, keyboard, pointer, and accessibility behavior.
  - [ ] `VALIDATION` — scrolling, indicators, keyboard, pointer, and accessibility not validated.
- **Select**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Select source,
        composition contract, API, and complete examples: Root, Trigger, Value,
        Content, Group, Label, Item, and Separator are public composable parts;
        typed controlled or internal single and multiple selection, arbitrary
        rich item and selected-value views, keyboard text values, default/small
        triggers, per-item and root disabling, read-only, required, explicit or
        Field-inherited invalid state, callbacks, grouped and scrollable lists,
        real selected indicators, and existing array convenience calls use one
        engine. Native Menu supplies real popup placement, dismissal, scrolling,
        scroll arrows, keyboard/typeahead, pointer/touch, focus restoration, and
        accessibility; Section, Divider, Button, and Toggle replace the matching
        web parts. Side, alignment, portal, and controlled-open props are omitted
        rather than faked because the platform menu deliberately owns them.
  - [ ] `VALIDATION` — binding, keyboard, dismissal, disabled state, touch, and accessibility not validated.
- **Separator**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Separator source,
        API, and complete horizontal, vertical, menu, and list examples: the
        default horizontal and explicit vertical one-point rules fill their
        native axis; separators are semantic and accessibility-visible by
        default as upstream requires; purely visual uses explicitly opt into
        decorative hiding; and the Swiftcn labeled extension now accepts either
        a String or arbitrary centered SwiftUI content as one combined semantic
        element. Button Group's internal join rules explicitly declare
        themselves decorative rather than inheriting semantic separator noise.
  - [ ] `VALIDATION` — horizontal, vertical, labeled, and accessibility behavior not validated.
        macOS consumer evidence 2026-07-14: TimberVox exercised horizontal Card,
        header, and metadata rules plus vertical Home-statistic separators.
- **Sheet**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Sheet source,
        Dialog API, and complete form, no-close-button, and four-side examples:
        controlled or internal Root, Trigger, Overlay, Content, Header, Footer,
        arbitrary Title and Description, automatic or caller-composed Close,
        open-change callbacks, semantic top/bottom/leading/trailing edges,
        optional panel sizing, scrim and Escape policy, and the existing
        `.scSheet` convenience are implemented. Sheet now specializes the one
        Drawer presentation engine with dragging disabled, so focus restoration,
        inert background, modal accessibility, reduced-motion transitions,
        pointer dismissal, Escape, and edge geometry are real and shared rather
        than duplicated. The compatibility dismiss environment also bridges to
        that same Close action.
  - [ ] `VALIDATION` — edges, focus, dismissal, keyboard, resizing, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox opened its trailing
        recording-information Sheet, exposed the modal content, and dismissed it
        through the caller-provided back action without invoking Finder.
- **Sidebar**
  - [x] `CODE` — accepted 2026-07-14 against the current Base sidebar source and
        documentation. One `SCSidebarLayout`/`SCSidebarState` engine now owns
        controlled-or-internal state, change notification, UserDefaults
        persistence, regular/compact routing, leading/trailing placement,
        sidebar/floating/inset variants, offcanvas/icon/none collapse, custom
        widths, Command-B/Control-B, and the functional pointer/drag/accessibility
        rail. Compact iPad containers use the accepted leading/trailing Sheet
        engine rather than a bottom system sheet. All official primitive slots
        are present; menu buttons expose default/outline, default/sm/lg, active,
        disabled, rich builders, trailing content, and collapsed tooltips;
        submenu containers expose indented-guide and compact flush styles;
        submenu buttons expose sm/md, active, disabled, and rich content; menu
        actions are real buttons with optional hover reveal. Sidebar Trigger,
        Input, Separator, and MenuSkeleton compose the accepted Button, Input,
        Separator, and Skeleton engines. Strict formatter, strict SwiftLint,
        macOS 14 compile, device-free iOS 17 compile, registry generation, and
        structural mapping pass.
  - [ ] `VALIDATION` — resizing, keyboard, focus, pointer, VoiceOver, compact iPad,
        persistence, and every primitive slot not validated.
        macOS consumer evidence 2026-07-14: TimberVox expanded and collapsed the
        icon Sidebar while preserving History selection and detail content.
- **Skeleton**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Skeleton source
        and examples. `SCSkeleton` now defaults to shadcn's pulse, supports
        pulse/shimmer/static modes in one engine, automatically becomes static
        for Reduce Motion, accepts flexible or fixed sizing, custom tint/radius,
        and arbitrary SwiftUI shapes, and stays hidden from accessibility.
        `.scSkeleton(when:animation:)` shares that engine for redacted content,
        disables interaction while pending, and hides placeholder content from
        accessibility. Strict formatter, strict SwiftLint, macOS 14 compile,
        device-free iOS 17 compile, registry generation, and structural mapping
        pass.
  - [ ] `VALIDATION` — shapes, reduced motion, and accessibility hiding not validated.
- **Slider**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Slider source,
        examples, and API. One controlled-or-internal engine supplies scalar,
        range, and arbitrary multiple-thumb values; horizontal/vertical layout;
        continuous or stepped values; configurable large step, minimum thumb
        separation, and edge/center alignment; push/swap/stop collisions; root
        and per-thumb disabling; track press and drag; Arrow, Shift-Arrow,
        Page Up/Down, Home, and End controls; change/commit callbacks with reason
        and active-thumb metadata; caller value formatting and thumb labels; and
        one native adjustable accessibility representation per thumb. The scalar
        initializer is a convenience over this same engine. Strict formatter,
        strict SwiftLint, macOS 14 compile, device-free iOS 17 compile, registry
        generation, and structural mapping pass.
  - [ ] `VALIDATION` — keyboard, touch, pointer, value announcements, and disabled state not validated.
        macOS consumer evidence 2026-07-14: TimberVox playback started from the
        Slider control, published progress through accessibility, and returned to
        zero after the real eight-second recording completed.
- **Sonner**
  - [x] `CODE` — accepted 2026-07-14 against the current shadcn Sonner wrapper,
        examples, and upstream Sonner API. `SCSonner` is a typed façade over the
        same `SCToastCenter` used by compatibility Toast callers, so there is one
        queue rather than a decorative or duplicate engine. It supports default,
        success, info, warning, error, and persistent loading notifications;
        stable identifiers and in-place updates; dismiss one/all; title,
        description, action, cancel, close, and dismissal policy; six positions;
        visible-count, gap, collapsed/expanded stacking, pause-on-hover, and
        directional swipe configuration; dismissal and auto-close callbacks;
        accessibility announcements; and Swift Concurrency success/error promise
        transitions. Strict format/lint, macOS 14 compile, device-free iOS 17
        compile, registry generation, and structural mapping pass.
  - [ ] `VALIDATION` — queue, stacking, timing, actions, announcements, promise transitions, and dismissal not validated.
- **Spinner**
  - [x] `CODE` — accepted 2026-07-14 against the current Spinner source and
        Basic, Button, Badge, Input Group, and Empty examples. `SCSpinner`
        matches the 16-point default, accepts arbitrary size and line width,
        inherits the caller's foreground style for composition in any of those
        containers, respects environmental disabled state, and exposes a
        caller-defined loading label through a native indeterminate
        `ProgressView` accessibility representation. Reduce Motion leaves the
        same progress glyph static. Strict format/lint, macOS 14 compile,
        device-free iOS 17 compile, registry generation, and structural mapping
        pass.
  - [ ] `VALIDATION` — sizes, reduced motion, labels, and appearance not validated.
- **Switch**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Switch source and
        Description, Choice Card, Disabled, Invalid, Size, and RTL examples.
        `SCSwitch` exposes a real caller-owned binding, default/small sizes,
        explicit or Field-inherited invalid state, explicit or environmental
        disabled state, a visible focus ring and expanded hit target, native
        switch accessibility, Reduce Motion behavior, and direction-aware thumb
        placement. The established native `Toggle` style is preserved over the
        same visual engine and supports both sizes and invalid state. Native
        adaptation: the standalone control requires an accessibility label in
        place of the web id/for association. Strict format/lint, macOS 14
        compile, device-free iOS 17 compile, registry generation, and structural
        mapping pass.
  - [ ] `VALIDATION` — native semantics, keyboard, touch target, and accessibility not validated.
- **Table**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Table source,
        composition guide, Footer, Actions, Data Table, and RTL examples. Public
        Root/Header/Body/Footer/Head/Row/Cell/Caption composition, responsive
        horizontal overflow, shared fixed/minimum/flexible column sizing,
        arbitrary rich content, selected/expanded/actionable row treatment,
        header and selection accessibility traits, and direction-aware alignment
        are implemented. The existing typed rows/columns API remains source
        compatible and adds caller-owned sorting, selection, select-all, rich
        cells, and row activation as a data-table convenience. Native adaptation:
        Caption is a dedicated Root builder because SwiftUI cannot hoist a child
        from the horizontal scroll container like HTML. Strict format/lint,
        macOS 14 compile, device-free iOS 17 compile, registry generation, and
        structural mapping pass.
  - [ ] `VALIDATION` — sort, select one/all, activate rows, cell controls, keyboard,
        accessibility, macOS, and iPadOS not validated.
- **Tabs**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Tabs source and
        complete shadcn examples: public Root/List/Trigger/Content composition,
        required/optional/internal typed state, automatic first-enabled internal
        fallback, change callbacks, default/line variants, horizontal/vertical
        layout, arbitrary labels and panels, disabled triggers, keep-mounted
        panels, manual or focus-activated loopable arrow traversal, RTL, and the
        original data-driven API as a thin composition are implemented. Native
        adaptations: Binding/environment state and native Buttons/FocusState
        replace Base context/roving tabindex; selected-trigger overlays replace
        the DOM Indicator. Strict format/lint, macOS and device-free iOS compiles,
        registry generation, and parity mapping pass.
  - [ ] `VALIDATION` — keyboard navigation, arbitrary labels/content, and accessibility not validated.
- **Textarea**
  - [x] `CODE` — accepted 2026-07-14 against the current Textarea source and
        complete examples: caller-owned multiline binding, optional placeholder,
        current 64-point default and custom minimum heights, explicit or
        Field-inherited invalid state, disabled/focus treatment, native editing,
        selection, scrolling, undo, keyboard and RTL behavior, plus Input Group
        chrome/focus integration are implemented. The decorative placeholder is
        hidden from accessibility and attached as a hint to the real editor.
        Native adaptations: TextEditor and Binding replace the HTML element and
        DOM events; labels, descriptions, and buttons remain ordinary Field
        composition. Strict format/lint, macOS and device-free iOS compiles,
        registry generation, and parity mapping pass.
  - [ ] `VALIDATION` — focus, scrolling, selection, Dynamic Type, and accessibility not validated.
- **Toast**
  - [x] `CODE` — accepted 2026-07-14 against the current official Toast page,
        which now publishes only a deprecation notice directing callers to
        Sonner. The existing registry entry remains installable for migration
        compatibility and preserves real queued presentation, actions, timing,
        manual/swipe dismissal, and caller-owned dispatch. No obsolete second
        Toast primitive was invented. Complete queue, promise, type, and
        positioning parity remains deliberately tracked by the separate Sonner
        item. macOS and device-free iOS compiles, registry generation, and parity
        mapping pass.
  - [ ] `VALIDATION` — queueing, timing, swipe/dismissal, actions, stacking, reduced motion, and announcements not validated.
- **Toggle**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Toggle source and
        complete shadcn examples: the native SwiftUI Toggle binding is the real
        caller-controlled pressed state and change path; arbitrary labels,
        default/outline variants, small/default/large sizes, pressed and pointer
        feedback, focus ring, disabling, keyboard activation, and accessibility
        semantics are implemented. The public button style is shared with Toggle
        Group so both use one visual engine. Native adaptations: ToggleStyle
        replaces Base's render prop, native app state replaces uncontrolled DOM
        state and hidden form values, and the platform control retains activation
        semantics. Strict format/lint, macOS and device-free iOS compiles,
        registry generation, and parity mapping pass.
  - [ ] `VALIDATION` — pressed state, keyboard, focus, disabled state, and accessibility not validated.
- **Toggle Group**
  - [x] `CODE` — accepted 2026-07-14 against the current Base Toggle Group and
        complete shadcn examples: public Root and Item views support arbitrary
        labels and typed values, caller-controlled or internal single/multiple
        state, change callbacks, default/outline variants, three sizes, the
        current two-point spacing default, connected zero spacing, horizontal
        and vertical layout, root/item disabling, loopable axis-aware arrow
        focus, RTL traversal, and explicit accessibility labeling. The original
        array initializers remain connected-outline compositions over the same
        engine. Native adaptations: SwiftUI environment state and typed bindings
        replace Base context/string arrays; native Buttons and FocusState replace
        toggle primitives and roving tabindex. Strict format/lint, macOS and
        device-free iOS compiles, registry generation, and parity mapping pass.
  - [ ] `VALIDATION` — keyboard traversal, disabled items, focus, and accessibility not validated.
        macOS consumer evidence 2026-07-14: TimberVox exposed Original as selected
        and Segmented as individually disabled with explanatory help when the
        recording contained no timestamp segments.
- **Tooltip**
  - [x] `CODE` — audited against the current official docs and registry source.
        `SCTooltipProvider` owns delayed/immediate presentation and unclipped
        placement, `SCTooltip` owns the SwiftUI trigger slot,
        `SCTooltipContent` owns the themed bubble and arrow, and `.scTooltip`
        is the convenience API over the same path. Leading/trailing replace
        physical left/right; touch uses temporary long-press presentation.
  - [ ] `VALIDATION` — the macOS Showcase and TimberVox consumer compile, the
        production app launches, sidebar collapse/expand works, and the trigger
        exposes accessibility help. Stationary hover screenshots, keyboard
        focus traversal, dismissal/timing, disabled triggers, iPadOS pointer and
        touch, VoiceOver, and automated host coverage remain incomplete.
- **Typography**
  - [x] `CODE` — accepted 2026-07-14 against the current typography guide, which
        intentionally ships examples rather than a component: all documented h1
        through h4, paragraph, blockquote, table, list, inline-code, lead, large,
        small, and muted treatments are present; headings expose native levels,
        h1 and h2 match the full-width centered/ruled defaults with opt-outs,
        lists accept arbitrary duplicate-safe rows, and the table alias installs
        the shared Table dependency. Native adaptations: document-flow spacing
        belongs to the caller's stack/scroll container, and SwiftUI has no direct
        CSS text-balance equivalent. Strict format/lint, macOS and device-free
        iOS compiles, registry generation, and parity mapping pass.
  - [ ] `VALIDATION` — Dynamic Type, selection, layout, and accessibility not validated.

## Effects

Effects are Swiftcn additions, not official shadcn component-catalog entries.

- **Aurora**
  - [x] `CODE` — accepted 2026-07-14 as a Swiftcn-native ambient background
        effect. `SCAuroraBackground` exposes caller colors, speed, blur, and
        base color; fills and clips to arbitrary container geometry; cycles a
        short palette safely; sanitizes non-finite speed and blur inputs; and
        renders as an accessibility-hidden visual layer for ordinary `ZStack`
        composition. Timeline time is derived rather than accumulated, pauses
        when speed is zero, and becomes a deterministic static composition
        under Reduce Motion. Strict format/lint, macOS 14 compile, device-free
        iOS 17 compile, registry generation, and structural ledger pass.
  - [ ] `VALIDATION` — resizing, reduced motion, CPU/GPU use, and appearance not validated.
- **Dot Pattern**
  - [x] `CODE` — accepted 2026-07-14 against the current Magic UI source,
        docs, and glow example. One responsive Canvas engine exposes dot size,
        square or independent horizontal/vertical pitch, whole-pattern and
        per-cell offsets, caller color, radial fade, and optional glow. Static
        dots are batched into one path; glow uses deterministic per-dot phases,
        two-to-five-second durations, opacity and scale pulses, and a 30 fps
        timeline without random state. Invalid sizes cannot create an infinite
        grid, the layer is hidden from accessibility, and Reduce Motion uses the
        same static pattern. Strict format/lint, macOS 14 compile, device-free
        iOS 17 compile, registry generation, and structural ledger pass.
  - [ ] `VALIDATION` — scaling, resizing, CPU/GPU use, and appearance not validated.
- **Marquee**
  - [x] `CODE` — accepted 2026-07-14 against the current Magic UI source,
        docs, and vertical example. One measured Timeline engine supports
        horizontal and vertical axes, logical leading/trailing travel with RTL,
        caller speed and spacing, the upstream four-copy default, a caller
        minimum repeat count, and additional automatic copies when required to
        prevent an empty gap. It remeasures dynamic content, hides duplicate
        copies from accessibility, pauses and resumes without jumping on hover,
        exposes optional axis-matched edge fades, sanitizes invalid motion
        inputs, and presents static content under Reduce Motion. Strict
        format/lint, macOS 14 compile, device-free iOS 17 compile, registry
        generation, and structural ledger pass.
  - [ ] `VALIDATION` — pause, reduced motion, dynamic content, CPU/GPU use, and accessibility not validated.
- **Number Ticker**
  - [x] `CODE` — accepted 2026-07-14 against the current Magic UI source,
        docs, decimal, and start-value examples. `SCNumberTicker` now has a real
        interpolated-number engine with target and start values, up/down
        direction, cancellable delay, integer and arbitrary locale-aware
        floating-point formats, monospaced digits, and replay when its
        configuration changes. SwiftUI task lifecycle replaces the upstream
        in-view observer and cancels delayed work when removed. Reduce Motion
        resolves directly to the terminal value, and accessibility exposes the
        stable formatted terminal number instead of every animation frame.
        Strict format/lint, macOS 14 compile, device-free iOS 17 compile,
        registry generation, and structural ledger pass.
  - [ ] `VALIDATION` — value changes, formatting, reduced motion, and accessibility value not validated.
- **Scroll Fade**
  - [x] `CODE` — accepted 2026-07-14 against the current official shadcn
        utility docs and Demo, No Overflow, Horizontal, Edge, Size, Disable,
        and RTL examples. `scScrollFade` masks content rather than overlaying a
        background and supports vertical/horizontal combined fades, individual
        top/bottom/logical leading/trailing edges, physical left/right edges,
        a shared depth, per-edge overrides, empty-edge disable, the 12%-capped-
        at-40-point default, and caller reveal distance. On macOS 15/iOS 18 it
        tracks real scroll geometry, suppresses fades without overflow, eases
        start/end edges independently, and maps logical/physical edges under
        RTL; the macOS 14/iOS 17 path intentionally matches upstream's static
        fallback. Invalid sizes and reveal values are bounded. Strict
        format/lint, macOS 14 compile, device-free iOS 17 compile, registry
        generation, and structural ledger pass.
  - [ ] `VALIDATION` — scroll-aware easing, per-edge selection, RTL, resizing,
        and appearance not validated.
- **Shimmer / Shimmer Button**
  - [x] `CODE` — accepted 2026-07-14 against the current official shadcn
        shimmer utility docs and Demo, Marker, Color, Duration, Spread, Angle,
        Reverse, Once, Disable, Reduced Motion, and RTL examples. `scShimmer`
        keeps the original content and interaction engine, masks a configurable
        highlight band over it, supports active/disabled, duration, spread,
        angle, explicit color, once/repeat, and reverse, follows reading
        direction, adapts its default highlight to appearance, sanitizes motion
        inputs, and renders untouched under Reduce Motion. The separate
        Swiftcn-native `SCShimmerButton` remains one real `Button` using the
        accepted `SCButtonStyle`; it now supports arbitrary labels, every button
        variant/size, beam color/width/length/duration, inherited disabled and
        accessibility semantics, and a non-animated Reduce Motion path. Strict
        format/lint, macOS 14 compile, device-free iOS 17 compile, registry
        generation, and structural ledger pass.
  - [ ] `VALIDATION` — masking, reduced motion, RTL sweep, disabled state,
        CPU/GPU use, and accessibility not validated.

## Audio (elevenlabs-ui)

Audio components are 1:1 ports from the elevenlabs-ui registry
(github.com/elevenlabs/ui, MIT), a second named upstream with the same
open-code model. Their parity ledger is `parity/elevenlabs-ui.json`, the
sibling of `parity/shadcn.json` (same schema: upstream URLs, upstreamParts →
swiftSymbols, behaviors, intentionalAdaptations).
`scripts/check_elevenlabs_parity.py` now verifies adopted/supporting-item
coverage, official source links, production symbols, registry files, and
declared dependencies in CI. Focused device-free behavior tests cover the pure
speech transcript, scrub timestamp, transcript composition, and word-tracking
logic; runtime and visual validation remain separate. The shared engine seam is
`audio-level-provider`
(`SCAudioLevelProvider`), the analog of upstream distributing its `use-scribe`
hook as a registry item.

- **Audio Level Provider** (engine seam; no upstream UI part)
  - [x] `CODE` — added 2026-07-14: `SCAudioLevelProvider` replaces the Web
        Audio `AnalyserNode` glue embedded in both upstream visualizers;
        views poll normalized bands on the main actor. Consumers conform with
        AVAudioEngine or any other engine.
  - [ ] `VALIDATION` — not validated against a real audio engine.
- **Live Waveform**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `live-waveform.tsx`: static mirrored and scrolling modes, live
        sampling throttled to the update rate, the synthesized processing
        animation blending out of the last live frame, fade-to-idle, dotted
        idle baseline, edge fading, bar geometry/sensitivity/history
        configuration, and the three aria labels are implemented. Native
        adaptations: provider polling replaces getUserMedia/analyser
        (deviceId/fftSize/smoothing and stream callbacks move to the engine);
        TimelineView+Canvas replace the rAF canvas loop with per-second
        integration of upstream's per-frame constants; `theme.foreground`
        replaces CSS currentColor.
  - [ ] `VALIDATION` — live engine input, both modes, processing/idle
        transitions, resizing, macOS, iPadOS, and accessibility not validated.
- **Bar Visualizer**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `bar-visualizer.tsx`: five agent states, the connecting/initializing
        sweep and listening/thinking blink sequences with upstream intervals,
        the 300 ms thinking pulse, speaking all-primary bars, demo-mode fake
        bands, min/max height clamping with the +5 offset, 8–12 pt flexible
        capsules with 150 ms transitions, and bottom/center alignment are
        implemented. Native adaptations: provider polling replaces
        mediaStream + multiband hooks; a time-derived animator replaces the
        rAF sequencer; deterministic noise replaces Math.random; a `height`
        parameter replaces className height utilities.
  - [ ] `VALIDATION` — live engine input, all five states, alignment modes,
        resizing, macOS, iPadOS, and accessibility not validated.
- **Speech Input**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `speech-input.tsx` and `use-scribe.ts`: Root/RecordButton/Preview/
        CancelButton composition, the `useSpeechInput` context surface
        (`scSpeechInput`), idle → connecting (pulsing dot, disabled) →
        recording (stop square, chrome, preview reveal, cancel) states,
        transcript building, onChange/onStart/onStop/onCancel/onError with
        snapshots, the superseded-start guard, disconnect-on-disappear, and
        three sizes are implemented. Native adaptations: the
        `SCSpeechInputSession` protocol replaces `useScribe` + `getToken`
        (token, model/VAD/microphone config, and the Scribe error taxonomy
        live in the consumer engine — no ElevenLabs SDK); shared `SCSkeleton`
        renders the circular connecting indicator; SF Symbols replace lucide;
        animation modifiers replace framer-motion.
  - [ ] `VALIDATION` — a real transcription session (e.g. VoiceFlowKit),
        cancel/stop flows, size variants, keyboard, macOS, iPadOS, and
        VoiceOver not validated.
- **Scrub Bar**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `scrub-bar.tsx`: Container/Track/Progress/Thumb/TimeLabel compound
        composition, context surface, pointer-to-time mapping, scrub lifecycle,
        clamping, immediate progress drawing, thumb positioning, tabular m:ss
        formatting, and slider accessibility are implemented. Native
        adaptations: SwiftUI environment replaces React context; DragGesture
        replaces window pointer capture; the 0…1 fraction is rendered by
        shared `SCProgressTrack`/`SCProgressIndicator` with zero transition
        duration; native adjustable actions seek in five-percent increments.
  - [ ] `VALIDATION` — mouse/touch scrubbing, resizing, macOS, iPadOS, and
        VoiceOver not validated in a running showcase.
- **Transcript Viewer**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `transcript-viewer.tsx` and `use-transcript-viewer.ts`: Container/
        Provider/Words/Word/PlayPauseButton/ScrubBar composition, character
        alignment composition, audio-tag hiding, spoken/current/unspoken
        projections, binary-search word tracking and timing-gap behavior,
        word/index seeking, callback surface, duration guessing, custom
        renderers, and end-of-playback presentation are implemented. Native
        adaptations: an observable player protocol replaces HTMLAudioElement;
        an additional normalized-word composition initializer supports ASR
        providers without character timing; a SwiftUI Layout replaces inline
        spans; seeking remains available to custom renderers through context,
        while the default word is noninteractive like upstream; insets and
        spacing expose upstream's root class customization.
  - [ ] `VALIDATION` — real audio synchronization, seeking across timing gaps,
        long transcript wrapping, macOS, iPadOS, and VoiceOver not validated in
        a running showcase.
- **Waveform**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `waveform.tsx`: Waveform/StaticWaveform/ScrollingWaveform/AudioScrubber/
        MicrophoneWaveform/LiveMicrophoneWaveform/RecordingWaveform, shared bar
        geometry and edge fades, click/seek mapping, progress/playhead/handle,
        live and processing animation, capture history, scrub playback seam,
        completed-take callback, position scrubbing, and slider accessibility
        are implemented across the six `Waveform*.swift` registry files.
        Native adaptations: TimelineView+Canvas replace rAF; deterministic
        noise replaces Math.random; provider/playback protocols own AV audio;
        SwiftUI bindings replace mutable refs and DragGesture replaces document
        mouse capture.
  - [ ] `VALIDATION` — decoded real-audio peaks, microphone capture, scrub
        playback, completed takes, resizing, macOS, iPadOS, and VoiceOver not
        validated in a running showcase.

## Chat (elevenlabs-ui)

Non-audio elevenlabs-ui ports, tracked in the same `parity/elevenlabs-ui.json`
ledger as the Audio section.

- **Response**
  - [x] `CODE` — accepted 2026-07-14 against the current upstream
        `response.tsx` (a `React.memo` wrapper around Streamdown):
        `SCResponse` is the same thin wrapper around MarkdownUI
        (gonzalezreal/swift-markdown-ui 2.4.1 — the library's first SPM
        package dependency, mirroring upstream's `streamdown` npm dependency;
        see docs/architecture.md, "Package dependencies for engine wrappers").
        Markdown styles map to theme tokens; first/last block margins are
        trimmed as upstream does; `Equatable` replaces the memo comparator.
        Known gap, watched: MarkdownUI has no streaming-specific rendering of
        incomplete markdown (unterminated fences/emphasis render literally
        until closed), unlike Streamdown.
  - [ ] `VALIDATION` — rich documents, dark mode, Dynamic Type, selection,
        streaming updates, macOS, iPadOS, and accessibility not validated.

## Official blocks

The current listed catalog contains 15 sidebar blocks (`01`–`05`, `07`–`16`),
five login blocks, five signup blocks, and `dashboard-01`. `sidebar-06` has a
direct preview URL but is not in the current listed catalog; classify it before
porting it.

### Sidebar blocks

- **sidebar-01**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-01
        page, AppSidebar, SearchForm, and VersionSwitcher source. The offcanvas
        documentation shell, all four grouped navigation sections, controlled-
        or-internal version/search/selection state, real version menu,
        selection routing, and responsive section/current-page breadcrumb are
        implemented with typed callbacks. The upstream inert search form now
        performs real case-insensitive filtering with an empty-result state,
        and the block requires a caller detail builder instead of shipping fake
        dashboard rectangles. `SCSidebarLayout` owns persistence, Rail, and
        compact iPad Sheet behavior; native `Menu` and SF Symbols replace
        DropdownMenu and lucide. Strict format/lint, macOS 14 compile,
        device-free iOS 17 compile, registry generation, and structural mapping
        pass.
  - [ ] `VALIDATION` — version/search/navigation/breadcrumb actions, offcanvas persistence, keyboard, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-02**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-02
        page, AppSidebar, SearchForm, and VersionSwitcher source. It is a thin
        composition over sidebar-01's accepted documentation engine, adding the
        complete Community section and five initially open, independently
        collapsible groups without duplicating version/search/navigation/detail
        logic. Disclosure controls are real native buttons with chevron and
        expanded/collapsed accessibility state, emit typed callbacks, and keep
        matching search results visible without destroying stored collapse
        state. The caller supplies real detail content instead of the upstream
        decorative scroll placeholders. Strict format/lint, macOS 14 compile,
        device-free iOS 17 compile, registry generation, and structural mapping
        pass.
  - [ ] `VALIDATION` — section disclosure, search interaction, sticky-header-equivalent scrolling, keyboard, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-03**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-03
        page and AppSidebar source. It is a thin composition over the accepted
        documentation-sidebar engine with the static Documentation v1.0.0
        brand header, all five selectable parent rows, and every always-visible
        nested SidebarMenuSub destination. Brand, parent, nested navigation,
        and responsive breadcrumb actions are real and typed; current selection
        drives the breadcrumb and required caller detail instead of decorative
        placeholder rectangles. Strict format/lint, macOS 14 compile, generic
        physical iOS/iPadOS 17 compile without a simulator, registry generation,
        and structural mapping pass.
  - [ ] `VALIDATION` — brand/parent/submenu/breadcrumb actions, keyboard,
        accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-04**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-04
        page and AppSidebar source. It configures the same documentation engine
        as sidebar-03 with the exact defining differences: a floating shell,
        304-point (19rem) expanded width, and compact flush submenus without a
        guide line. Brand, parent, nested navigation, breadcrumb, persistence,
        compact iPad presentation, and required caller detail remain real and
        typed. The reusable submenu primitive now owns both indented-guide and
        flush treatments; sidebar-03's registry dependency was also corrected
        so its sample data no longer relies on an undeclared sidebar-02 source.
        Strict format/lint, macOS 14 compile, generic physical iOS/iPadOS 17
        compile without a simulator, registry generation, and structural
        mapping pass.
  - [ ] `VALIDATION` — floating geometry, submenu spacing, brand/navigation/
        breadcrumb actions, resizing, keyboard, accessibility, macOS, iPadOS,
        XCUITest, and snapshots not validated.
- **sidebar-05**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-05
        page, AppSidebar, and SearchForm source. It configures the shared
        documentation engine with a real accessible magnifier search field,
        static brand action, five independently collapsible parent rows,
        plus/minus state, and nested navigation. Only Build Your Application
        starts expanded, matching upstream index 1; search filters parent and
        nested destinations while preserving stored disclosure state. Every
        expansion, search, nested selection, and breadcrumb action is typed,
        current selection drives required caller detail, and the shell retains
        real Rail, persistence, and compact iPad behavior. The shared
        SCSidebarInput now exposes SCInput's composable leading-symbol slot, also
        correcting the search affordance in sidebar-01 and sidebar-02. Strict
        format/lint, macOS 14 compile, generic physical iOS/iPadOS 17 compile
        without a simulator, registry generation, and structural mapping pass.
  - [ ] `VALIDATION` — initial/open disclosure state, search filtering,
        brand/navigation/breadcrumb actions, persistence, keyboard,
        accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-07 / `SCSidebarBlock`**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-07
        page, AppSidebar, NavMain, NavProjects, NavUser, and TeamSwitcher source.
        The icon-collapsible inset shell, controlled-or-internal team/navigation
        selection, team shortcuts/add action, collapsible nested navigation,
        project selection/view/share/delete/more actions, full user menu,
        responsive actionable breadcrumb, and caller-supplied detail slot are
        implemented; every visible application action routes through the
        required typed callback, including disclosure changes. The old public
        decorative-placeholder initializer and type are removed, so real detail
        content is mandatory. Native `Menu` replaces DropdownMenu;
        `SCSidebarLayout` owns Provider/Inset/Rail, persisted open state, and compact Sheet behavior;
        `ViewThatFits` replaces the breadcrumb breakpoint; SF Symbols replace
        lucide. Strict format/lint, macOS 14 compile, device-free iOS 17 compile,
        registry generation, and structural mapping pass.
  - [ ] `VALIDATION` — collapse, navigation, team/project/user actions, persistence,
        macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-08**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-08
        page, AppSidebar, NavMain, NavProjects, NavSecondary, and NavUser
        source. It is a thin configuration of the accepted sidebar-07
        application engine with a real static Acme organization action,
        offcanvas inset shell, parent rows that navigate independently from
        separate disclosure buttons, pinned Support/Feedback navigation,
        projects and their full menus, complete user menu, responsive
        breadcrumb, persisted open state, and required caller detail. The
        shared content primitive now supports native bottom-pinning without
        losing scrolling, disclosure changes emit typed callbacks, and the
        expanded/collapsed header matches the upstream 64/48-point geometry.
        Strict format/lint, macOS 14 compile, generic physical iOS/iPadOS 17
        compile without a simulator, registry generation, and structural
        mapping pass.
  - [ ] `VALIDATION` — independent parent/disclosure actions, secondary bottom
        placement, project/user menus, header geometry, persistence, keyboard,
        accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-09**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-09
        page, nested AppSidebar, and NavUser source. The 350-point outer shell
        genuinely collapses to its 56-point permanent folder rail; the second
        pane shows the active folder, exact ten-message sample, real unread and
        sender/email/subject/teaser search filters, selectable mail summaries,
        and empty results. Folder/message/filter state can be controlled or
        internal, every organization/folder/message/breadcrumb/user action is
        typed, selection reopens the regular-width list pane, open state
        persists, and current folder/mail values drive mandatory caller detail.
        Deterministic folder membership replaces upstream's random shuffle, and
        the formerly inert Unreads switch and search input now work. Strict
        format/lint, macOS 14 compile, generic physical iOS/iPadOS 17 compile
        without a simulator, registry generation, and structural mapping pass.
  - [ ] `VALIDATION` — 350/56-point nested geometry, collapse/reopen behavior,
        folder/message/filter bindings, scrolling, user menu, persistence,
        keyboard, accessibility, macOS, iPadOS, XCUITest, and snapshots not
        validated.
- **sidebar-10**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-10
        page, AppSidebar, TeamSwitcher, NavMain, NavFavorites, NavWorkspaces,
        NavSecondary, and NavActions source. The borderless offcanvas shell has
        real team switching/add, four primary rows, all ten favorites and their
        four-action menus, all five independently disclosed workspaces with
        add/selectable-page behavior, bottom-pinned secondary navigation, and
        mandatory caller detail. The 56-point header has a real star binding
        and a controlled-or-internal anchored popover containing all thirteen
        grouped page actions; unlike the upstream showcase effect, it does not
        force itself open on mount. Every visible action is typed, selection and
        open state can persist, and `SCSidebarLayout` now exposes reusable
        divider control for the exact border-r-0 composition. Strict
        format/lint, macOS 14 compile, generic physical iOS/iPadOS 17 compile
        without a simulator, registry generation, and structural mapping pass.
  - [ ] `VALIDATION` — team/navigation/favorite/workspace/page action routing,
        independent disclosure, popover anchoring/dismissal, bottom placement,
        persistence, keyboard, accessibility, macOS, iPadOS, XCUITest, and
        snapshots not validated.
- **sidebar-11**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-11
        page, AppSidebar, and recursive Tree source. It carries the exact three
        Changes rows and complete sample tree in typed caller-replaceable
        models, with controlled-or-internal selected path and expanded folders.
        Every change/file row routes, folders independently disclose with
        semantic expanded state, components/ui start open, and the breadcrumb
        derives real parent path actions from current selection. Visible nodes
        are safely flattened by depth for SwiftUI rather than introducing a
        second tree engine or recursive opaque view, and detail is mandatory.
        Strict format/lint, macOS 14 compile, generic physical iOS/iPadOS 17
        compile without a simulator, registry generation, and structural
        mapping pass.
  - [ ] `VALIDATION` — arbitrary/deep trees, disclosure and path bindings,
        change/file/breadcrumb routing, scrolling, persistence, keyboard,
        accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-12**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-12
        page, AppSidebar, Calendars, DatePicker, and NavUser source. The exact
        October 2024 calendar, three independently disclosed calendar groups,
        real calendar toggles, new-calendar action, month/date selection, full
        account menu, dynamic month breadcrumb, and caller-owned detail are
        present. Date, month, selected calendars, and expanded groups are all
        controlled or internal; collapse mode, side, and detail header are
        reusable composition inputs. Native adaptation: `SCCalendar` and SF
        Symbols replace the web calendar and icon primitives.
  - [ ] `VALIDATION` — calendar sizing, month/date changes, disclosure, toggles,
        account and creation actions, collapse, keyboard, accessibility, macOS,
        iPadOS, XCUITest, and snapshots not validated.
- **sidebar-13**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-13
        page and AppSidebar source. The settings Dialog, title/description, all
        12 upstream destinations, Messages & media default, real navigation,
        controlled-or-internal presentation and selection, caller-supplied
        trigger, and caller-owned settings pane are present. The compact layout
        remains usable without replacing any controls with decorative rows.
        Native adaptation: SwiftUI dialog sizing replaces CSS breakpoints.
  - [ ] `VALIDATION` — dialog focus entry/return, dismissal, resizing, selection,
        keyboard, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-14**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-14
        page and AppSidebar source. The trailing offcanvas table of contents has
        all five upstream sections and 26 pages, Data Fetching default,
        controlled-or-internal selection, real row routing, current-page and
        section-aware breadcrumbs, and caller-owned document content. Models
        and callbacks are public and replaceable rather than fixed demo chrome.
  - [ ] `VALIDATION` — trailing collapse, scrolling, long content, selection,
        breadcrumbs, keyboard, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **sidebar-15**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-15
        page and dual AppSidebar composition. It genuinely composes the accepted
        sidebar-10 workspace system with sidebar-12's calendar system around
        caller-owned content; it does not redraw either as placeholder chrome.
        Team, page, workspace disclosure, date, month, calendar selection, and
        calendar disclosure can all be externally controlled, and every left
        and right action is forwarded through typed callbacks.
  - [ ] `VALIDATION` — dual-sidebar geometry, narrow resizing, both collapse
        systems, all forwarded actions, keyboard, accessibility, macOS, iPadOS,
        XCUITest, latency, and snapshots not validated.
- **sidebar-16**
  - [x] `CODE` — accepted 2026-07-14 against the complete current sidebar-16
        page, SiteHeader, and AppSidebar source. The persistent site header and
        application sidebar share one real `SCSidebarState`; its trigger,
        offcanvas collapse, organization, nested navigation, projects,
        secondary navigation, account menu, breadcrumbs, editable search, and
        Return submission are functional. Selection, expansion, search, and
        caller-owned detail remain composable through bindings and callbacks.
  - [ ] `VALIDATION` — shared header/sidebar state, search editing and submit,
        narrow resizing, focus, keyboard shortcut, accessibility, macOS, iPadOS,
        XCUITest, latency, and snapshots not validated.

### Authentication blocks

- **login-01 / `SCLoginBlock`**
  - [x] `CODE` — accepted 2026-07-14 against the complete current login-01 page
        and form source: centered Card, required email/password, forgot-password,
        Login, Google, and signup paths are present and every action has a
        required callback. Native required/email guarding and Return submission
        replace browser constraint validation; secure native input replaces the
        password input; SF Symbols replace provider artwork.
  - [ ] `VALIDATION` — keyboard, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **login-02**
  - [x] `CODE` — accepted 2026-07-14 against the complete current login-02 page
        and form source: brand/form column, adaptive media builder, required
        credentials, forgot-password, Login, GitHub, and signup actions are
        implemented. `ViewThatFits` replaces the `lg` breakpoint; the upstream
        `#` brand identity remains intentionally static.
  - [ ] `VALIDATION` — keyboard, media collapse, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **login-03**
  - [x] `CODE` — accepted 2026-07-14 against the complete current login-03 page
        and form source: muted brand page, centered Card, Apple/Google actions,
        separated required credentials, forgot-password, Login, signup, terms,
        and privacy callbacks are implemented.
  - [ ] `VALIDATION` — keyboard, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **login-04**
  - [x] `CODE` — accepted 2026-07-14 against the complete current login-04 page
        and form source: adaptive flush-media split Card, required credentials,
        forgot-password, Login, Apple/Google/Meta, signup, terms, and privacy
        callbacks are implemented. Direct Card tokens preserve the zero-inset
        media edge; `ViewThatFits` replaces the `md` breakpoint.
  - [ ] `VALIDATION` — keyboard, split layout, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **login-05**
  - [x] `CODE` — accepted 2026-07-14 against the complete current login-05 page
        and form source: accessible brand identity, signup prompt, required
        email-only Login, adaptive Apple/Google actions, terms, and privacy are
        implemented with real callbacks.
  - [ ] `VALIDATION` — keyboard, provider reflow, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **signup-01**
  - [x] `CODE` — accepted 2026-07-14 against the complete current signup-01 page
        and form source: centered Card, required name/email/password/confirmation,
        typed submission, Google, and signin callbacks are implemented. Native
        validation guards both the button and Return submission.
  - [ ] `VALIDATION` — keyboard, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **signup-02**
  - [x] `CODE` — accepted 2026-07-14 against the complete current signup-02 page
        and form source: brand/form column, adaptive media builder, four required
        fields, create-account, GitHub, and signin callbacks are implemented.
        `ViewThatFits` replaces the `lg` breakpoint.
  - [ ] `VALIDATION` — keyboard, media collapse, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **signup-03**
  - [x] `CODE` — accepted 2026-07-14 against the complete current signup-03 page
        and form source: muted brand page, centered Card, required name/email and
        paired password fields, create-account, signin, terms, and privacy
        callbacks are implemented.
  - [ ] `VALIDATION` — keyboard, paired-field layout, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **signup-04**
  - [x] `CODE` — accepted 2026-07-14 against the complete current signup-04 page
        and form source: adaptive flush-media split Card, required email and
        paired passwords, create-account, Apple/Google/Meta, signin, terms, and
        privacy callbacks are implemented. Direct Card tokens preserve the
        zero-inset media edge; `ViewThatFits` replaces the `md` breakpoint.
  - [ ] `VALIDATION` — keyboard, split layout, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.
- **signup-05**
  - [x] `CODE` — accepted 2026-07-14 against the complete current signup-05 page
        and form source: accessible brand identity, signin prompt, required
        email-only account creation, adaptive Apple/Google actions, terms, and
        privacy are implemented with real callbacks.
  - [ ] `VALIDATION` — keyboard, provider reflow, validation, accessibility, macOS, iPadOS, XCUITest, and snapshots not validated.

All ten authentication blocks pass strict format and SwiftLint, macOS 14 and
device-free iOS 17 compiles, registry generation, and structural mapping.

### Dashboard block

- **dashboard-01**
  - [x] `CODE` — accepted 2026-07-14 (reverse pass) against the complete current
        upstream block source (page, app-sidebar, nav-main/documents/secondary/
        user, site-header, section-cards, chart-area-interactive, data-table,
        data.json): `SCDashboard01Block` composes the offcanvas inset sidebar
        shell (Quick Create, Inbox, main/documents/secondary navigation with
        controlled-or-internal selection, per-document action menus, user
        account menu), site header with real GitHub link, the four section
        cards, the interactive 90/30/7-day stacked-gradient visitors chart
        with x-selection tooltip (91-point upstream series), and the 68-row
        sections table: checkbox selection, hideable columns, pagination,
        inline target/limit editing with sonner-style save toasts, reviewer
        assignment, row duplicate/delete, and a per-row drawer with the
        six-month mini chart and an editable form that submits back to the
        table. Every visible control routes through the required `onAction`.
        Native adaptations: SCSidebarLayout(.offcanvas, .inset) owns
        Provider/Inset; dnd-kit row dragging becomes keyboard-accessible
        Move up/Move down actions emitting `reorderSections`; tab badge
        counts are label text; container queries become ViewThatFits
        (toggle group ↔ select) and platform drawer edge (trailing macOS,
        bottom compact iPad, which also owns the upstream mobile 7-day
        default); SCToastCenter replaces `toast.promise`; Swift Charts
        gradients replace recharts defs; SF Symbols replace @tabler icons.
        Ledger: `dashboard-01` machine-mapped in `parity/shadcn.json`
        (checker extended to validate block structural maps).
  - [ ] `VALIDATION` — sidebar, chart interaction, table flows, drawer, toasts,
        keyboard, accessibility, macOS, and iPadOS not validated.

## Swiftcn-native blocks

- **`SCSettingsBlock`**
  - [x] `CODE` — accepted 2026-07-14 (reverse pass; Swiftcn-native, no upstream):
        profile card, preferences card, and danger zone compose accepted
        Card/Item/Avatar/Switch/Select/Field/Separator/Alert/Button/Typography
        parts. All three preferences (push, digest, appearance) are now
        controlled-or-internal bindings with caller defaults; edit-profile and
        delete-account are real optional callbacks whose controls are omitted
        when absent; profile identity is documented demo data per the block
        model. Registry deps verified complete for the single source file.
  - [ ] `VALIDATION` — actions, form state, keyboard, iPad layout, and accessibility not validated.
- **`SCDashboardBlock`**
  - [x] `CODE` — accepted 2026-07-14 (reverse pass; Swiftcn-native, no upstream):
        icon-rail sidebar, adaptive stat grid, Overview chart card, and Recent
        Sales list compose accepted Sidebar/Card/Chart/Item/Avatar/Button/
        Typography parts. Sidebar navigation is now controlled-or-internal
        (`selection` binding, `defaultSelection`, `onNavigate` callback) and
        the detail header follows the selection; download is a real optional
        callback whose button is omitted when absent; stats/revenue/sales are
        documented demo data per the block model. Stale Separator dependency
        comment removed; registry deps verified complete.
  - [ ] `VALIDATION` — layout, chart, actions, resizing, accessibility, macOS, and iPadOS not validated.
## Registry and CLI work

- [x] Generated local registry contains the current 75 local distribution items.
- [x] Native CLI supports local `list`, `view`, `add`, `init`, and `check`.
- [x] Native CLI rejects dependency cycles and path/symlink escapes.
- [ ] Decide whether `init` should write consumer configuration.
- [ ] Publish and test the canonical private registry URL before restoring any default remote.
- [ ] Decide whether prefix rewriting or third-party registries are needed.
