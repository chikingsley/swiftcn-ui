#!/usr/bin/env python3

from __future__ import annotations

import argparse
import copy
import json
import os
import tempfile
import threading
from datetime import datetime, timezone
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

API_PATH = "/api/review-state"
IMPORT_PATH = f"{API_PATH}/import"
MAX_BODY_BYTES = 64 * 1024
MAX_NOTE_LENGTH = 2_000


class GalleryStateError(ValueError):
    pass


class GalleryStore:
    def __init__(self, state_path: Path, allowed_keys: set[str]) -> None:
        self.state_path = state_path
        self.allowed_keys = allowed_keys
        self._lock = threading.Lock()

    @staticmethod
    def _empty_state() -> dict[str, Any]:
        return {"revision": 0, "updatedAt": None, "verdicts": {}}

    def _validate_entry(self, key: str, value: Any) -> dict[str, Any]:
        if key not in self.allowed_keys:
            raise GalleryStateError(f"Unknown review state: {key}")
        if not isinstance(value, dict):
            raise GalleryStateError(f"Review value for {key} must be an object")

        verdict = value.get("v")
        note = value.get("note", "")
        if verdict not in (None, "ok", "bad"):
            raise GalleryStateError(f"Invalid verdict for {key}")
        if not isinstance(note, str):
            raise GalleryStateError(f"Note for {key} must be a string")
        if len(note) > MAX_NOTE_LENGTH:
            raise GalleryStateError(f"Note for {key} exceeds {MAX_NOTE_LENGTH} characters")
        return {"v": verdict, "note": note}

    def _read_unlocked(self) -> dict[str, Any]:
        if not self.state_path.exists():
            return self._empty_state()

        state = json.loads(self.state_path.read_text(encoding="utf-8"))
        if not isinstance(state, dict) or not isinstance(state.get("verdicts"), dict):
            raise GalleryStateError("Stored review state is malformed")
        if not isinstance(state.get("revision"), int):
            raise GalleryStateError("Stored review revision is malformed")

        state["verdicts"] = {
            key: self._validate_entry(key, value)
            for key, value in state["verdicts"].items()
        }
        state.setdefault("updatedAt", None)
        return state

    def _write_unlocked(self, state: dict[str, Any]) -> None:
        self.state_path.parent.mkdir(parents=True, exist_ok=True)
        state["revision"] += 1
        state["updatedAt"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

        descriptor, temporary_name = tempfile.mkstemp(
            dir=self.state_path.parent,
            prefix=".review-state.",
            suffix=".tmp",
            text=True,
        )
        temporary_path = Path(temporary_name)
        try:
            with os.fdopen(descriptor, "w", encoding="utf-8") as output:
                json.dump(state, output, indent=2, sort_keys=True)
                output.write("\n")
                output.flush()
                os.fsync(output.fileno())
            os.replace(temporary_path, self.state_path)
        finally:
            temporary_path.unlink(missing_ok=True)

    def snapshot(self) -> dict[str, Any]:
        with self._lock:
            return copy.deepcopy(self._read_unlocked())

    def update(self, key: str, verdict: Any, note: Any) -> dict[str, Any]:
        value = self._validate_entry(key, {"v": verdict, "note": note})
        with self._lock:
            state = self._read_unlocked()
            if value["v"] is None and value["note"] == "":
                state["verdicts"].pop(key, None)
            else:
                state["verdicts"][key] = value
            self._write_unlocked(state)
            return copy.deepcopy(state)

    def import_legacy(self, verdicts: Any) -> dict[str, Any]:
        if not isinstance(verdicts, dict):
            raise GalleryStateError("Legacy verdicts must be an object")

        validated = {
            key: self._validate_entry(key, value)
            for key, value in verdicts.items()
        }
        with self._lock:
            state = self._read_unlocked()
            changed = False
            for key, value in validated.items():
                if key in state["verdicts"]:
                    continue
                if value["v"] is None and value["note"] == "":
                    continue
                state["verdicts"][key] = value
                changed = True
            if changed:
                self._write_unlocked(state)
            return copy.deepcopy(state)

    def reset(self) -> dict[str, Any]:
        with self._lock:
            state = self._read_unlocked()
            state["verdicts"] = {}
            self._write_unlocked(state)
            return copy.deepcopy(state)


class GalleryRequestHandler(SimpleHTTPRequestHandler):
    def __init__(
        self,
        *args: Any,
        directory: str,
        store: GalleryStore,
        **kwargs: Any,
    ) -> None:
        self.store = store
        super().__init__(*args, directory=directory, **kwargs)

    def end_headers(self) -> None:
        self.send_header("X-Content-Type-Options", "nosniff")
        super().end_headers()

    def do_GET(self) -> None:
        if urlsplit(self.path).path == API_PATH:
            self._run_api_action(self.store.snapshot)
            return
        super().do_GET()

    def do_PATCH(self) -> None:
        if urlsplit(self.path).path != API_PATH:
            self._send_json(404, {"error": "Not found"})
            return
        self._run_api_action(self._patch_state)

    def do_POST(self) -> None:
        if urlsplit(self.path).path != IMPORT_PATH:
            self._send_json(404, {"error": "Not found"})
            return
        self._run_api_action(self._import_legacy)

    def do_DELETE(self) -> None:
        if urlsplit(self.path).path != API_PATH:
            self._send_json(404, {"error": "Not found"})
            return
        self._run_api_action(self.store.reset)

    def _patch_state(self) -> dict[str, Any]:
        payload = self._read_json()
        return self.store.update(
            payload.get("key"),
            payload.get("v"),
            payload.get("note", ""),
        )

    def _import_legacy(self) -> dict[str, Any]:
        payload = self._read_json()
        return self.store.import_legacy(payload.get("verdicts"))

    def _read_json(self) -> dict[str, Any]:
        try:
            content_length = int(self.headers.get("Content-Length", "0"))
        except ValueError as error:
            raise GalleryStateError("Invalid Content-Length") from error
        if content_length <= 0 or content_length > MAX_BODY_BYTES:
            raise GalleryStateError("Request body is missing or too large")

        payload = json.loads(self.rfile.read(content_length).decode("utf-8"))
        if not isinstance(payload, dict):
            raise GalleryStateError("Request body must be an object")
        return payload

    def _run_api_action(self, action: Any) -> None:
        try:
            self._send_json(200, action())
        except (GalleryStateError, json.JSONDecodeError) as error:
            self._send_json(400, {"error": str(error)})
        except Exception as error:  # pragma: no cover - journaled unexpected failure
            self.log_error("review API failure: %s", error)
            self._send_json(500, {"error": "Review state could not be saved"})

    def _send_json(self, status: int, payload: dict[str, Any]) -> None:
        body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def create_handler(directory: Path, store: GalleryStore) -> Any:
    return partial(
        GalleryRequestHandler,
        directory=str(directory),
        store=store,
    )


def allowed_review_keys(manifest_path: Path) -> set[str]:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    return {
        f"{component['id']}::{state['id']}"
        for component in manifest["components"]
        for state in component["states"]
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve and persist the Swiftcn review gallery")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--bind", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=4174)
    parser.add_argument("--state-file", type=Path)
    arguments = parser.parse_args()

    repo_root = arguments.repo_root.resolve()
    gallery_root = repo_root / "gallery"
    state_path = arguments.state_file or gallery_root / "review-state.json"
    store = GalleryStore(
        state_path=state_path,
        allowed_keys=allowed_review_keys(gallery_root / "comparisons.json"),
    )
    server = ThreadingHTTPServer(
        (arguments.bind, arguments.port),
        create_handler(gallery_root, store),
    )
    print(f"Serving {gallery_root} with review state at {state_path}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
