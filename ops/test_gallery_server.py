#!/usr/bin/env python3

from __future__ import annotations

import json
import tempfile
import threading
import unittest
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from http.server import ThreadingHTTPServer
from pathlib import Path

from gallery_server import GalleryStateError, GalleryStore, create_handler


class GalleryStoreTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.state_path = Path(self.temporary_directory.name) / "review-state.json"
        self.allowed_keys = {f"component-{index}::light" for index in range(32)} | {
            "button::light",
            "dialog::dark",
        }
        self.store = GalleryStore(self.state_path, self.allowed_keys)

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def test_update_persists_and_can_be_reversed(self) -> None:
        state = self.store.update("button::light", "ok", "Looks right")
        self.assertEqual(state["revision"], 1)
        self.assertEqual(state["verdicts"]["button::light"]["v"], "ok")

        reloaded = GalleryStore(self.state_path, self.allowed_keys).snapshot()
        self.assertEqual(reloaded["verdicts"], state["verdicts"])

        cleared = self.store.update("button::light", None, "")
        self.assertNotIn("button::light", cleared["verdicts"])

    def test_legacy_import_does_not_overwrite_server_state(self) -> None:
        self.store.update("button::light", "bad", "Server decision")
        state = self.store.import_legacy(
            {
                "button::light": {"v": "ok", "note": "Old browser decision"},
                "dialog::dark": {"v": "ok", "note": "Migrated"},
            }
        )
        self.assertEqual(state["verdicts"]["button::light"]["v"], "bad")
        self.assertEqual(state["verdicts"]["dialog::dark"]["note"], "Migrated")

    def test_rejects_unknown_states_and_invalid_verdicts(self) -> None:
        with self.assertRaises(GalleryStateError):
            self.store.update("unknown::light", "ok", "")
        with self.assertRaises(GalleryStateError):
            self.store.update("button::light", "maybe", "")

    def test_concurrent_updates_do_not_drop_other_states(self) -> None:
        keys = [f"component-{index}::light" for index in range(32)]
        with ThreadPoolExecutor(max_workers=8) as executor:
            list(executor.map(lambda key: self.store.update(key, "ok", key), keys))

        state = self.store.snapshot()
        self.assertEqual(state["revision"], len(keys))
        self.assertEqual(set(state["verdicts"]), set(keys))


class GalleryHTTPTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        root = Path(self.temporary_directory.name)
        (root / "index.html").write_text("gallery", encoding="utf-8")
        self.store = GalleryStore(root / "review-state.json", {"button::light"})
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), create_handler(root, self.store))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base_url = f"http://127.0.0.1:{self.server.server_port}"

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)
        self.temporary_directory.cleanup()

    def test_patch_and_get_round_trip(self) -> None:
        request = urllib.request.Request(
            f"{self.base_url}/api/review-state",
            data=json.dumps({"key": "button::light", "v": "ok", "note": "Saved"}).encode(),
            method="PATCH",
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request) as response:
            self.assertEqual(response.status, 200)

        with urllib.request.urlopen(f"{self.base_url}/api/review-state") as response:
            state = json.load(response)
        self.assertEqual(state["verdicts"]["button::light"], {"v": "ok", "note": "Saved"})


if __name__ == "__main__":
    unittest.main()
