// Capture the small cross-runtime pilot fixtures, not the surrounding app.

import { spawn } from "node:child_process"
import { mkdir, rm, writeFile } from "node:fs/promises"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"
import { chromium } from "@playwright/test"

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = resolve(__dirname, "..")
const SHOTS = resolve(ROOT, "pilot-shots")
const PORT = Number(process.env.PORT ?? 4320)
const HOST = "127.0.0.1"
const fixtures = [
  { component: "accordion", state: "expanded" },
  { component: "accordion", state: "collapsed" },
  { component: "alert", state: "default" },
  { component: "alert", state: "destructive" },
]
const themes = ["light", "dark"]

function run(command, args) {
  return spawn(command, args, { cwd: ROOT, stdio: "inherit" })
}

function runToCompletion(command, args) {
  return new Promise((resolvePromise, reject) => {
    const process = run(command, args)
    process.on("exit", (code) =>
      code === 0
        ? resolvePromise()
        : reject(new Error(`${command} exited ${code}`))
    )
  })
}

async function waitForServer(url, timeoutMs = 40_000) {
  const start = Date.now()
  while (Date.now() - start < timeoutMs) {
    try {
      if ((await fetch(url)).ok) return
    } catch {
      // The preview process is still starting.
    }
    await new Promise((resolvePromise) => setTimeout(resolvePromise, 250))
  }
  throw new Error(`Server did not become ready at ${url}`)
}

async function assertFixtureState(page, fixture) {
  if (fixture.component === "accordion") {
    const expanded = await page
      .locator('[data-slot="accordion-trigger"]')
      .evaluateAll((triggers) =>
        triggers.map((trigger) => trigger.getAttribute("aria-expanded"))
      )
    const expected = fixture.state === "expanded"
      ? ["true", "false", "false"]
      : ["false", "false", "false"]
    if (JSON.stringify(expanded) !== JSON.stringify(expected)) {
      throw new Error(
        `${fixture.component}-${fixture.state}: expected ${expected}, got ${expanded}`
      )
    }
  } else {
    const alert = page.getByRole("alert")
    if ((await alert.count()) !== 1) {
      throw new Error(`${fixture.component}-${fixture.state}: missing alert role`)
    }
  }
}

async function main() {
  await runToCompletion("pnpm", ["build"])
  await rm(SHOTS, { recursive: true, force: true })
  await mkdir(SHOTS, { recursive: true })

  const baseUrl = process.env.BASE_URL ?? `http://${HOST}:${PORT}`
  const preview = process.env.BASE_URL
    ? undefined
    : run("pnpm", [
        "exec",
        "vite",
        "preview",
        "--port",
        String(PORT),
        "--strictPort",
        "--host",
        HOST,
      ])
  if (preview) await waitForServer(baseUrl)

  const browser = await chromium.launch()
  const manifest = []
  try {
    const context = await browser.newContext({
      viewport: { width: 900, height: 800 },
      deviceScaleFactor: 2,
      reducedMotion: "reduce",
    })
    const page = await context.newPage()

    for (const fixture of fixtures) {
      for (const theme of themes) {
        const suffix = theme === "dark" ? "?theme=dark" : ""
        await page.goto(
          `${baseUrl}/pilot/${fixture.component}/${fixture.state}${suffix}`,
          { waitUntil: "networkidle" }
        )
        await page.waitForFunction(
          (expectsDark) =>
            document.documentElement.classList.contains("dark") === expectsDark &&
            document.documentElement.style.colorScheme ===
              (expectsDark ? "dark" : "light"),
          theme === "dark"
        )
        await page.evaluate(async () => {
          document.documentElement.classList.add("no-anim")
          await document.fonts.ready
        })
        const root = page.locator("[data-pilot-root]")
        await root.waitFor()
        await assertFixtureState(page, fixture)
        const bounds = await root.boundingBox()
        if (!bounds) throw new Error("pilot root has no bounds")

        const file = `${fixture.component}-${fixture.state}-${theme}.png`
        await root.screenshot({
          path: resolve(SHOTS, file),
          animations: "disabled",
        })
        manifest.push({ ...fixture, theme, file, bounds })
        console.log(`[pilot] captured ${file} (${bounds.width}x${bounds.height})`)
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
  console.log(`[pilot] wrote ${manifest.length} tight screenshots to pilot-shots/`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
