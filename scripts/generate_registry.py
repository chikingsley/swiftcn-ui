#!/usr/bin/env python3
"""Generate registry.json from Sources/Swiftcn.

The registry is the machine-readable component index (the swiftcn analog of
shadcn/ui's registry.json — see docs/05-registry-cli.md). Each item lists its
source file, a description pulled from the file's first doc comment, and a
dependency graph derived from cross-file references to other items' public
SC* symbols.

Run from the repo root:  python3 scripts/generate_registry.py
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ROOT / "Sources" / "Swiftcn"

KIND_BY_DIR = {
    "Components": "registry:component",
    "Blocks": "registry:block",
    "Effects": "registry:component",
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


def main() -> None:
    files = []
    for sub in KIND_BY_DIR:
        d = SOURCES / sub
        if d.is_dir():
            files.extend(sorted(d.glob("*.swift")))

    # Pass 1: which public SC symbols does each item define?
    symbols: dict[str, set[str]] = {}
    texts: dict[str, str] = {}
    meta: dict[str, dict] = {}
    for f in files:
        item = kebab(f.stem)
        text = f.read_text()
        texts[item] = text
        symbols[item] = set(PUBLIC_TYPE.findall(text)) | set(PUBLIC_FUNC.findall(text))
        meta[item] = {
            "stem": f.stem,
            "path": str(f.relative_to(ROOT)),
            "kind": KIND_BY_DIR[f.parent.name],
        }

    # Pass 2: dependencies = other items whose symbols this file references
    # in actual code (comments stripped so doc prose can't create deps).
    items = []
    for item, text in texts.items():
        code = strip_comments(text)
        deps = {"theme"}
        for other, syms in symbols.items():
            if other == item:
                continue
            if any(re.search(rf"\b{sym}\b", code) for sym in syms):
                deps.add(other)
        # `.sc(...)` — SCButtonStyle's accessor — is too short for the
        # symbol scan; detect it directly.
        if item != "button" and re.search(r"\.sc\(", code):
            deps.add("button")
        m = meta[item]
        items.append(
            {
                "name": item,
                "type": m["kind"],
                "title": re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", m["stem"]),
                "description": doc_summary(text, m["stem"]),
                "files": [
                    {"path": m["path"], "target": f"Swiftcn/{m['stem']}.swift"}
                ],
                "registryDependencies": sorted(deps),
                "platforms": {"iOS": "17.0", "macOS": "14.0"},
            }
        )

    theme_item = {
        "name": "theme",
        "type": "registry:theme",
        "title": "Theme",
        "description": "The swiftcn design-token system: Theme struct in the SwiftUI environment, adaptive light/dark colors, the Tailwind palette, and the default zinc theme.",
        "files": [
            {"path": f"Sources/Swiftcn/Theme/{n}.swift", "target": f"Swiftcn/Theme/{n}.swift"}
            for n in ["Theme", "Theme+Default", "Palette", "Color+Adaptive", "SCPreview"]
        ],
        "registryDependencies": [],
        "platforms": {"iOS": "17.0", "macOS": "14.0"},
    }

    registry = {
        "$schema": "https://swiftcn.dev/schema/registry.json",
        "name": "swiftcn",
        "homepage": "https://github.com/Mobilecn-UI/swiftcn-ui",
        "items": [theme_item] + sorted(items, key=lambda i: (i["type"], i["name"])),
    }

    out = ROOT / "registry.json"
    out.write_text(json.dumps(registry, indent=2) + "\n")
    print(f"{len(registry['items'])} items -> {out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
