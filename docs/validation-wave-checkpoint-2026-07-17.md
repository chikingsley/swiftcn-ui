# Validation wave checkpoint — 2026-07-17

This document records the handoff state of the unmerged macOS validation wave
based on `b08a8b0`. It is a coding checkpoint, not acceptance evidence and not
ready to merge to `main`.

The contained shadcn comparison gallery is published independently on `main`
through `c78faf9`; the validation-wave changes remain isolated on this branch
until the blockers below are resolved. The canonical gallery path is now
`tools/shadcn-comparison-gallery`; do not recreate the removed standalone
checkout.

## Last complete macOS run

The final run completed on a calm Mac with 514 tests:

- 499 passed
- 15 failed

The failures were:

- `DatePickerValidationTests.testDateTimePickerEnablesTimeControlOnlyAfterADateIsChosen`
- `DatePickerValidationTests.testInputPickerCalendarButtonOpensAndCommitsADay`
- `DatePickerValidationTests.testInputPickerCommitsValidTextAndRejectsInvalidText`
- `DatePickerValidationTests.testNaturalLanguageParsingUpdatesWhileTyping`
- `InputGroupValidationTests.testInvalidInputGroupRemainsFunctional`
- `MessageScrollerValidationTests.testScrollButtonsToggleAccessibilityWithEdgeState`
- `NavigationMenuValidationTests.testActionInsidePopoverRoutesIntoCallerStateAndClosesTheMenu`
- `NavigationMenuValidationTests.testActiveActionExposesSelectedTraitAndStillRoutesItsAction`
- `NavigationMenuValidationTests.testLinkRoutesThroughInterceptedOpenURLAndClosesTheMenu`
- `ResizableValidationTests.testArrowKeysAdjustTheFocusedHorizontalHandle`
- `ResizableValidationTests.testArrowKeysAdjustTheFocusedVerticalHandle`
- `ResizableValidationTests.testDoubleClickResetsTheHorizontalHandleToItsInitialLayout`
- `ResizableValidationTests.testDraggingTheHorizontalHandleResizesBothPanels`
- `SidebarValidationTests.testSearchFieldRoutesTypedTextIntoCallerOwnedBinding`
- `SpinnerValidationTests.testEverySizeAppearanceAndLabelRendersAtStableGeometry`

Several failures appear to be macOS XCUITest interaction-synthesis limits, but
that classification is not acceptance. Each failure still needs either a
deterministic automated contract or an explicit manual validation item.

## Source changes under validation

- AlertDialog: Escape/cancel-action dismissal while retaining outside-click
  refusal.
- Attachment: remove the low-contrast destructive background tint.
- Message: reserve an exact invisible avatar column for grouped messages.
- MessageScroller: observe real scroll geometry on macOS 15/iOS 18 and newer.
- NativeSelect: apply `selectionDisabled` to disabled Picker options.

## Merge blockers

1. `FieldValidationTests`, `MarkerValidationTests`, and
   `ScrollAreaValidationTests` currently contain scene-wide audit matches using
   `identifier: "*"`. Replace those with exact identifiers or narrowly justified
   identifier prefixes; a scene-wide contrast waiver can hide a new defect.
2. Regenerate `Validation/SwiftcnValidation.xcodeproj` and run the separate
   `ComboboxKeyboardAccessibilityValidationTests` suite. It was added after the
   last project generation and was not part of the 514-test run.
3. Resolve or explicitly classify all 15 failing tests above, then rerun the
   complete macOS suite.
4. Add accurate `TODO.md` validation evidence only after the final run; do not
   write green ledger entries from this checkpoint.

## Machine boundary

- GMK server: primary source editing, formatting, lint, parity, registry, and
  other Linux-compatible checks.
- Mac: Xcode project generation, SwiftUI builds, XCUITest, VoiceOver/manual
  validation, and Swiftcn comparison screenshots.

## Comparison review surface

- `Showcase/Scripts/capture-comparison.sh` builds the Showcase once, launches a
  deterministic component/appearance mode, and captures only the launched
  process via ScreenCaptureKit.
- The current set contains 51 components in light and dark at 1800 x 1600.
- GMK serves the side-by-side gallery at `http://gmk-server:4174/` from the
  contained tool at
  `/home/simon/github/swiftcn-ui/tools/shadcn-comparison-gallery`.
- Every match, mismatch, reversal, and note is saved directly on GMK in the
  gitignored `gallery/review-state.json` file. The same state reloads across
  browsers and is readable through `http://gmk-server:4174/api/review-state`;
  no manual export is required.
- Combobox, Dropdown Menu, Menubar, Select, and Tooltip currently show the
  Swiftcn rest state. Context Menu shows the rest state on both sides. Their
  open/hover behavior remains an interactive validation item and is labeled as
  such in the gallery manifest.

The gallery is a review aid. Its screenshots do not replace the merge blockers
or runtime/assistive-technology gates above.
