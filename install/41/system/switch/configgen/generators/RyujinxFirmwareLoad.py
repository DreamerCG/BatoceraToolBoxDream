#!/usr/bin/env python3
import os
import shutil

# Répertoires
NCA_SRC_DIR = "/userdata/bios/switch/firmware"
KEYS_SRC_DIR = "/userdata/bios/switch/keys"
RYUJINX_SYSTEM_DIR = "/userdata/system/configs/Ryujinx/system"
REGISTERED_DIR = "/userdata/system/configs/Ryujinx/bis/system/Contents/registered"


def copy_keys():
    if not os.path.isdir(KEYS_SRC_DIR):
        raise RuntimeError(f"Dossier keys introuvable : {KEYS_SRC_DIR}")

    os.makedirs(RYUJINX_SYSTEM_DIR, exist_ok=True)

    for filename in os.listdir(KEYS_SRC_DIR):
        src = os.path.join(KEYS_SRC_DIR, filename)
        dst = os.path.join(RYUJINX_SYSTEM_DIR, filename)

        if os.path.isfile(src):
            shutil.copy2(src, dst)
            print(f"[KEY] {filename} copié")


def prepare_registered():
    if os.path.isdir(REGISTERED_DIR):
        # Suppression complète du contenu
        for entry in os.listdir(REGISTERED_DIR):
            path = os.path.join(REGISTERED_DIR, entry)
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
        print("[CLEAN] registered nettoyé")
    else:
        os.makedirs(REGISTERED_DIR, exist_ok=True)
        print("[INIT] registered créé")


def process_nca():
    if not os.path.isdir(NCA_SRC_DIR):
        raise RuntimeError(f"Dossier NCA introuvable : {NCA_SRC_DIR}")

    for filename in os.listdir(NCA_SRC_DIR):
        if not filename.lower().endswith(".nca"):
            continue

        src_file = os.path.join(NCA_SRC_DIR, filename)
        if not os.path.isfile(src_file):
            continue

        dst_dir = os.path.join(REGISTERED_DIR, filename)
        os.makedirs(dst_dir, exist_ok=True)

        dst_file = os.path.join(dst_dir, "00")
        shutil.copy2(src_file, dst_file)

        print(f"[NCA] {filename} → {dst_dir}/00")


def main():
    print("=== Ryujinx setup ===")
    copy_keys()
    prepare_registered()
    process_nca()
    print("=== Terminé ===")


if __name__ == "__main__":
    main()
