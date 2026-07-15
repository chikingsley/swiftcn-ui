#!/usr/bin/env python3
"""Validate the adopted elevenlabs-ui ledger against Swift sources and registry metadata.

This proves that every adopted component is accounted for, mapped symbols still
exist in production source, and required Swiftcn dependencies remain composed.
Runtime and visual parity remain separate validation gates in TODO.md.
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "parity" / "elevenlabs-ui.json"
REGISTRY = ROOT / "registry.json"
DOCS_PREFIX = "https://ui.elevenlabs.io/docs/components/"
SOURCE_PREFIX = (
    "https://github.com/elevenlabs/ui/blob/main/"
    "apps/www/registry/elevenlabs-ui/"
)


def fail(message: str) -> None:
    raise SystemExit(f"elevenlabs parity error: {message}")


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


def validate_name_list(values: list[str], label: str) -> set[str]:
    require_unique(values, label)
    invalid = sorted(value for value in values if not re.fullmatch(r"[a-z0-9-]+", value))
    if invalid:
        fail(f"{label} contains invalid names: {', '.join(invalid)}")
    return set(values)


def validate_component_coverage(
    catalog: set[str],
    aliases: dict[str, str],
    missing: list[str],
    items: dict[str, dict],
) -> set[str]:
    require_unique(missing, "missing components")
    unknown = sorted((set(aliases) | set(missing)) - catalog)
    if unknown:
        fail(f"coverage names are outside the adopted catalog: {', '.join(unknown)}")

    present = set()
    for name in sorted(catalog):
        direct = name in items and items[name]["type"] == "registry:component"
        alias = name in aliases
        absent = name in missing
        if sum((direct, alias, absent)) != 1:
            fail(f"{name!r} must be exactly one of direct, aliased, or missing")
        if alias:
            target = aliases[name]
            if target not in items:
                fail(f"{name!r} aliases missing registry item {target!r}")
            if items[target]["type"] != "registry:component":
                fail(f"{name!r} aliases {target!r} with the wrong registry type")
        if direct or alias:
            present.add(name)
    return present


def validate_structural_map(
    mapping: dict,
    items: dict[str, dict],
    aliases: dict[str, str],
) -> None:
    name = mapping["name"]
    registry_name = aliases.get(name, name)
    if registry_name not in items:
        fail(f"{name!r} is absent from registry.json")
    item = items[registry_name]
    if item["type"] != "registry:component":
        fail(f"{name!r} maps a non-component registry item")
    if not mapping["upstreamDocs"].startswith(DOCS_PREFIX):
        fail(f"{name!r} has a non-official upstreamDocs URL")
    if not mapping["upstreamSource"].startswith(SOURCE_PREFIX):
        fail(f"{name!r} has a non-official upstreamSource URL")

    declared_source = ROOT / mapping["source"]
    if not declared_source.is_file():
        fail(f"{name!r} source does not exist: {mapping['source']}")

    source_files = [ROOT / entry["path"] for entry in item["files"]]
    if declared_source not in source_files:
        fail(f"{name!r} declared source is absent from its registry files")
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

    actual_dependencies = set(item.get("meta", {}).get("swiftcnDependencies", []))
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

    if manifest.get("schemaVersion") != 1:
        fail("schemaVersion must be 1")
    upstream = manifest["upstream"]
    if upstream.get("project") != "elevenlabs/ui":
        fail("upstream project must be elevenlabs/ui")
    if upstream.get("repository") != "https://github.com/elevenlabs/ui":
        fail("upstream repository is not canonical")
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", upstream.get("checkedAt", "")):
        fail("upstream checkedAt must be an ISO date")

    catalog = validate_name_list(manifest["catalog"]["components"], "component catalog")
    supporting = validate_name_list(
        manifest["catalog"].get("supportingItems", []), "supporting items"
    )
    overlap = sorted(catalog & supporting)
    if overlap:
        fail(f"catalog components are also supporting items: {', '.join(overlap)}")

    coverage = manifest["coverage"]
    aliases = coverage["componentAliases"]
    present = validate_component_coverage(
        catalog, aliases, coverage["missingComponents"], items
    )
    for name in supporting:
        if name not in items or items[name]["type"] != "registry:component":
            fail(f"supporting item {name!r} is absent from registry.json")

    mappings = manifest["structuralMaps"]
    mapping_names = [mapping["name"] for mapping in mappings]
    require_unique(mapping_names, "structural maps")
    expected_mappings = present | supporting
    missing_mappings = sorted(expected_mappings - set(mapping_names))
    extra_mappings = sorted(set(mapping_names) - expected_mappings)
    if missing_mappings or extra_mappings:
        fail(
            "structural maps differ from present adopted/supporting items: "
            f"missing [{', '.join(missing_mappings)}], extra [{', '.join(extra_mappings)}]"
        )

    for mapping in mappings:
        validate_structural_map(mapping, items, aliases)

    print(
        "elevenlabs-ui source ledger is current: "
        f"{len(present)} adopted components / {len(supporting)} supporting items / "
        f"{len(mappings)} machine-mapped"
    )


if __name__ == "__main__":
    main()
