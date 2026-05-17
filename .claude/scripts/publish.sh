#!/usr/bin/env bash
# Publish the wiki snapshot for the team-wiki Cowork plugin.
#
# Builds wiki.zip from the current wiki/ directory, then opens the Drive folder
# so you can upload (overwriting the existing wiki.zip to keep the file ID stable).
#
# Usage:   .claude/scripts/publish.sh
# Output:  wiki.zip at repo root
#
# Setup:   Replace <YOUR_SNAPSHOT_FOLDER_ID> below with your Drive folder ID
#          (see MAINTAINING.md → "Drive setup").

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DRIVE_FOLDER_URL="https://drive.google.com/drive/folders/<YOUR_SNAPSHOT_FOLDER_ID>"

cd "$REPO_ROOT"

if [[ ! -d wiki ]]; then
  echo "Error: no wiki/ directory at $REPO_ROOT" >&2
  exit 1
fi

echo "→ Building wiki.zip from wiki/ ..."
rm -f wiki.zip
( cd wiki && zip -rq ../wiki.zip . -x "*.DS_Store" )

PAGE_COUNT=$(find wiki -name "*.md" -type f | wc -l | tr -d ' ')
SIZE=$(ls -lh wiki.zip | awk '{print $5}')

echo "→ Built wiki.zip — $PAGE_COUNT pages, $SIZE"
echo ""
echo "Next: upload wiki.zip to Drive, OVERWRITING the existing file."
echo "(Same file ID = teammates can /team-wiki:refresh without any plugin update.)"
echo ""
echo "Opening Drive folder ..."

if command -v open >/dev/null 2>&1; then
  open "$DRIVE_FOLDER_URL"
else
  echo "$DRIVE_FOLDER_URL"
fi
