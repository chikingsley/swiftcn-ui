// Screenshot every component showcase page in both light and dark themes.
//
//   node scripts/capture.mjs
//
// It builds the app if needed, starts `vite preview`, scrapes the index page
// for the list of components (the single source of truth), and writes one
// full-page PNG per component per theme into ./shots plus a manifest.json.
//
// Full-page (not element) screenshots are deliberate: shadcn overlays (Dialog,
// Popover, Select, Dropdown, ...) portal their open content to <body>, outside
// any states container, so a tight element shot would miss them.

import { spawn } from "node:child_process"
import { existsSync } from "node:fs"
import { mkdir, rm, writeFile } from "node:fs/promises"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"
import { chromium } from "@playwright/test"

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = resolve(__dirname, "..")
const SHOTS = resolve(ROOT, "shots")
const PORT = Number(process.env.PORT ?? 4319)
const HOST = "127.0.0.1"
const THEMES = ["light", "dark"]
const VIEWPORT_WIDTH = 900

function run(cmd, args, opts = {}) {
  return spawn(cmd, args, { cwd: ROOT, stdio: "inherit", ...opts })
}

function runToCompletion(cmd, args) {
  return new Promise((res, rej) => {
    const p = run(cmd, args)
    p.on("exit", (code) =>
      code === 0 ? res() : rej(new Error(`${cmd} exited ${code}`))
    )
  })
}

async function waitForServer(url, timeoutMs = 40000) {
  const start = Date.now()
  while (Date.now() - start < timeoutMs) {
    try {
      const r = await fetch(url)
      if (r.ok) return
    } catch {
      // not up yet
    }
    await new Promise((r) => setTimeout(r, 300))
  }
  throw new Error(`Server did not become ready at ${url}`)
}

async function main() {
  // 1. Build if there is no production bundle yet.
  if (!existsSync(resolve(ROOT, "dist", "index.html"))) {
    console.log("[capture] no dist/ — building...")
    await runToCompletion("pnpm", ["build"])
  }

  // 2. Start `vite preview` (unless BASE_URL points at an existing server).
  let baseUrl = process.env.BASE_URL
  let preview
  if (baseUrl) {
    console.log(`[capture] using existing server at ${baseUrl}`)
  } else {
    baseUrl = `http://${HOST}:${PORT}`
    console.log(`[capture] starting vite preview at ${baseUrl}`)
    preview = run("pnpm", [
      "exec",
      "vite",
      "preview",
      "--port",
      String(PORT),
      "--strictPort",
      "--host",
      HOST,
    ])
    await waitForServer(`${baseUrl}/`)
  }

  await rm(SHOTS, { recursive: true, force: true })
  await mkdir(SHOTS, { recursive: true })

  const browser = await chromium.launch()
  const manifest = []
  // Collect real JS errors (page throws + console.error) so a re-run can
  // definitively report whether every page is clean. Network 404s (e.g. the
  // avatar demo image) are filtered out — they are expected and benign.
  const issues = []
  let current = "startup"
  try {
    const context = await browser.newContext({
      viewport: { width: VIEWPORT_WIDTH, height: 800 },
      deviceScaleFactor: 2,
      reducedMotion: "reduce",
    })
    const page = await context.newPage()

    page.on("pageerror", (e) =>
      issues.push({ where: current, kind: "pageerror", message: String(e) })
    )
    page.on("console", (m) => {
      if (m.type() !== "error") return
      const text = m.text()
      if (text.includes("Failed to load resource")) return
      issues.push({ where: current, kind: "console.error", message: text })
    })

    // 3. Scrape the index for the component id list (single source of truth).
    current = "index"
    await page.goto(`${baseUrl}/`, { waitUntil: "networkidle" })
    await page.waitForSelector("[data-cid]")
    const ids = await page.$$eval("[data-cid]", (els) =>
      els.map((e) => e.getAttribute("data-cid"))
    )
    console.log(`[capture] ${ids.length} components:`, ids.join(", "))

    // 4. Screenshot each component in each theme.
    for (const id of ids) {
      for (const theme of THEMES) {
        const q = theme === "dark" ? "?theme=dark" : ""
        const url = `${baseUrl}/c/${id}${q}`
        current = `${id}-${theme}`
        await page.goto(url, { waitUntil: "networkidle" })
        await page.waitForSelector("[data-content]")
        await page.evaluate(() => document.fonts.ready)
        await page.waitForTimeout(200)
        const file = `${id}-${theme}.png`
        await page.screenshot({
          path: resolve(SHOTS, file),
          fullPage: true,
          animations: "disabled",
        })
        manifest.push({ component: id, theme, file })
      }
    }

    await context.close()
  } finally {
    await browser.close()
    if (preview) preview.kill("SIGTERM")
  }

  await writeFile(
    resolve(SHOTS, "manifest.json"),
    JSON.stringify(manifest, null, 2) + "\n"
  )
  console.log(
    `[capture] wrote ${manifest.length} screenshots + manifest.json to shots/`
  )

  if (issues.length) {
    console.warn(`[capture] ${issues.length} page error(s) detected:`)
    for (const i of issues) console.warn(`  - [${i.where}] ${i.kind}: ${i.message}`)
  } else {
    console.log("[capture] no page errors detected on any component page.")
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
