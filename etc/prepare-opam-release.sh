#!/usr/bin/env bash
set -euo pipefail

# Usage: prepare-opam-release.sh <version-tag>
# Downloads the release tarball, computes its SHA512 checksum, and
# appends url { ... } to the opam file.

TAG="${1:?Usage: $0 <version-tag>}"
REPO="theorem-labs/rocq-structured-output-print-assumptions"
OPAM_FILE="rocq-print-assumptions-json.opam"

URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz"

echo "Downloading ${URL}..."
curl -fSL -o release.tar.gz "$URL"
SHA512=$(sha512sum release.tar.gz | cut -d' ' -f1)
rm -f release.tar.gz

cat >> "$OPAM_FILE" <<EOF
url {
  src: "${URL}"
  checksum: "sha512=${SHA512}"
}
EOF

echo "Updated ${OPAM_FILE} with url and checksum."
