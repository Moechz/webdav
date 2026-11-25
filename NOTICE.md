# Third-party notices — WebDAV Server for TerraMaster TOS

This package (`webdavdocker`) is an independent community build by **Moechz**.
It is not affiliated with the rclone project, the former ugeek image or
TerraMaster. All trademarks belong to their owners.

## Runtime: rclone 1.76.0

- Project: **rclone** — <https://github.com/rclone/rclone>
- Documentation for the WebDAV server command:
  <https://rclone.org/commands/rclone_serve_webdav/>
- License: **MIT** (verified from the upstream repository and the image labels)
- Copyright: Nick Craig-Wood and the rclone contributors
- Container image: `rclone/rclone:1.76.0` from Docker Hub, used **unmodified**
- Pinned digest (multi-architecture OCI index):
  `sha256:7cbeec24a44f206067597c0368be4de90ae19a64d5113c7d1938bd737a81e466`
- Platforms in that index: `linux/amd64`, `linux/arm64`, `linux/arm/v6`,
  `linux/arm/v7`, `linux/386`
- Base operating system of the image: Alpine Linux 3.24 (musl, current stable)
- No rclone source code is redistributed in this repository. The image is pulled
  from Docker Hub at install time, exactly as published upstream.

The package starts the upstream binary with:

```text
rclone serve webdav /media --addr :8080 --log-level INFO
```

The only local additions are the generated password file and the `--exclude`
rule that hides that file from WebDAV clients. See `src/entrypoint.sh`.

## Former runtime (no longer used): ugeek/webdav

Releases up to `1.0.0-3` ran `ugeek/webdav:amd64` from Docker Hub. That image was
built on **2022-11-24** on Debian 10.6 (end-of-life), and the upstream repository
<https://github.com/ugeek/docker-webdav> has had no commit since **2022-11-20**,
no tags and no releases. It is retained here only as history and is **not**
referenced by the current package. Its upstream license is MIT.

## TerraMaster tooling

`TOSAppSelfTestingTool` is an official TerraMaster utility, redistributed in this
repository unmodified for local package validation. It is not part of the
installed application.

## Packaging license

The packaging files in this repository (config.ini, lang file, compose file,
entrypoint wrapper, build scripts and documentation) are released under the
**MIT License** — see `LICENSE`. The rclone image remains under its own MIT
license. Nothing in this repository grants rights to the TerraMaster name,
logos or App Center.
