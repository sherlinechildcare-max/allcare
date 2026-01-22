#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== A) Create a stable snapshot (commit + tag) =="
git add -A
git commit -m "chore: snapshot UI (home/requests/messages)" >/dev/null 2>&1 || true

TAG="ui-stable-$(date +%Y%m%d-%H%M)"
git tag -a "$TAG" -m "Stable UI snapshot: home/requests/messages" >/dev/null 2>&1 || true

echo "Pushing current branch + tags..."
git push origin HEAD --tags

echo
echo "== B) Create a safe working branch for next work (Profile) =="
BR="profile-work"
git checkout -B "$BR"
git push -u origin "$BR"

echo
echo "== C) OPTIONAL local lock (read-only) for finished UI folders =="
LOCK_PATHS=(
  "lib/features/home"
  "lib/features/requests"
  "lib/features/messages"
  "lib/config/router"
)

for p in "${LOCK_PATHS[@]}"; do
  if [ -e "$p" ]; then
    chmod -R a-w "$p"
    echo "🔒 locked: $p"
  else
    echo "skip (not found): $p"
  fi
done

echo
echo "✅ Done."
echo "Snapshot tag: $TAG"
echo
echo "To UNLOCK later (edit again):"
echo "  chmod -R u+w ${LOCK_PATHS[*]}"
echo
echo "To RESTORE snapshot later (even if something breaks):"
echo "  git checkout $TAG -- ${LOCK_PATHS[*]}"
