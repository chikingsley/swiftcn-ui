import { existsSync, readFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..")
const galleryRoot = resolve(repoRoot, "gallery")
const html = readFileSync(resolve(galleryRoot, "index.html"), "utf8")
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)]

if (scripts.length !== 1) {
  throw new Error(`Expected one inline gallery script, found ${scripts.length}`)
}
new Function(scripts[0][1])
if (!html.includes('const API = "./api/review-state"')) {
  throw new Error("Gallery is not connected to the server-backed review API")
}
if (!html.includes('method:"PATCH"')) {
  throw new Error("Gallery does not persist per-state review updates")
}
if (html.includes('id="export"')) {
  throw new Error("Gallery still exposes the retired JSON export workflow")
}

for (const requiredPath of [
  resolve(repoRoot, "ops/gallery_server.py"),
  resolve(repoRoot, "ops/test_gallery_server.py"),
]) {
  if (!existsSync(requiredPath)) {
    throw new Error(`Missing gallery persistence file: ${requiredPath}`)
  }
}

const manifest = JSON.parse(
  readFileSync(resolve(galleryRoot, "comparisons.json"), "utf8"),
)
const componentIDs = manifest.components.map((component) => component.id)
if (new Set(componentIDs).size !== componentIDs.length) {
  throw new Error("Gallery manifest contains duplicate component IDs")
}

const states = manifest.components.flatMap((component) => component.states)
const imagePaths = states.flatMap((state) => [state.shadcn, state.swiftcn])
if (new Set(imagePaths).size !== imagePaths.length) {
  throw new Error("Gallery manifest contains duplicate image paths")
}

function imageSize(imagePath) {
  const absolutePath = resolve(galleryRoot, imagePath)
  if (!existsSync(absolutePath)) {
    throw new Error(`Missing gallery image: ${imagePath}`)
  }

  const png = readFileSync(absolutePath)
  return { width: png.readUInt32BE(16), height: png.readUInt32BE(20) }
}

for (const component of manifest.components) {
  for (const state of component.states) {
    const shadcn = imageSize(state.shadcn)
    const swiftcn = imageSize(state.swiftcn)
    const isPilot = state.shadcn.startsWith("shadcn-pilot/")

    if (isPilot) {
      if (shadcn.width !== swiftcn.width || shadcn.width < 900) {
        throw new Error(
          `${component.id}/${state.id} pilot widths differ or are too small: ` +
          `shadcn ${shadcn.width}px, swiftcn ${swiftcn.width}px`,
        )
      }
      if (shadcn.height < 100 || swiftcn.height < 100) {
        throw new Error(`${component.id}/${state.id} pilot capture is empty`)
      }
      continue
    }

    if (shadcn.width !== 1800 || shadcn.height < 1600) {
      throw new Error(
        `${state.shadcn} is ${shadcn.width}x${shadcn.height}; ` +
        "expected 1800px wide and at least 1600px high",
      )
    }
    if (swiftcn.width !== 1800 || swiftcn.height !== 1600) {
      throw new Error(
        `${state.swiftcn} is ${swiftcn.width}x${swiftcn.height}; expected 1800x1600`,
      )
    }
  }
}

console.log(
  `gallery check: ${manifest.components.length} components, ${states.length} states, ` +
  `${imagePaths.length} images; pilot pairs are tight and width-matched`,
)
