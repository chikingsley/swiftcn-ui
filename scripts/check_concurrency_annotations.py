#!/usr/bin/env python3
"""Reject unchecked Swift concurrency escape hatches in production sources."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "Sources" / "Swiftcn"
FORBIDDEN = {
    "@unchecked Sendable": re.compile(r"@\s*unchecked\s+Sendable"),
    "nonisolated(unsafe)": re.compile(r"nonisolated\s*\(\s*unsafe\s*\)"),
}


def main() -> int:
    matches: list[str] = []

    for path in sorted(SOURCE_ROOT.rglob("*.swift")):
        for line_number, line in enumerate(path.read_text().splitlines(), start=1):
            for annotation, pattern in FORBIDDEN.items():
                if pattern.search(line):
                    relative_path = path.relative_to(ROOT)
                    matches.append(f"{relative_path}:{line_number}: {annotation}")

    if matches:
        print("Unchecked concurrency annotations found:")
        print("\n".join(f"- {match}" for match in matches))
        print(
            "Replace each annotation with checked Sendable conformance, actor "
            "isolation, or a concurrency-safe value type."
        )
        return 1

    print("concurrency annotation check passed: no unchecked production escapes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
