# Changelog

All notable user-visible changes to the WebDAV Server TOS application package.

## 1.76.0-1 — 2026-11-25

Remediation of the App Center listing review for `1.0.0-3` (C3, C9, T1),
with the runtime and both architectures rebuilt.

### Security (T1)

- Replaced the former `ugeek/webdav:amd64` image (built 2022-11-24 on Debian
  10.6, which is end-of-life) with **rclone 1.76.0**, the current upstream
  release (2026-11-06). The old image remains vulnerable and is no longer used.
- Verified that `ugeek/docker-webdav` has had **no commit since 2022-11-20, no
  tags and no releases**, so there is no newer ugeek image to upgrade to.
- Pinned `rclone/rclone:1.76.0` by tag and by the multi-architecture OCI index
  digest `sha256:7cbeec24…e466`. The same digest contains `linux/amd64` and
  `linux/arm64`, so the aarch64 package is genuine rather than a relabelled
  x86_64 or arm32 image.
- The new image is based on current Alpine Linux 3.24 and runs as uid 1000.

### Compliance (C3 / C4 / C5 / C7 / C8)

- Added `PRIVACY.md`: what is stored (files, metadata, password, access logs),
  where it is stored, retention, user rights and deletion channels, security
  measures and the third-party endpoint table.
- `config.ini` `help` now points to
  `https://github.com/Moechz/webdav/blob/main/PRIVACY.md`, a public URL.
- Documented explicitly that the service **does not contact any third party at
  runtime**. The only external request is the anonymous Docker Hub image pull at
  install/upgrade. Files, names and passwords never leave the NAS.
- Documented the access-log contents (client IP, time, method, path, status) and
  that DockerEngine, not the app, retains them.

### Description (C9)

- Rewrote the English, `zh-cn` and `zh-hk` descriptions, plus all fallback
  languages, to match the delivered service:
  - one WebDAV folder, single account `tos`, random password in the data folder;
  - read/write with `PROPFIND`, `PUT`, `GET`, `MKCOL`, `COPY`, `MOVE`, `DELETE`;
  - plain HTTP only, **no built-in TLS**;
  - no web admin UI, no multi-user accounts.
- Removed the old `beaverhabits` habit-tracker text and the incorrect claims
  ("per-app credentials", "rebuilds nginx", "only x86_64 because upstream only
  publishes amd64").
- Removed all ASCII semicolons from `webdavdocker.lang` so the store parser does
  not truncate any value.

### Packaging

- Entrypoint now starts `rclone serve webdav` as PID 1 after generating or
  reusing `/media/.webdav-password` (mode `0600`).
- The password file is excluded from WebDAV responses and is not passed on the
  command line.
- Healthcheck asserts that the server answers with `401 Unauthorized`, which also
  proves authentication is enforced.
- Added `security_opt: no-new-privileges:true`.
- Added the **aarch64** package. Port remains **8112** (host) → 8080 (container).
- Removed the contaminated `probe` block (it described `daya0576/beaverhabits`)
  and the dangling `entrypoint_file` path from `tosapp.json`.
- README now covers repository layout, privacy, notices, build, data/uninstall
  and limitations.

### Compatibility

- Existing data in `/Volume1/DockerAppData/webdavdocker/media` is preserved.
- The existing `.webdav-password` is reused, so configured clients keep working.
- The host port is unchanged at 8112.

## 1.0.0-1 — 2026-11-12

### Added
- First release. WebDAV Server (`ugeek/webdav:amd64`, Docker Hub official image,
  unmodified) packaged as a TOS 7 Docker application, published on port 8112 and
  running as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/webdavdocker/`.
