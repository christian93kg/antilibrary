#!/usr/bin/env bash
# One-shot cover fetcher — run from the repo root on a machine with open network:
#   bash tools/fetch_covers.sh
# Pulls cover art via the iTunes Search API (no key needed) into assets/covers/,
# named by entry slug so index.html picks them up automatically. Re-running
# overwrites. Add new lines as the library grows; for anything the search
# misses, just drop a JPG into assets/covers/<slug>.jpg by hand.
set -uo pipefail

cd "$(dirname "$0")/.."
mkdir -p assets/covers

fetch() { # <slug> <media> <search term>
  local slug="$1" media="$2" term="$3"
  local q="${term// /+}"
  local url
  url="$(curl -s "https://itunes.apple.com/search?term=${q}&media=${media}&limit=1" \
    | python3 -c "import json,sys; r=json.load(sys.stdin).get('results',[]); print(r[0]['artworkUrl100'].replace('100x100bb','600x600bb') if r else '')" \
    || true)"
  if [ -n "$url" ] && curl -sf -o "assets/covers/${slug}.jpg" "$url"; then
    echo "  ✓ ${slug}"
  else
    echo "  ✗ ${slug} — no hit; drop assets/covers/${slug}.jpg manually"
  fi
}

echo "Fetching covers…"
fetch shadow-of-the-torturer  ebook   "shadow of the torturer gene wolfe"
fetch claw-of-the-conciliator ebook   "claw of the conciliator gene wolfe"
fetch meditations             ebook   "meditations marcus aurelius gregory hays"
fetch discourses              ebook   "discourses epictetus"
fetch sandworm                ebook   "sandworm andy greenberg"
fetch the-daily-stoic         podcast "the daily stoic"
fetch the-bear                tvShow  "the bear season 1"
echo "Done. Review assets/covers/, then commit."
