#!/usr/bin/env bash
# Exit on error
set -euo pipefail

# Variables
TARGET="$1"
PORTS="$2"
OUTDIR="recon/$TARGET"

# Creating Directory
mkdir -p "$OUTDIR"

echo "Resolving target"
getent hosts "$TARGET" | tee "$OUTDIR/dns.txt" || true

echo "Checking if target is alive"
if ping -c 1 "$TARGET" >/dev/null 2>&1; then
    echo "ICMP reachable" | tee "$OUTDIR/alive.txt"
else
    echo "ICMP blocked or host filtered" | tee "$OUTDIR/alive.txt"
fi

# Checking for open ports
echo "Scanning $TARGET"
nmap -T4 --top-ports "$PORTS" "$TARGET" 2>&1 | tee "$OUTDIR/nmap.txt" 

# Preparing open ports for service enumeration 
echo "Preparing open ports (CSV)"

awk '/open/ { split($1,a,"/"); print a[1] }' "$OUTDIR/nmap.txt" \
    | sort -n -u \
    | paste -sd, - \
    > "$OUTDIR/open_ports.csv"

# Service Enumeration
if [[ -s "$OUTDIR/open_ports.csv" ]]; then
    echo "Running service enumeration"
    nmap -sC -sV -p "$(cat "$OUTDIR/open_ports.csv")" "$TARGET" \
        | tee "$OUTDIR/services.txt"
else
    echo "No open ports found"
fi


