#!/bin/bash
# scripts/s390x/patch-dockerfile.sh
# Adds s390x musl library path to rootfs/Dockerfile if missing
# Run from repository root after checking out a Rancher branch

set -e

DOCKERFILE="rootfs/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
    echo "Error: $DOCKERFILE not found"
    exit 1
fi

# Check if s390x path already exists
if grep -q "ld-musl-s390x" "$DOCKERFILE"; then
    echo "s390x musl path already present, skipping"
    exit 0
fi

# Check if aarch64 path exists (we'll add after it)
if ! grep -q "ld-musl-aarch64" "$DOCKERFILE"; then
    echo "Warning: ld-musl-aarch64 not found in Dockerfile, may need manual patching"
    exit 0
fi

# Add s390x path after aarch64 path (portable sed)
sed -i.bak 's|> /etc/ld-musl-aarch64.path|> /etc/ld-musl-aarch64.path \\\n  \&\& echo "/lib:/usr/lib:/usr/local/lib:/modules_mount/etc/nginx/modules/otel" > /etc/ld-musl-s390x.path|' "$DOCKERFILE"
rm -f "${DOCKERFILE}.bak"

echo "Added s390x musl library path to $DOCKERFILE"
