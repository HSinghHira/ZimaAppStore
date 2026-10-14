#!/usr/bin/env bash
# Records each upstream image's start-up config (entrypoint, command, env,
# working dir, user, ports) into ./meta/<name>.json. The Dockerfile copies it in,
# and run-svc.sh uses it to start each service the way its own image would.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p meta
count=0
while read -r _ image _ stage; do
  name=${stage#img-}
  docker pull -q "$image" >/dev/null
  docker image inspect "$image" --format '{{json .Config}}' > "meta/$name.json"
  echo "meta/$name.json  <-  $image"
  count=$((count + 1))
done < <(grep -E '^FROM [^ ]+ AS img-[a-z]+$' Dockerfile)
[ "$count" -ge 8 ] || { echo "expected 8 images, captured $count"; exit 1; }
