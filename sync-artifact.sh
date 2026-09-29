#!/bin/bash
# Sync guitar-tab-player artifact from the sheet-music repo
# The repo is the source of truth; the artifact follows it.

REPO_DIR="$HOME/workspace/sheet-music-repo"
ARTIFACT_DIR="$HOME/workspace/ts-spaces/guitar-tab-player"
TABS_DIR="$HOME/workspace/your_files/tabs"
DATA_SRC="$REPO_DIR/data/songs_final.json"
DATA_DST="$HOME/workspace/tabwork/songs_final.json"

cd "$REPO_DIR" || exit 1

# Pull latest
git pull --quiet origin main 2>&1 | grep -v "Already up to date" 

# Check if the main HTML changed
if ! cmp -s "$REPO_DIR/guitar-tab-player.html" "$ARTIFACT_DIR/index.html"; then
    echo "[$(date)] Updating artifact HTML from repo"
    cp "$REPO_DIR/guitar-tab-player.html" "$ARTIFACT_DIR/index.html"
    UPDATED=1
fi

# Check if song data changed
if [ -f "$DATA_SRC" ] && ! cmp -s "$DATA_SRC" "$DATA_DST"; then
    echo "[$(date)] Updating song data from repo"
    cp "$DATA_SRC" "$DATA_DST"
    UPDATED=1
fi

# Check if tab files changed
for f in "$REPO_DIR"/tabs/*.txt "$REPO_DIR"/tabs/*.mid; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    if ! cmp -s "$f" "$TABS_DIR/$base" 2>/dev/null; then
        echo "[$(date)] Updating tab file: $base"
        cp "$f" "$TABS_DIR/$base"
        UPDATED=1
    fi
done

if [ "$UPDATED" = "1" ]; then
    echo "[$(date)] Artifact synced from repo"
else
    echo "[$(date)] Already in sync"
fi
