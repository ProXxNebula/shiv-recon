#! /usr/bin/env bash
set -euo pipefail

TARGET="$1"
PORTS=$(tr ',' ' ' < "recon/$TARGET/open_ports.csv")
OUTDIR="recon/$TARGET"

# Testing version for HTTP AND HTTPS
for p in $(echo "$PORTS" | tr ',' ' '); do
    curl -I "$TARGET:$p" | tee "$OUTDIR/finder_headers.txt"
done
