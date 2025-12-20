#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target>"
    exit 1
fi

TARGET="$1"
PORTS=$(tr ',' ' ' < "recon/$TARGET/open_ports.csv")
OUTDIR="recon/$TARGET"

: > "$OUTDIR/finder_headers.txt"
: > "$OUTDIR/finder_body.txt"

# TODO non-http Testing
handle_non_http() {
    echo "[STUB] Port $1 requires protocol-specific finder"
}

# Testing version for HTTP AND HTTPS
for p in $PORTS; do
    if [[ "$p" == "443" ]]; then
        SCHEME="https"

        openssl s_client -connect "$TARGET:443" -servername "$TARGET" < /dev/null 2>/dev/null \
            | openssl x509 -noout -text \
            >> "$OUTDIR/tls.txt" || true
    elif [[ "$p" == "80" ]]; then
        SCHEME="http"
    else
    handle_non_http "$p"
    continue    
    fi    

    # Building URL format
    URL="$SCHEME://$TARGET:$p"
    
    # -skI Silently send a HEAD request and ignore TLS errors.
    curl -skI "$URL" >> "$OUTDIR/finder_headers.txt" || true
    # -sk for send a BODY request.
    curl -sk "$URL" >> "$OUTDIR/finder_body.txt" || true
done
