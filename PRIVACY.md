# Privacy Policy — WebDAV Server for TerraMaster TOS (`webdavdocker`)

**Last updated:** 25 November 2026
**Data controller / contact:** Moechz — moechz@163.com
**Applies to:** version `1.76.0-1` and later of the TOS application
`webdavdocker`, the container image it runs and this repository.

## 1. Summary

- The application runs **entirely on your NAS**. The developer does not receive,
  collect or have access to your files, folder names, password or logs.
- There is **no telemetry, no analytics, no advertising and no developer
  account**, and no cloud service is used.
- The container makes **no outbound network connections while it is running**.
  The only external request is the anonymous Docker Hub image pull performed by
  DockerEngine when you install or upgrade the app.
- The app is a **single-account file service**: one username (`tos`) and one
  password, shared by every WebDAV client you connect.

## 2. What data is processed

| Data | Where it is stored on the NAS |
|---|---|
| Files and folders you upload through WebDAV, including their contents, names, sizes and timestamps | `/Volume1/DockerAppData/webdavdocker/media` (the WebDAV root) |
| File metadata served by WebDAV (name, size, modification time, content type, ETag) | generated from the files above; no separate database |
| The WebDAV password | `/Volume1/DockerAppData/webdavdocker/media/.webdav-password`, mode `0600` |
| Access logs: client IP address, time, HTTP method, requested path, status code and user agent | the container's stdout/stderr, readable with `docker logs webdavdocker`; kept by DockerEngine according to its own log rotation settings |

The password file is created on first start with 18 random bytes encoded as
base64. It is **excluded from the WebDAV view**: clients cannot list or download
it, although it lives in the same folder on the NAS.

The app does not ask for an email address, phone number, account, cookie or any
other personal identifier. There is no user database and no session store beyond
HTTP Basic authentication.

## 3. Retention period

- **Files and folders:** kept until **you** delete them. There is no automatic
  expiry and no upload. Uninstalling the app keeps the data folder unless you
  tick “delete data” or remove it yourself.
- **Password file:** kept for the life of the installation, so upgrades do not
  invalidate your clients. Delete it and restart the container to generate a new
  random password.
- **Logs:** stdout/stderr only. The Docker daemon keeps them according to its own
  rotation configuration. The app writes no log files of its own.

## 4. Your rights and the deletion channel

| Right | How |
|---|---|
| Access / export | Connect any WebDAV client with the `tos` account and copy the files. The complete state is the folder `/Volume1/DockerAppData/webdavdocker/media`. |
| Correct | Rename, move or edit files through your WebDAV client. |
| Delete | Delete files through your WebDAV client, uninstall the app with “delete data”, or stop the container and remove `/Volume1/DockerAppData/webdavdocker/`. |
| Restrict processing | Keep the app on the LAN, block outbound traffic for the container, or stop it. The service does not need internet access to serve files. |
| Rotate the password | Stop the container, delete `/Volume1/DockerAppData/webdavdocker/media/.webdav-password`, and start it again. A new random password is generated. |
| Assistance | Email **moechz@163.com** with the subject “WebDAV Server data request”. A reply follows within 30 days. |

The developer holds no copy of your data, so deletion is normally completed by
removing the folder on your own NAS. The email channel exists for questions and
for requests about the package, the repository or the publishing records.

## 5. Security measures

- The container runs as **uid 1000**, never root; no `privileged`, no `cap_add`,
  no host network and no Docker socket.
- Only the application's own port is published (host 8112 → container 8080).
- HTTP Basic authentication is **required for every request**. An unauthenticated
  request receives `401 Unauthorized` (verified during packaging).
- The password file is mode `0600` and is filtered out of WebDAV responses.
  Passwords are not written to the container command line, so they do not appear
  in `ps` output.
- The image is pinned by tag **and multi-architecture digest**
  (`rclone/rclone:1.76.0@sha256:7cbeec24…`); the package is rebuilt when upstream
  ships security fixes.
- **No TLS is built in.** Basic authentication over plain HTTP is readable by
  anyone who can capture LAN traffic. Use the app only on a trusted network, or
  put a TLS reverse proxy in front of port 8112 before exposing it to the
  internet.
- Files are stored unencrypted on the NAS. Use the NAS volume encryption or an
  encrypted dataset if you need encryption at rest.
- There is no login rate limiting or account lockout in this package. Restrict
  access with the NAS firewall or a reverse proxy if the service is reachable
  from untrusted networks.

## 6. Third-party sharing and API disclosure

The developer shares nothing. **The running container contacts no third-party
service.** The only external endpoint involved in the life of the package is the
image registry used by DockerEngine:

| Service | Endpoint | Data sent | When | Destination / region |
|---|---|---|---|---|
| Docker Hub (or the registry mirror configured on your NAS) | `registry-1.docker.io`, `auth.docker.io`, or your mirror | anonymous image pull: IP address and user agent; no files, folder names or password | install and upgrade only | Docker Hub, United States / your mirror |

Notes:

- `rclone serve webdav` reads and writes only the local folder
  `/Volume1/DockerAppData/webdavdocker/media`. It does not check for updates, send
  telemetry or call a licensing server.
- WebDAV clients that you connect from your own devices are chosen and controlled
  by you. They are not third-party services operated by the developer.
- If you configure a TLS reverse proxy or VPN in front of the app, that component
  has its own privacy policy.

## 7. Children

The app is a self-hosted file-sharing utility and is not directed at children.

## 8. Changes

Material changes are published in this file and reflected in the “Last updated”
date. The policy also ships with every release of the package and is linked from
the app's Help field and the repository README.

## 9. Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/privacy.html>

## 10. Scope

This policy covers the TOS package `webdavdocker` (the four packaging files, the
entrypoint wrapper and the documentation in this repository) and the unmodified
upstream image `rclone/rclone:1.76.0`. The upstream rclone project has its own
documentation at <https://rclone.org> and its own privacy policy for the project
website.
