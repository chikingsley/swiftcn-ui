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

for (const imagePath of imagePaths) {
  const absolutePath = resolve(galleryRoot, imagePath)
  if (!existsSync(absolutePath)) {
    throw new Error(`Missing gallery image: ${imagePath}`)
  }

  const png = readFileSync(absolutePath)
  const width = png.readUInt32BE(16)
  const height = png.readUInt32BE(20)
  const isSwiftcn = imagePath.startsWith("swiftcn/")
  const expectedHeight = isSwiftcn ? height === 1600 : height >= 1600
  if (width !== 1800 || !expectedHeight) {
    const expectation = isSwiftcn ? "1800x1600" : "1800px wide and at least 1600px high"
    throw new Error(`${imagePath} is ${width}x${height}; expected ${expectation}`)
  }
}

console.log(
  `gallery check: ${manifest.components.length} components, ${states.length} states, ${imagePaths.length} images, all 1800px wide`,
)
