#!/usr/bin/env bash
# Exit on error
set -euo pipefail

# Variables
TARGET="$1"
PORTS="$2"
OUTDIR="recon/$TARGET"

# Creating Directory
mkdir -p "$OUTDIR"

# Checking the target if alive
echo "Ping to $TARGET"
ping -c 1 "$TARGET" >/dev/null && echo "Alive" | tee "$OUTDIR/alive.txt" 

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


