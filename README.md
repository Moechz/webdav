# WebDAV Server for TerraMaster TOS 7

> TerraMaster TOS 7 App Center — **Docker application** package for a
> single-folder WebDAV server powered by [rclone](https://rclone.org/webdav/).

## What this is

A four-file TOS Docker application archive (`webdavdocker.tar.gz`) that installs
a WebDAV file service on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `webdavdocker`)
- `webdavdocker.lang` — 23-language superset (14 required by TOS)
- `webdavdocker.svg` — application icon
- `docker-compose.yml` — one service running the pinned rclone image

The service exposes **one shared folder** at `/Volume1/DockerAppData/webdavdocker/media`
over WebDAV. It is intentionally small: no web admin UI, no database and no
multi-tenant account system.

## How it works

| | |
|---|---|
| Runtime | `rclone serve webdav` from `rclone/rclone:1.76.0` (Docker Hub, unmodified) |
| Open | `http://<NAS-IP>:8112/` (container port 8080) |
| Authentication | HTTP Basic, **single account** `tos`, random password generated on first start |
| Password file | `/Volume1/DockerAppData/webdavdocker/media/.webdav-password` (mode `0600`, hidden from WebDAV clients) |
| WebDAV root | `/Volume1/DockerAppData/webdavdocker/media` |
| Runs as | non-root, `user: "1000:1000"` |
| Transport | **HTTP only** — this package does not include TLS |
| Outbound traffic | **none at runtime**; Docker Hub is contacted only for the image pull at install/upgrade |
| Logs | `docker logs webdavdocker` (stdout/stderr) |

### Supported methods and clients

The server implements the WebDAV methods used by mainstream clients, including
`PROPFIND`, `OPTIONS`, `GET`, `PUT`, `DELETE`, `MKCOL`, `COPY` and `MOVE`.
Windows Explorer, macOS Finder, Linux `davfs2`/GVfs, rclone, Cyberduck, KDE
dolphin and mobile WebDAV apps can connect. On Windows, Basic authentication over
plain HTTP is disabled by default in the WebClient service; use a TLS reverse
proxy or set `BasicAuthLevel=2` if you understand the risk.

### Credentials

On first start the entrypoint writes 18 random bytes (base64) to
`.webdav-password`. To rotate it:

```bash
# stop the app, then:
rm /Volume1/DockerAppData/webdavdocker/media/.webdav-password
# start the app again; a new password is generated
```

The password is read from the file on every start, so upgrades preserve it.

## Repository layout

```text
.
├── CHANGELOG.md              # release history, one section per packaging version
├── LICENSE                   # MIT for the packaging
├── NOTICE.md                 # third-party notices, image digest, licences
├── PRIVACY.md                # privacy policy (linked from the app's Help field)
├── README.md                 # this file
├── TOSAppSelfTestingTool     # official TerraMaster package checker
├── scripts/
│   ├── build.sh              # stage + verify + pack one architecture
│   └── build-dual.sh         # build x86_64 and aarch64, run the official check
├── src/
│   ├── config.ini            # TOS metadata (help links to PRIVACY.md)
│   ├── docker-compose.yml    # image, port, volume, healthcheck, entrypoint
│   ├── entrypoint.sh         # password generation + rclone exec
│   ├── webdavdocker.lang     # 23-language store text
│   └── webdavdocker.svg      # icon
├── test/install-and-verify.sh # on-device E2E (needs root, destructive)
├── tools/verify.py           # review-standards self-check
└── tosapp.json               # build spec and translations
```

## Privacy

The full policy is [`PRIVACY.md`](PRIVACY.md) and is also linked from the app's
Help field. In short:

- Everything stays on your NAS. The developer receives no files, names,
  passwords or logs.
- The running container has **no outbound connections**. The only external
  request is the anonymous Docker Hub image pull at install/upgrade.
- Logs contain client IP addresses and requested paths and are kept by
  DockerEngine's log driver, not by the app.
- The package has **no TLS**. Use it on a trusted LAN or behind a TLS reverse
  proxy. Basic authentication over plain HTTP is not confidential against a
  network sniffer.

## Notices

`rclone` is MIT-licensed. The image is used unmodified and pinned by tag and
multi-architecture digest; see [`NOTICE.md`](NOTICE.md) for the digest, the
platforms in the index and the former `ugeek/webdav` runtime. This is an
independent community package, not affiliated with rclone or TerraMaster.

## Build

```bash
scripts/build-dual.sh            # both architectures, current tosapp.json version
scripts/build-dual.sh 1.76.0-2   # explicit packaging version
scripts/build.sh 1.76.0-1 x86_64 # one architecture -> out/webdavdocker.tar.gz
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`),
removes CRLF/BOM/AppleDouble, then runs `tools/verify.py` — a review-standards
self-check covering archive layout, JSON validity, required fields, 14+ language
coverage, version consistency, Docker-Hub-only images, fixed tag/digest, reserved
and recommended host ports, non-root user, per-service healthcheck/TZ/restart,
data paths below the application data root, no `/Volume*` wildcard, comment-free
sequence blocks, `x-app-meta` position, no literal secrets and icon limits.

`build-dual.sh` also runs the official `TOSAppSelfTestingTool -c` on both
packages. Both must print `check passed`.

## Local verification

```bash
./TOSAppSelfTestingTool -c out/webdavdocker_x86_64.tar.gz
./TOSAppSelfTestingTool -c out/webdavdocker_aarch64.tar.gz
python3 ../stage.py . --timeout 300      # isolated compose run, no production data
```

`stage.py` rewrites the volumes and ports into a temporary directory, starts the
package with `docker compose`, waits for `healthy`, checks the HTTP response and
the non-root user, then removes everything. It never touches
`/Volume1/DockerAppData`.

The on-device script `test/install-and-verify.sh` installs through the official
`-i` path and deletes the app data; it is for a disposable test NAS, **not** for
a NAS that already runs the listed app.

## Data and uninstall

| Path | Contents | Removal |
|---|---|---|
| `/Volume1/DockerAppData/webdavdocker/media` | every file and folder shared over WebDAV, plus `.webdav-password` | delete through a WebDAV client, or uninstall with “delete data”, or `rm -rf /Volume1/DockerAppData/webdavdocker/` |

There is no other application data. Logs live only in Docker's log buffer. The
TOS App Center's Docker packages have no uninstall hook, so removing the package
keeps the data folder unless you explicitly delete it.

## Upgrade from 1.0.0-3

- The image changed from `ugeek/webdav:amd64` to `rclone/rclone:1.76.0`.
  The old image is based on end-of-life Debian 10 and had no upstream update
  since 2022; the new one is a current Alpine 3.24 build with amd64 and arm64
  images from the same OCI index.
- Existing files stay in `/Volume1/DockerAppData/webdavdocker/media`.
- The existing `.webdav-password` is reused, so clients keep working.
- Port 8112 is unchanged.
- aarch64 is now built from the same pinned image index. A separate aarch64 App
  record is created on the developer platform because TOS tracks one record per
  architecture.

## Limitations

- **Single user.** One account (`tos`) and one password. There is no per-user
  permission model; every client sees the same folder.
- **Plain HTTP only.** No certificate is generated or bundled. Terminate TLS in a
  reverse proxy if the service must cross an untrusted network.
- **No web admin UI.** Management is done with a WebDAV client and the files on
  disk.
- **No file locking across clients beyond WebDAV locks.** Applications that
  require POSIX locks (for example some database files) are not suitable.
- The root URL returns an authenticated directory listing, not a custom
  dashboard.

## Security

- Container runs as uid 1000 with no `privileged`, no `cap_add`, no host network
  and no Docker socket.
- Only port 8112 is published.
- HTTP Basic authentication is required; unauthenticated requests receive `401`.
- The password file is `0600` and excluded from WebDAV responses.
- The image is pinned by tag and digest and is rebuilt when upstream ships a
  security release.
- No TLS and no brute-force protection are included; restrict access at the NAS
  firewall or reverse proxy.

## License / branding

The packaging is MIT (see `LICENSE`). rclone is MIT. The container image is
pulled unmodified from Docker Hub. This is an independent community submission by
Moechz and is not affiliated with the rclone project or TerraMaster.
