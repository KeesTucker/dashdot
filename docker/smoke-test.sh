#!/usr/bin/env bash
# Boots an image and waits for /info to answer. Catches a server bundle that
# crashes on load, which unit tests miss because they never run the bundle.
set -euo pipefail

image="$1"
name="dashdot-smoke-$$"

docker run -d --name "$name" -p 127.0.0.1:3001:3001 "$image" >/dev/null
trap 'docker rm -f "$name" >/dev/null' EXIT

for _ in $(seq 1 60); do
  if curl -fs -o /dev/null http://127.0.0.1:3001/info; then
    echo "smoke test passed: $image answers on /info"
    exit 0
  fi
  sleep 1
done

echo "smoke test failed: $image did not answer on /info within 60s" >&2
docker logs --tail 50 "$name" >&2
exit 1
