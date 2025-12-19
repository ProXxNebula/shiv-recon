#! /usr/bin/env bash
set -euo pipefail

TARGET="$1"
PORTS=$(tr ',' ' ' < "recon/$TARGET/open_ports.csv")
OUTDIR="recon/$TARGET"

# Testing version for HTTP AND HTTPS
for p in $(echo "$PORTS" | tr ',' ' '); do
    if [[ "$p" == "443" ]]; then
        SCHEME="https"
    elif [[ "$p" == "80" ]]; then
        SCHEME="http"    
    else
        echo "trying dif finder script"    
    fi    

    # Building URL format
    URL="$SCHEME://$TARGET:$p"
    
    # -skI Silently send a HEAD request and ignore TLS errors.
    curl -skI "$URL" >> "$OUTDIR/finder_headers.txt" || true
done