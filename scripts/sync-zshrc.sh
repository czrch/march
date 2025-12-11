#!/bin/bash

# Script to sync the user's .zshrc to docs/terminal

SOURCE="$HOME/.zshrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/../docs/terminal/.zshrc"

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source file $SOURCE does not exist"
    exit 1
fi

if [ -f "$TARGET" ]; then
    echo "Warning: $TARGET already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Sync cancelled"
        exit 0
    fi
fi

cp "$SOURCE" "$TARGET"
echo "Successfully synced .zshrc to $TARGET"
