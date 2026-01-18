#!/bin/bash

# repertoires
NCA_SRC_DIR="/userdata/bios/switch/firmware"
KEYS_SRC_DIR="/userdata/bios/switch/keys"
RYUJINX_SYSTEM_DIR="/userdata/system/configs/Ryujinx/system"
REGISTERED_DIR="/userdata/system/configs/Ryujinx/bis/system/Contents/registered"

# --- Copier les keys ---
if [ -d "$KEYS_SRC_DIR" ]; then
    mkdir -p "$RYUJINX_SYSTEM_DIR"
    for f in "$KEYS_SRC_DIR"/*; do
        if [ -f "$f" ]; then
            cp -p "$f" "$RYUJINX_SYSTEM_DIR/"
        fi
    done
else
fi

# --- Preparer registered ---
if [ -d "$REGISTERED_DIR" ]; then
    rm -rf "$REGISTERED_DIR"/*
else
    mkdir -p "$REGISTERED_DIR"
fi

# --- Copier les fichiers .nca ---
if [ -d "$NCA_SRC_DIR" ]; then
    for f in "$NCA_SRC_DIR"/*.nca; do
        [ -f "$f" ] || continue
        filename=$(basename "$f")
        dst_dir="$REGISTERED_DIR/$filename"
        mkdir -p "$dst_dir"
        cp -p "$f" "$dst_dir/00"
        echo "[NCA] $filename → $dst_dir/00"
    done
fi
