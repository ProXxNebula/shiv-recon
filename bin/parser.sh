#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target>"
    exit 1
fi

TARGET="$1"
OUTDIR="recon/$TARGET"
PARSEDIR="$OUTDIR/parsed"

mkdir -p "$PARSEDIR"

### Parse HTTP headers
if [[ -f "$OUTDIR/finder_headers.txt" ]]; then
    echo "[+] Parsing HTTP headers"

    grep -iE '^HTTP/|^Server:|^Location:' "$OUTDIR/finder_headers.txt" \
        > "$PARSEDIR/http_summary.txt"
fi

# Parse TLS certificate
if [[ -f "$OUTDIR/tls.txt" ]]; then
    echo "[+] Parsing TLS certificate"

    {
        echo "== Subject =="
        grep -m1 "Subject:" "$OUTDIR/tls.txt"

        echo
        echo "== Issuer =="
        grep -m1 "Issuer:" "$OUTDIR/tls.txt"

        echo
        echo "== Validity =="
        grep -A2 "Validity" "$OUTDIR/tls.txt"

        echo
        echo "== Subject Alternative Names =="
        grep -A1 "Subject Alternative Name" "$OUTDIR/tls.txt"
    } > "$PARSEDIR/tls_summary.txt"
fi

echo "[✓] Parsing complete"
