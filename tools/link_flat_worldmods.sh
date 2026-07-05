#!/usr/bin/env bash
set -e

REPO="$HOME/Genesis/genesis-world"
WORLD="$HOME/.minetest/worlds/genesis_flat"
BACKUP="$WORLD/worldmods.backup.$(date +%Y%m%d_%H%M%S)"

pkill minetestserver || true

if [ -d "$WORLD/worldmods" ]; then
    mv "$WORLD/worldmods" "$BACKUP"
    echo "Backed up old worldmods to: $BACKUP"
fi

mkdir -p "$WORLD/worldmods"

ln -s "$REPO/mods/genesis_flat" "$WORLD/worldmods/genesis_flat"
ln -s "$REPO/mods/genesis_core" "$WORLD/worldmods/genesis_core"
ln -s "$REPO/mods/genesis_objects" "$WORLD/worldmods/genesis_objects"
ln -s "$REPO/mods/genesis_regions" "$WORLD/worldmods/genesis_regions"
ln -s "$REPO/mods/genesis_life" "$WORLD/worldmods/genesis_life"

echo "Linked Genesis worldmods:"
ls -l "$WORLD/worldmods"
