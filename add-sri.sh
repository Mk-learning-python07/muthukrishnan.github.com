#!/usr/bin/env bash
# Run this once in your Codespace terminal from the repo root:
#   bash add-sri.sh
# It fetches both CDN files, computes SHA-384 hashes, and patches the HTML in-place.

set -e

echo "Fetching Font Awesome 6.4.0..."
FA_HASH=$(curl -sfL "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" \
  | openssl dgst -sha384 -binary | openssl base64 -A)

echo "Fetching Plotly.js 2.27.0..."
PLOTLY_HASH=$(curl -sfL "https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.27.0/plotly.min.js" \
  | openssl dgst -sha384 -binary | openssl base64 -A)

echo "Patching _layouts/default.html..."
sed -i "s|href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css\" crossorigin=\"anonymous\"|href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css\" integrity=\"sha384-${FA_HASH}\" crossorigin=\"anonymous\"|" \
  _layouts/default.html

echo "Patching apps/vector-acceleration.html..."
sed -i "s|src=\"https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.27.0/plotly.min.js\" crossorigin=\"anonymous\"|src=\"https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.27.0/plotly.min.js\" integrity=\"sha384-${PLOTLY_HASH}\" crossorigin=\"anonymous\"|" \
  apps/vector-acceleration.html

echo ""
echo "Done. Verify:"
grep "integrity=" _layouts/default.html
grep "integrity=" apps/vector-acceleration.html
