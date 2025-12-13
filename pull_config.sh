#!/usr/bin/env bash
set -e

SRC="$HOME/.config/nvim/lua"
DST="./lua"

if [ ! -d "$SRC" ]; then
    echo "Source not found: $SRC"
    exit 1
fi

mkdir -p "$DST"

while IFS= read -r -d '' srcFile; do
    relPath="${srcFile#$SRC/}"
    dstFile="$DST/$relPath"
    dstDir="$(dirname "$dstFile")"

    mkdir -p "$dstDir"

    if [ -f "$dstFile" ]; then
        if [ -f "$dstFile" ] && cmp -s "$dstFile" "$srcFile"; then
            echo "Unchanged: $relPath"
            continue
        fi

        echo
        echo "Diff for $relPath"
        echo "-------------------"
        diff -u --color=always "$dstFile" "$srcFile" | less -R

        read -r -p "Overwrite $relPath? (y/n/q) " ans </dev/tty
    else
        echo
        echo "New file: $relPath"
        read -r -p "Copy? (y/n/q) " ans </dev/tty
    fi

    case "$ans" in
    y)
        cp "$srcFile" "$dstFile"
        echo "Copied"
        ;;
    q)
        echo "Aborted"
        exit 0
        ;;
    *)
        echo "Skipped"
        ;;
    esac
done < <(find "$SRC" -type f -print0)

echo
echo "Finished"
