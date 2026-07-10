# Roadmap: the big list

Every shadcn/ui component (all 64, per the July 2026 docs), mapped to a SwiftUI build strategy, sized, and prioritized. This is the kill list — work top to bottom within each phase.

**Legend**
- **Strategy** — `style`: restyle a native SwiftUI primitive via a Style protocol · `custom`: no primitive exists, build the structure · `doc`: dissolves into a native API; ship a docs page, not a file · `pattern`: composition of other swiftcn components
- **Effort** — S: ≤ half a day · M: 1–2 days · L: multi-day
- **Priority** — P0: foundation/core · P1: expected in any real app · P2: differentiators · P3: nice-to-have / niche platform
- **Status** — ✅ exists (needs rebuild onto 2.0 architecture) · 🚧 was WIP · ❌ not started

---

## Phase 0 — Foundation (everything depends on this)

No components ship until this exists. Detail in `02-architecture.md`.

| # | Work item | Effort | Notes |
|---|---|---|---|
| 0.1 | `Theme` struct + Environment key + `.theme()` modifier | S | token names ≙ shadcn: background/foreground pairs, border, input, ring, radius |
| 0.2 | `Palette.swift` — Tailwind color constants (zinc, red, etc.) | S | mechanical port; gives all components one color vocabulary |
| 0.3 | `Color(light:dark:)` adaptive initializer | S | kills every `colorScheme == .dark` conditional |
| 0.4 | `Theme.default` (zinc) | S | port of shadcn's default theme (`--radius: 0.625rem` → 10pt) |
| 0.5 | `SCPreview` wrapper for consistent previews | S | see `03-previews.md` |
| 0.6 | Repo restructure: `Sources/Swiftcn/` + SPM manifest, keep `.swiftpm` playground | M | playground becomes a consumer |
| 0.7 | Raise floor to iOS 17, adopt `#Preview`/`@Previewable` everywhere | S | |
| 0.8 | Showcase app skeleton (`ComponentCatalog`, NavigationSplitView shell) | M | grows with every component after |
| 0.9 | CONTRIBUTING.md: component checklist + file anatomy template | S | makes drive-by PRs conform |

## Phase 1 — Rebuild the existing 13 on the foundation

Proves the architecture; every one is small because the foundation does the heavy lifting.

| # | Component | Strategy | Effort | Status | Notes |
|---|---|---|---|---|---|
| 1.1 | Button | style (`ButtonStyle`) | S | ✅ | 6 variants × 4 sizes; pressed = `opacity(0.85)`; disabled via `isEnabled` |
| 1.2 | Badge | custom | S | ✅ | variants: default/secondary/destructive/outline |
| 1.3 | Card | custom (slots) | S | ✅ | Header/Title/Description/Content/Footer sub-views |
| 1.4 | Input | custom over `TextField` | M | ✅ | keep `InputConvertible` sugar; absorb `InputBoxModifier`; focus ring via `theme.ring` |
| 1.5 | Textarea | custom over `TextEditor` | S | ✅🚧 | rename from CustomTextEditor |
| 1.6 | Switch | style (`ToggleStyle`) | S | ✅ | rename from CustomToggle; fix hand-rolled tap gesture (a11y) |
| 1.7 | Progress | style (`ProgressViewStyle`) | S | ✅ | |
| 1.8 | Slider | style/custom | S | ✅ | theme-tinted; custom track later if needed |
| 1.9 | Avatar | custom | S | ✅ | size presets sm/default/lg; add `SCAvatarGroup` (overlap stack) |
| 1.10 | Tabs | custom | M | ✅ | kill `AnyView` API; `matchedGeometryEffect` underline; variants: underline/pill (segmented) |
| 1.11 | Skeleton | custom modifier | S | 🚧 | `.skeleton(when:)` — shape-aware placeholder + shimmer |
| 1.12 | ShimmerButton → Effects/ | custom | S | ✅ | reclassify as effect, not component |
| 1.13 | DotPattern → Effects/ | custom (`Canvas`) | S | ✅ | rewrite with Canvas (current O(n²) ForEach) |

## Phase 2 — Core kit (what every real app needs next)

| # | Component | Strategy | Effort | Priority | Notes |
|---|---|---|---|---|---|
| 2.1 | Separator | custom (themed Divider) | S | P0 | horizontal/vertical, optional label |
| 2.2 | Label | style (`LabeledContentStyle`) | S | P0 | |
| 2.3 | **Field** | custom | M | P0 | label + control + description + error message; form-library-agnostic (shadcn replaced Form with this) |
| 2.4 | Checkbox | style (`ToggleStyle`) | S | P0 | box + checkmark animation |
| 2.5 | Alert (callout) | custom | S | P0 | default/destructive variants; icon + title + description |
| 2.6 | **Sidebar** | custom | L | **P0** | the flagship — see breakout below |
| 2.7 | Radio Group | custom | M | P1 | single-selection group, `Picker`-like API with ViewBuilder rows |
| 2.8 | Select | custom (Menu-backed) | M | P1 | themed trigger + native `Menu` for the list; Native Select = `Picker` doc |
| 2.9 | Input OTP | custom | M | P1 | huge iOS relevance; integrate `.textContentType(.oneTimeCode)` |
| 2.10 | Toast (Sonner-style) | custom presenter | L | P1 | no native primitive; overlay window/root modifier + queue; swipe to dismiss |
| 2.11 | Spinner | style (`ProgressViewStyle`) | S | P1 | |
| 2.12 | Empty | custom | S | P1 | styled `ContentUnavailableView` analog: icon/title/description/action slots |
| 2.13 | Item | custom | S | P1 | generic row: leading/title/description/trailing — feeds List, Sidebar, Command |
| 2.14 | Accordion | style (`DisclosureGroupStyle`) | S | P1 | single/multiple-open modes |
| 2.15 | Collapsible | custom | S | P1 | trigger + content, animated |
| 2.16 | Dialog | custom overlay | L | P1 | centered modal with dim; native `alert()` is too constrained for arbitrary content |
| 2.17 | Alert Dialog | pattern (Dialog preset) | S | P1 | confirm/cancel action row |
| 2.18 | Drawer | custom over `.sheet` | S | P1 | `presentationDetents` + themed grabber — the easiest big win in the list |
| 2.19 | Popover | custom over `.popover` | S | P1 | `.presentationCompactAdaptation(.popover)` to keep popover on iPhone |
| 2.20 | Typography | doc + Font tokens | S | P1 | `Text` extensions: `.h1()…`, `.lead()`, `.muted()` |

### Sidebar breakout (2.6)

shadcn's most composable component (~20 parts) and the thing that makes dashboard blocks possible. SwiftUI translation:

| shadcn part | swiftcn |
|---|---|
| `SidebarProvider` (open state, cookie persistence, ⌘B) | `@Observable SCSidebarState` in Environment; `@AppStorage`/`SceneStorage` persistence; `.keyboardShortcut("b", modifiers: .command)` |
| `Sidebar` `side:` `variant: sidebar/floating/inset` `collapsible: offcanvas/icon/none` | custom HStack layout (not `NavigationSplitView` — we need icon-rail collapse, which it can't do); width animation for icon mode |
| Mobile → Sheet | compact size class → `.sheet` presentation, automatic |
| Header/Content/Footer, Group(+Label/Action), Menu/MenuItem/MenuButton(+Badge/Action/Sub), Trigger, Rail, Inset, Separator, Input | direct sub-view ports; MenuButton shows tooltip-style flyout when icon-collapsed |
| `useSidebar` hook | `@Environment(\.sidebarState)` |
| `--sidebar*` token family | `theme.sidebar`, `theme.sidebarForeground`, `sidebarPrimary`, `sidebarAccent`, `sidebarBorder`, `sidebarRing` — add to `Theme` when this lands |

Ship with **sidebar-07** (icon-collapse) as the reference demo — it's the shadcn flagship block, and the Showcase app itself should run on it.

## Phase 3 — Differentiators

| # | Component | Strategy | Effort | Priority | Notes |
|---|---|---|---|---|---|
| 3.1 | Sheet (edge panel) | custom | M | P2 | leading/trailing/top/bottom slide-over; distinct from Drawer |
| 3.2 | Command (⌘K palette) | custom | L | P2 | search + grouped results + keyboard nav; killer on iPad/Mac; reuses Item |
| 3.3 | Combobox | pattern (Popover+Command) | M | P2 | |
| 3.4 | Calendar | custom | L | P2 | month grid, single/range selection; native `DatePicker(.graphical)` can't theme or range-select |
| 3.5 | Date Picker | pattern (Popover+Calendar) | S | P2 | after 3.4 |
| 3.6 | Toggle | style | S | P2 | pressed-state button (`.toggleStyle(.button)` themed) |
| 3.7 | Toggle Group | custom | M | P2 | single/multiple select; segmented look |
| 3.8 | Button Group | custom | S | P2 | attached buttons, split-button |
| 3.9 | Input Group | custom | M | P2 | prefix/suffix addons around Input |
| 3.10 | Chart | style over Swift Charts | M | P2 | `chart1…chart5` theme tokens, themed axes/legend/tooltip — Swift Charts does the rest |
| 3.11 | Carousel | custom (paging ScrollView) | M | P2 | `.scrollTargetBehavior(.paging)` + indicators + prev/next |
| 3.12 | Breadcrumb | custom | S | P2 | mostly iPad/Mac |
| 3.13 | Dropdown Menu | style/doc over `Menu` | M | P2 | native Menu theming is limited — document limits, custom popover menu for full control |
| 3.14 | Context Menu | doc over `.contextMenu` | S | P2 | |
| 3.15 | Table | style over SwiftUI `Table` | L | P2 | iPad/Mac; compact-width falls back to List of Items |
| 3.16 | Chat suite: Message, Bubble, Attachment, Message Scroller, Marker | custom | L | P2 | shadcn's June 2026 additions — arguably *more* at home on iOS than web |
| 3.17 | Tooltip | custom | M | P3 | `.help()` on Mac; long-press flyout on touch |
| 3.18 | Kbd | custom | S | P3 | shortcut chip, iPad/Mac |
| 3.19 | Pagination | custom | S | P3 | |
| 3.20 | Hover Card | custom | M | P3 | pointer platforms only |
| 3.21 | Resizable | custom | L | P3 | split panes; Mac `HSplitView`, custom drag on iPad |
| 3.22 | Data Table | pattern doc (Table + sort/select) | L | P3 | |
| 3.23 | Menubar | doc (`.commands` on Mac) | S | P3 | |
| 3.24 | More Effects (magicui-style) | custom | ongoing | P3 | grid/dot patterns, marquee, animated gradients, number ticker |

**Dissolves into a doc page** (no file shipped): Aspect Ratio (`.aspectRatio`), Scroll Area (`ScrollView`), Direction/RTL (`layoutDirection` — free in SwiftUI), Navigation Menu (web-specific; map to toolbar/Menu), Form (superseded by Field), Native Select (`Picker`).

## Phase 4 — Blocks (composition proves the system)

shadcn blocks are just registry items whose dependencies pull in components. Each is a single file in `Sources/Swiftcn/Blocks/` + a Showcase page.

| Block | Composes | Priority |
|---|---|---|
| `login-01` … `login-03` | Card, Field, Input, Button, Separator | P1 — first block, minimal deps |
| `sidebar-07` (icon collapse) | Sidebar family | P1 — ships with Sidebar |
| `settings-01` | Sidebar/Tabs, Field, Switch, Select, Separator | P1 — every iOS app has one |
| `dashboard-01` | Sidebar, Card, Chart, Table/Item list, Badge | P2 — the flagship screenshot |
| `onboarding-01` | Carousel, Button, Typography | P2 — iOS-specific, no shadcn analog |
| `paywall-01` | Card, Badge, Button, Effects | P2 — iOS-specific, no shadcn analog |
| `chat-01` | Chat suite, Input Group, Avatar | P2 |

## Phase 5 — Distribution (registry + CLI)

Detail in `05-registry-cli.md`.

| # | Work item | Effort |
|---|---|---|
| 5.1 | `registry.json` + per-component `registry/<name>.json` (ported shadcn schema) | M |
| 5.2 | `swiftcn` CLI: `list`, `view`, `add <name>` (resolve `registryDependencies` topologically, copy files) | L |
| 5.3 | `swiftcn init` (adds Theme/ to a project, writes `swiftcn.json` config) | M |
| 5.4 | GitHub-as-registry: `swiftcn add owner/repo/component` | M |
| 5.5 | Homebrew tap / `mint` install | S |

---

## Suggested kill order (first ~12 PRs)

1. **PR 1 — Foundation**: 0.1–0.5 (Theme, Palette, adaptive Color, default theme, SCPreview)
2. **PR 2 — Restructure**: 0.6–0.8 (SPM layout, iOS 17, Showcase shell)
3. **PR 3 — Button + Badge** on the new system (sets the file-anatomy precedent)
4. **PR 4 — Card + Separator + Typography**
5. **PR 5 — Input + Textarea + Label + Field**
6. **PR 6 — Switch + Checkbox + Slider + Progress + Spinner**
7. **PR 7 — Tabs + Accordion + Collapsible**
8. **PR 8 — Skeleton + Empty + Alert + Item**
9. **PR 9 — Avatar (+Group) + effects reclassification**
10. **PR 10 — Sidebar** (the big one) **+ sidebar-07 block**, Showcase adopts it
11. **PR 11 — Drawer + Popover + Dialog + Alert Dialog**
12. **PR 12 — Toast** + `login-01` + `settings-01` blocks

After PR 12 the library covers ~30 components + 3 blocks — more than enough surface to launch "swiftcn 2.0", update the Mintlify docs, and let the community pull Phase 3 items by demand.

## Scorecard

| | count |
|---|---|
| shadcn components mapped | 64 |
| → build as component/style | ~48 |
| → dissolve into doc pages | 6 |
| → skip (web-only) | ~2 |
| swiftcn-only additions | effects + onboarding/paywall/chat blocks |
| exists today (to rebuild) | 13 |
