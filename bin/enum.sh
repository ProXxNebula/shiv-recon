#!/usr/bin/env bash

set -euo pipefail

TARGET="$1"
PORTS="$2"
OUTDIR="recon/$TARGET"

mkdir -p "$OUTDIR"

echo "Ping to $TARGET"
ping -c 1 "$TARGET" >/dev/null && echo "Alive" | tee "$OUTDIR/alive.txt" 

echo "Scanning $TARGET"
nmap -T4 --top-ports "$PORTS" "$TARGET" 2>&1 | tee "$OUTDIR/nmap.txt" 

echo "Getting Open Ports"
: > "$OUTDIR/open_ports.txt"
grep "open" "$OUTDIR/nmap.txt" >> "$OUTDIR/open_ports.txt" || true


