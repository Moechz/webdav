#!/bin/sh
set -u
set -e
mkdir -p /media /tmp/client_body /tmp/proxy /tmp/fastcgi /tmp/uwsgi /tmp/scgi
if [ ! -s /media/.webdav-password ]; then
  head -c 18 /dev/urandom | base64 | tr -d '\n' > /media/.webdav-password
fi
PASS=$(cat /media/.webdav-password)
htpasswd -bc /tmp/htpasswd tos "$PASS" >/dev/null 2>&1
cat > /tmp/nginx.conf <<'CONF'
load_module /usr/lib/nginx/modules/ngx_http_dav_ext_module.so;
worker_processes 1;
pid /tmp/nginx.pid;
error_log /tmp/error.log;
events { worker_connections 1024; }
http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log /tmp/access.log;
  client_body_temp_path /tmp/client_body;
  proxy_temp_path /tmp/proxy;
  fastcgi_temp_path /tmp/fastcgi;
  uwsgi_temp_path /tmp/uwsgi;
  scgi_temp_path /tmp/scgi;
  server {
    listen 8080;
    server_name _;
    location = / {
      default_type text/plain;
      return 200 "WebDAV server is running. Use the credentials in the app data folder.\n";
    }
    location / {
      root /media;
      auth_basic "WebDAV";
      auth_basic_user_file /tmp/htpasswd;
      dav_methods PUT DELETE MKCOL COPY MOVE;
      dav_ext_methods PROPFIND OPTIONS;
      dav_access user:rw group:rw all:r;
      autoindex on;
      create_full_put_path on;
    }
  }
}
CONF
exec nginx -c /tmp/nginx.conf -g 'error_log /tmp/error.log; daemon off;'
