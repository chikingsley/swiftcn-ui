# swiftcn-shadcn-ref

A durable **Vite + React + TypeScript + shadcn/ui** reference and review
workspace for `swiftcn-ui`. It renders fixed official-source states, stores both
image sets, and provides a side-by-side gallery with per-state verdicts and
notes.

- Style: shadcn **new-york** (radix-based), the classic look the port mirrors.
- Theme: **zinc** base color, CSS variables (matches the port's zinc theme).
- Every route supports **dark mode** via `?theme=dark`.
- Overlays (Dialog, Select, Popover, Dropdown, Sheet, Drawer, ...) are rendered
  **open by default** so the screenshot captures the open state.

This gallery is review evidence, not an automated parity verdict. Build/tests,
source-parity checks, and interactive macOS validation remain separate gates in
the Swift package.

## Install

```bash
cd /home/simon/github/swiftcn-shadcn-ref
pnpm install
```

## Run the dev server

```bash
pnpm dev
```

Then open:

- `http://localhost:5173/` — index of every component
- `http://localhost:5173/c/<component-id>` — a component's states
- add `?theme=dark` to any route for dark mode, e.g.
  `http://localhost:5173/c/dialog?theme=dark`

## Capture screenshots

```bash
pnpm capture
```

This builds the app, starts `vite preview`, and for every component page (both
light and dark) writes a full-page PNG to `shots/`, plus `shots/manifest.json`
listing `{ component, theme, file }` for each shot.

- Fixed viewport width **900px**, `deviceScaleFactor: 2` (crisp 2x images).
- Runs headless (Playwright + Chromium). Animations disabled for stable frames.
- Output: `shots/<component-id>-<theme>.png` and `shots/manifest.json`.

To re-run against an already-running server instead of spawning `vite preview`:

```bash
BASE_URL=http://localhost:5173 node scripts/capture.mjs
```

## Refresh the comparison gallery

The two sides intentionally come from different machines:

- GMK captures the official React/shadcn reference with `pnpm capture`.
- A Mac captures the native SwiftUI Showcase with
  `Showcase/Scripts/capture-comparison.sh` in the `swiftcn-ui` repo.

After the Mac capture passes its count, filename, and dimension checks, sync it
to this server:

```bash
rsync -av --delete \
  Showcase/.comparison-shots/ \
  gmk-server:/home/simon/github/swiftcn-shadcn-ref/gallery/swiftcn/
```

The gallery manifest is `gallery/comparisons.json`. Both sets are 1800px wide;
Swiftcn uses a fixed 1600px-high canvas, while the shadcn reference keeps taller
full-page captures where needed. Known rest-state-only captures are called out
in the manifest so a still image is not mistaken for open-state or interaction
proof.

## Review gallery

The persistent GMK service is versioned under `ops/`; setup and audit commands
are in `ops/README.md`. Once enabled, open:

- `http://gmk-server:4174/`

Verdicts and notes remain in browser local storage until exported. Use **export
verdicts JSON** before clearing browser data or moving to another browser.

## How it's wired

- `src/showcases/registry.tsx` — the single source of truth: an array of
  `{ id, title, Component }`. The index page, the `/c/:id` routes, and the
  capture script (which scrapes the index for `[data-cid]`) all derive from it.
- `src/showcases/<id>.tsx` — one file per component, a vertical stack of
  `<StateRow label="...">` blocks (see `src/lib/showcase.tsx`).
- `src/lib/use-theme.ts` — reads `?theme=dark` and toggles `.dark` on `<html>`.
- `scripts/capture.mjs` — the Playwright screenshot script.

## Notes / limitations

- **context-menu** has no forced-open API (it needs a real right-click), so its
  page shows the rest state only.
- **sidebar** is rendered with `collapsible="none"` so the app-shell sidebar
  embeds inline as one deterministic screenshot.
- **sonner** toasts are pinned open (`duration: Infinity`) and fired on mount.
- Font is Geist (shadcn's default); the port uses the SF system font, so text
  metrics differ — expected, and orthogonal to the component visuals.
