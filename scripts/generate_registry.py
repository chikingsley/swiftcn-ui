#!/usr/bin/env python3
"""Generate registry.json from Sources/Swiftcn.

The registry is the machine-readable component index (the swiftcn analog of
shadcn/ui's registry.json). Each item lists its
source file, a description pulled from the file's first doc comment, and a
dependency graph derived from cross-file references to other items' public
SC* symbols.

Run from the repo root:  python3 scripts/generate_registry.py
"""

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ROOT / "Sources" / "Swiftcn"

KIND_BY_DIR = {
    "Components": "registry:component",
    "Blocks": "registry:block",
    "Effects": "registry:component",
    "Audio": "registry:component",
}

# A shadcn component is the distribution unit even when Swift linting or source
# organization requires several files. Supplemental files remain part of the
# single `sidebar` registry item.
ITEM_BY_STEM = {
    "AlertDialogModifier": "alert-dialog",
    "ComboboxCollection": "combobox",
    "ComboboxControls": "combobox",
    "ComboboxConvenience": "combobox",
    "ComboboxFlowLayout": "combobox",
    "ComboboxPicker": "combobox",
    "ComboboxRowAction": "combobox",
    "FieldFeedback": "field",
    "FieldInvalidState": "field",
    "DrawerParts": "drawer",
    "DrawerPresentation": "drawer",
    "InputTyped": "input",
    "ItemParts": "item",
    "ItemContentParts": "item",
    "SelectConvenience": "select",
    "SelectParts": "select",
    "SelectRendering": "select",
    "SheetParts": "sheet",
    "SheetPresentation": "sheet",
    "SidebarMenuExtras": "sidebar",
    "SidebarState": "sidebar",
    "ToggleGroupConvenience": "toggle-group",
    "ToggleGroupItem": "toggle-group",
    "HoverCardState": "hover-card",
    "ProgressStyle": "progress",
    "SidebarSections": "sidebar",
    "SidebarMenu": "sidebar",
    "SidebarControls": "sidebar",
    "TranscriptViewerControls": "transcript-viewer",
    "TranscriptViewerModels": "transcript-viewer",
    "TranscriptViewerWords": "transcript-viewer",
    "WaveformLiveRecording": "waveform",
    "WaveformMicrophone": "waveform",
    "WaveformRecording": "waveform",
    "WaveformScrolling": "waveform",
    "WaveformScrubber": "waveform",
}

# Swift package (SPM) dependencies per item, emitted as the official schema's
# `dependencies` field the way shadcn items declare npm packages
# (`name@version`). Only thin registry components wrapping an engine may
# declare one — see docs/architecture.md, "Package dependencies for engine
# wrappers". The package URL and product are documented in the item's source
# file header for consumers who vendor the file.
PACKAGE_DEPENDENCIES_BY_ITEM = {
    # https://github.com/gonzalezreal/swift-markdown-ui (product: MarkdownUI)
    "response": ["swift-markdown-ui@2.4.1"],
}

# Compound registry files often declare public payload/context types before
# their root view. Keep their catalog copy intentional instead of depending on
# declaration order.
DESCRIPTION_BY_ITEM = {
    "input-group-context": "Internal focus and validation coordination shared by Input, Textarea, and Input Group.",
    "scrub-bar": "A compound playback scrubber with a draggable track, progress fill, thumb, and time labels.",
    "transcript-viewer": "A time-synced transcript viewer with word highlighting, playback controls, and scrubbing.",
}

# Copy-distribution dependencies that cannot be inferred from public symbols.
# Keep these explicit instead of making internal coordination types public or
# forcing independently installable components into a dependency cycle.
EXPLICIT_DEPENDENCIES_BY_ITEM = {
    "input": {"input-group-context"},
    "input-group": {"input-group-context"},
    "textarea": {"input-group-context"},
}

PUBLIC_TYPE = re.compile(
    r"public\s+(?:struct|enum|final class|class|protocol)\s+(SC\w+|InputConvertible)"
)
# Members of `public extension` blocks inherit public without the keyword,
# so match any sc-prefixed func/var declaration (scChartStyle, scSwitch, …).
PUBLIC_FUNC = re.compile(r"(?:static\s+)?(?:func|var)\s+(sc[A-Z]\w*)")
DOC_LINE = re.compile(r"^\s*///\s?(.*)$")


def kebab(name: str) -> str:
    s = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "-", name)
    return s.lower()


def strip_comments(text: str) -> str:
    """Remove comment lines so doc prose can't create false dependencies."""
    return "\n".join(
        line for line in text.splitlines() if not line.lstrip().startswith("//")
    )


def strip_previews(text: str) -> str:
    """Return the production portion of a component source file."""
    positions = [
        text.find(marker)
        for marker in ("// MARK: - Previews", "// MARK: Previews")
        if marker in text
    ]
    return text[: min(positions)] if positions else text


def dependencies_for(item: str, text: str, symbols: dict[str, set[str]]) -> set[str]:
    code = strip_comments(text)
    deps = set()
    if re.search(r"@Environment\s*\(\s*\\\.theme\b|\bSCPreview\b|\.theme\s*\(", code):
        deps.add("theme")
    referenced_symbols = set(
        re.findall(r"\b(?:SC\w+|InputConvertible|sc[A-Z]\w*)\b", code)
    )
    for other, syms in symbols.items():
        if other == item:
            continue
        if referenced_symbols.intersection(syms):
            deps.add(other)
    if item != "button" and re.search(r"\.sc\(", code):
        deps.add("button")
    return deps


def doc_summary(text: str, stem: str) -> str:
    """First sentence of the doc block on the file's main declaration.

    Prefers the /// block immediately preceding `public struct SC<stem>` (or
    the first public SC declaration / View extension); falls back to the first
    /// block in the file.
    """
    lines = text.splitlines()
    anchors = [
        re.compile(rf"public\s+(?:struct|final class|class)\s+SC{re.escape(stem)}\b"),
        re.compile(r"public\s+(?:struct|final class|class)\s+SC\w+"),
        re.compile(r"\bfunc\s+sc\w+"),
        re.compile(r"public\s+(?:struct|enum|final class|class|protocol)\s+\w+"),
    ]

    def block_above(idx: int) -> list[str]:
        """Contiguous /// block above idx, skipping @attribute lines."""
        block: list[str] = []
        n = idx - 1
        while n >= 0 and lines[n].lstrip().startswith("@"):
            n -= 1
        while n >= 0:
            m = DOC_LINE.match(lines[n])
            if not m:
                break
            block.insert(0, m.group(1).strip())
            n -= 1
        return block

    for anchor in anchors:
        for n, line in enumerate(lines):
            if not anchor.search(line):
                continue
            prose = []
            for entry in block_above(n):
                if not entry:  # blank doc line ends the summary paragraph
                    break
                if entry.startswith(("- ", "* ")) or entry.lstrip().startswith(("SCDialog", "Button(")):
                    break
                prose.append(entry)
            summary = " ".join(prose).split(". ")[0].rstrip(".")
            if summary:
                return summary + "."
    return ""


def validate_registry(registry: dict) -> None:
    """Reject incomplete generated items before they become distributable."""
    items = registry["items"]
    names = [item["name"] for item in items]
    duplicate_names = sorted({name for name in names if names.count(name) > 1})
    if duplicate_names:
        raise SystemExit(f"duplicate registry items: {', '.join(duplicate_names)}")

    known_names = set(names)
    unknown_packages = set(PACKAGE_DEPENDENCIES_BY_ITEM) - known_names
    if unknown_packages:
        raise SystemExit(
            "package dependencies declared for unknown items: "
            + ", ".join(sorted(unknown_packages))
        )
    source_paths: set[str] = set()
    for item in items:
        if not item["description"]:
            raise SystemExit(f"registry item {item['name']!r} needs a public doc summary")
        if not item["files"]:
            raise SystemExit(f"registry item {item['name']!r} has no source files")
        unknown_dependencies = set(item["registryDependencies"]) - known_names
        if unknown_dependencies:
            raise SystemExit(
                f"registry item {item['name']!r} has unknown dependencies: "
                + ", ".join(sorted(unknown_dependencies))
            )
        for file in item["files"]:
            if file["path"] in source_paths:
                raise SystemExit(f"registry source is published twice: {file['path']}")
            source_paths.add(file["path"])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit nonzero instead of rewriting registry.json when it is stale.",
    )
    args = parser.parse_args()

    files = []
    for sub in KIND_BY_DIR:
        d = SOURCES / sub
        if d.is_dir():
            files.extend(sorted(d.glob("*.swift")))

    # Pass 1: which public SC symbols does each item define?
    symbols: dict[str, set[str]] = {}
    texts: dict[str, list[str]] = {}
    meta: dict[str, dict] = {}
    for f in files:
        item = ITEM_BY_STEM.get(f.stem, kebab(f.stem))
        text = f.read_text()
        texts.setdefault(item, []).append(text)
        symbols.setdefault(item, set()).update(PUBLIC_TYPE.findall(text))
        symbols[item].update(PUBLIC_FUNC.findall(text))
        entry = meta.setdefault(
            item,
            {
                "stem": "Sidebar" if item == "sidebar" else f.stem,
                "kind": KIND_BY_DIR[f.parent.name],
                "files": [],
            },
        )
        entry["files"].append(
            {
                "path": str(f.relative_to(ROOT)),
                "type": KIND_BY_DIR[f.parent.name],
                "target": f"Swiftcn/{f.stem}.swift",
            }
        )

    # Pass 2: dependencies = other items whose symbols this file references
    # in actual code (comments stripped so doc prose can't create deps).
    items = []
    for item, source_texts in texts.items():
        text = "\n".join(source_texts)
        production_text = "\n".join(strip_previews(source) for source in source_texts)
        explicit_deps = EXPLICIT_DEPENDENCIES_BY_ITEM.get(item, set())
        production_deps = dependencies_for(item, production_text, symbols) | explicit_deps
        all_deps = dependencies_for(item, text, symbols) | explicit_deps
        preview_deps = all_deps - production_deps
        m = meta[item]
        record = {
            "name": item,
            "type": m["kind"],
            "title": re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", m["stem"]),
            "description": DESCRIPTION_BY_ITEM.get(item, doc_summary(text, m["stem"])),
        }
        if item in PACKAGE_DEPENDENCIES_BY_ITEM:
            record["dependencies"] = PACKAGE_DEPENDENCIES_BY_ITEM[item]
        record.update(
            {
                "files": sorted(m["files"], key=lambda entry: entry["path"]),
                "registryDependencies": sorted(all_deps),
                "meta": {
                    "swiftcnDependencies": sorted(production_deps),
                    "swiftcnPreviewDependencies": sorted(preview_deps),
                },
                "platforms": {"iOS": "17.0", "macOS": "14.0"},
            }
        )
        items.append(record)

    theme_item = {
        "name": "theme",
        "type": "registry:theme",
        "title": "Theme",
        "description": "The swiftcn design-token system: Theme struct in the SwiftUI environment, adaptive light/dark colors, the Tailwind palette, and the default zinc theme.",
        "files": [
            {
                "path": f"Sources/Swiftcn/Theme/{n}.swift",
                "type": "registry:theme",
                "target": f"Swiftcn/Theme/{n}.swift",
            }
            for n in ["Theme", "Palette", "Color+Adaptive", "SCPreview"]
        ],
        "registryDependencies": [],
        "meta": {
            "swiftcnDependencies": [],
            "swiftcnPreviewDependencies": [],
        },
        "platforms": {"iOS": "17.0", "macOS": "14.0"},
    }

    registry = {
        "$schema": "https://ui.shadcn.com/schema/registry.json",
        "name": "swiftcn",
        "homepage": "https://github.com/chikingsley/swiftcn-ui",
        "items": [theme_item] + sorted(items, key=lambda i: (i["type"], i["name"])),
    }
    validate_registry(registry)

    out = ROOT / "registry.json"
    rendered = json.dumps(registry, indent=2) + "\n"
    if args.check:
        if not out.exists() or out.read_text() != rendered:
            print(f"{out.relative_to(ROOT)} is stale; run scripts/generate_registry.py")
            raise SystemExit(1)
        print(f"{out.relative_to(ROOT)} is current ({len(registry['items'])} items)")
        return

    out.write_text(rendered)
    print(f"{len(registry['items'])} items -> {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
