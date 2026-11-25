#!/bin/sh
# Entrypoint for the WebDAV Server TOS package.
#
# The upstream image is rclone/rclone:1.76.0.  It runs `rclone serve webdav`
# against the mounted data folder as uid 1000.  The image itself is unmodified;
# this wrapper only creates the per-install password and starts the server.
set -u
set -e

umask 077

# /media is the WebDAV root.  It is a bind mount owned by the app user (the
# TOS installer creates and chowns it).  Nothing outside /media is written.
mkdir -p /media

# Keep the existing password on upgrade.  The file is deliberately excluded
# from the WebDAV view below, so clients cannot download it.
if [ ! -s /media/.webdav-password ]; then
  head -c 18 /dev/urandom | base64 | tr -d '\n' > /media/.webdav-password
fi
chmod 600 /media/.webdav-password
PASS=$(cat /media/.webdav-password)

# Credentials go through the environment, not argv, so `ps` does not show the
# password.  rclone maps RCLONE_<FLAG> to the corresponding command-line flag.
export RCLONE_USER=tos
export RCLONE_PASS="$PASS"

# HTTP only: this package does not ship or generate TLS certificates.  If HTTPS
# is required, terminate it in a reverse proxy in front of port 8112.
#
# --exclude keeps the credential file out of PROPFIND/GET responses.
# --dir-cache-time 10s makes files written directly on the NAS show up quickly.
exec rclone serve webdav /media \
  --addr :8080 \
  --log-level INFO \
  --dir-cache-time 10s \
  --umask 022 \
  --exclude /.webdav-password
