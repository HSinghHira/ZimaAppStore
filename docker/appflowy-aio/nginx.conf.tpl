user www-data;
worker_processes 2;
pid /run/nginx-aio.pid;
error_log /dev/stderr warn;

events {
    worker_connections 1024;
}

http {
    access_log off;

    map $http_x_forwarded_proto $proxy_x_forwarded_proto {
        default $http_x_forwarded_proto;
        ''      $scheme;
    }

    server {
        listen @GATEWAY_PORT@;
        @EXTRA_LISTEN@
        client_max_body_size 10M;
        underscores_in_headers on;

        location /gotrue {
            proxy_pass http://127.0.0.1:9999;
            rewrite ^/gotrue/?(.*)$ /$1 break;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_pass_request_headers on;
        }

        location /ws {
            proxy_pass http://127.0.0.1:8000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_read_timeout 86400s;
        }

        location /api {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header X-Request-Id $request_id;
            proxy_set_header Host $http_host;

            location ~* ^/api/workspace/([a-zA-Z0-9_-]+)/publish$ {
                proxy_pass http://127.0.0.1:8000;
                proxy_request_buffering off;
                client_max_body_size 256M;
            }

            location /api/chat {
                proxy_pass http://127.0.0.1:8000;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                chunked_transfer_encoding on;
                proxy_buffering off;
                proxy_cache off;
                proxy_read_timeout 600s;
                proxy_connect_timeout 600s;
                proxy_send_timeout 600s;
            }

            location /api/import {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header X-Request-Id $request_id;
                proxy_set_header Host $http_host;
                proxy_read_timeout 600s;
                proxy_connect_timeout 600s;
                proxy_send_timeout 600s;
                proxy_request_buffering off;
                proxy_buffering off;
                proxy_cache off;
                client_max_body_size 2G;
            }
        }

        location /minio/ {
            proxy_pass http://127.0.0.1:9001;
            rewrite ^/minio/(.*) /$1 break;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_set_header X-NginX-Proxy true;
            real_ip_header X-Real-IP;
            proxy_connect_timeout 300s;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            chunked_transfer_encoding off;
        }

        location /minio-api/ {
            proxy_pass http://127.0.0.1:9000;
            proxy_set_header Host appflowy-minio:9000;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            rewrite ^/minio-api/(.*) /$1 break;
            proxy_connect_timeout 300s;
            proxy_read_timeout 600s;
            proxy_send_timeout 600s;
            proxy_request_buffering off;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;
            client_max_body_size 0;
        }

        location /console {
            proxy_pass http://127.0.0.1:3100;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header Host $http_host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Scheme $proxy_x_forwarded_proto;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_cache_bypass $http_upgrade;
        }

        location = /mail {
            return 301 /mail/;
        }

        location /mail/ {
            proxy_pass http://127.0.0.1:8025;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_read_timeout 3600s;
        }

        location / {
            proxy_pass http://127.0.0.1:@WEB_PORT@;
            proxy_set_header X-Scheme $proxy_x_forwarded_proto;
            proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
        }
    }
}
