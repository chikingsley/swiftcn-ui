# Gallery service

The server definition lives in this repository so the persistent process is
visible and reviewable. Install it as a user-service symlink on GMK:

```bash
mkdir -p ~/.config/systemd/user
ln -sfn \
  /home/simon/github/swiftcn-ui/tools/shadcn-comparison-gallery/ops/swiftcn-gallery.service \
  ~/.config/systemd/user/swiftcn-gallery.service
systemctl --user daemon-reload
systemctl --user enable --now swiftcn-gallery.service
```

Audit, restart, or inspect saved review state with:

```bash
systemctl --user status swiftcn-gallery.service
systemctl --user restart swiftcn-gallery.service
journalctl --user -u swiftcn-gallery.service --since today
curl -fsS http://localhost:4174/api/review-state | jq
jq . /home/simon/github/swiftcn-ui/tools/shadcn-comparison-gallery/gallery/review-state.json
```

The service exposes the static `gallery/` directory and a narrow same-origin
review API on port `4174`. It writes decisions atomically to the gitignored,
plain-text `gallery/review-state.json` file. Per-state updates are serialized so
concurrent clicks on different components do not overwrite one another.

Run the persistence and concurrency tests with:

```bash
pnpm test:gallery-server
```
