#!/usr/bin/env python3
"""Check the complete shadcn inventory and machine structural maps.

The catalog/coverage pass makes missing code explicit for every current
official component and block. Detailed structural maps additionally prove
that declared Swift symbols and production dependencies still exist. This does
not perform or approve the item-by-item CODE review, and it does not claim
runtime parity; those separate gates are tracked in TODO.md.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "parity" / "shadcn.json"
REGISTRY = ROOT / "registry.json"
DOCS_PREFIX = "https://ui.shadcn.com/docs/components/"
BLOCK_DOCS_PREFIXES = (
    "https://ui.shadcn.com/blocks",
    "https://ui.shadcn.com/view/",
)


def fail(message: str) -> None:
    raise SystemExit(f"parity error: {message}")


def require_unique(values: list[str], label: str) -> None:
    duplicates = sorted({value for value in values if values.count(value) > 1})
    if duplicates:
        fail(f"{label} contains duplicates: {', '.join(duplicates)}")


def production_source(paths: list[Path]) -> str:
    sources = []
    for path in paths:
        text = path.read_text()
        positions = [
            text.find(marker)
            for marker in ("// MARK: - Previews", "// MARK: Previews")
            if marker in text
        ]
        if positions:
            text = text[: min(positions)]
        text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
        text = "\n".join(
            line for line in text.splitlines() if not line.lstrip().startswith("//")
        )
        sources.append(text)
    return "\n".join(sources)


def validate_catalog(
    values: list[str], expected_count: int, label: str
) -> set[str]:
    require_unique(values, label)
    if len(values) != expected_count:
        fail(f"{label} has {len(values)} entries; expected {expected_count}")
    invalid = sorted(value for value in values if not re.fullmatch(r"[a-z0-9-]+", value))
    if invalid:
        fail(f"{label} contains invalid names: {', '.join(invalid)}")
    return set(values)


def validate_coverage(
    catalog: set[str],
    aliases: dict[str, str],
    missing: list[str],
    items: dict[str, dict],
    registry_type: str,
    label: str,
) -> tuple[int, int]:
    require_unique(missing, f"missing {label}")
    unknown_aliases = sorted(set(aliases) - catalog)
    unknown_missing = sorted(set(missing) - catalog)
    if unknown_aliases or unknown_missing:
        fail(
            f"{label} coverage names are outside the official catalog: "
            + ", ".join(unknown_aliases + unknown_missing)
        )

    present = 0
    for name in sorted(catalog):
        direct = name in items and items[name]["type"] == registry_type
        alias = name in aliases
        absent = name in missing
        if sum((direct, alias, absent)) != 1:
            fail(
                f"{name!r} must be exactly one of direct, aliased, or missing "
                f"for {label} coverage"
            )
        if alias:
            target = aliases[name]
            if target not in items:
                fail(f"{name!r} aliases missing registry item {target!r}")
            if items[target]["type"] != registry_type:
                fail(f"{name!r} aliases {target!r} with the wrong registry type")
        if direct or alias:
            present += 1
    return present, len(missing)


def validate_structural_maps(
    mappings: list[dict],
    component_catalog: set[str],
    block_catalog: set[str],
    items: dict[str, dict],
    aliases: dict[str, str],
) -> None:
    mapping_names = [mapping["name"] for mapping in mappings]
    require_unique(mapping_names, "structural maps")

    for mapping in mappings:
        name = mapping["name"]
        is_block = name in block_catalog
        if not is_block and name not in component_catalog:
            fail(f"structural map {name!r} is absent from the official catalog")
        registry_name = aliases.get(name, name)
        if registry_name not in items:
            fail(f"{name!r} is absent from registry.json")
        docs = mapping["upstreamDocs"]
        official = (
            docs.startswith(BLOCK_DOCS_PREFIXES) if is_block else docs.startswith(DOCS_PREFIX)
        )
        if not official:
            fail(f"{name!r} has a non-official upstreamDocs URL")

        declared_source = ROOT / mapping["source"]
        if not declared_source.is_file():
            fail(f"{name!r} source does not exist: {mapping['source']}")

        source_files = [ROOT / entry["path"] for entry in items[registry_name]["files"]]
        missing_sources = [
            str(path.relative_to(ROOT)) for path in source_files if not path.is_file()
        ]
        if missing_sources:
            fail(f"{name!r} registry sources do not exist: {', '.join(missing_sources)}")

        source = production_source(source_files)
        for symbol in mapping["swiftSymbols"]:
            declaration = (
                rf"\b(?:struct|enum|class|protocol|typealias|func|var)\s+"
                rf"{re.escape(symbol)}\b"
            )
            if not re.search(declaration, source):
                fail(f"{name!r} maps missing production declaration {symbol!r}")

        actual_dependencies = set(
            items[registry_name].get("meta", {}).get("swiftcnDependencies", [])
        )
        required_dependencies = set(mapping["requiredRegistryDependencies"])
        missing_dependencies = required_dependencies - actual_dependencies
        if missing_dependencies:
            fail(
                f"{name!r} is missing production dependencies: "
                + ", ".join(sorted(missing_dependencies))
            )

        for field in ("upstreamParts", "swiftSymbols", "behaviors", "intentionalAdaptations"):
            if not mapping[field]:
                fail(f"{name!r} must declare {field}")


def main() -> None:
    manifest = json.loads(MANIFEST.read_text())
    registry = json.loads(REGISTRY.read_text())
    items = {item["name"]: item for item in registry["items"]}

    expected = manifest["expectedCounts"]
    component_catalog = validate_catalog(
        manifest["catalog"]["components"], expected["components"], "component catalog"
    )
    block_catalog = validate_catalog(
        manifest["catalog"]["blocks"], expected["blocks"], "block catalog"
    )

    coverage = manifest["coverage"]
    component_present, component_missing = validate_coverage(
        component_catalog,
        coverage["componentAliases"],
        coverage["missingComponents"],
        items,
        "registry:component",
        "component",
    )
    block_present, block_missing = validate_coverage(
        block_catalog,
        coverage["blockAliases"],
        coverage["missingBlocks"],
        items,
        "registry:block",
        "block",
    )

    unlisted = [entry["name"] for entry in coverage["unlistedBlocks"]]
    require_unique(unlisted, "unlisted blocks")
    overlap = sorted(set(unlisted) & block_catalog)
    if overlap:
        fail(f"unlisted blocks also appear in the official catalog: {', '.join(overlap)}")

    mappings = manifest["structuralMaps"]
    validate_structural_maps(
        mappings,
        component_catalog,
        block_catalog,
        items,
        {**coverage["componentAliases"], **coverage["blockAliases"]},
    )

    print(
        "shadcn source ledger is current: "
        f"components {component_present} present / {component_missing} missing / "
        f"{len(mappings)} machine-mapped; "
        f"blocks {block_present} present / {block_missing} missing; "
        f"{len(unlisted)} unlisted block pending classification"
    )


if __name__ == "__main__":
    main()
