# Gallery service

The server definition lives in this repository so the persistent process is
visible and reviewable. Install it as a user-service symlink on GMK:

```bash
mkdir -p ~/.config/systemd/user
ln -sfn \
  /home/simon/github/swiftcn-shadcn-ref/ops/swiftcn-gallery.service \
  ~/.config/systemd/user/swiftcn-gallery.service
systemctl --user daemon-reload
systemctl --user enable --now swiftcn-gallery.service
```

Audit or restart it with:

```bash
systemctl --user status swiftcn-gallery.service
systemctl --user restart swiftcn-gallery.service
journalctl --user -u swiftcn-gallery.service --since today
```

The service exposes only the static `gallery/` directory on port `4174`; it
does not run Vite, install packages, or write review data to the server.
