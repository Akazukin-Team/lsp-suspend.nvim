#!/bin/bash

find src -name "*.lua" | while read -r file; do
    # Set output path
    target="out/${file#src/}"

    # Create dir if the output path is not found
    mkdir -p "$(dirname "$target")"

    # Compile
    luac -o "$target" "$file"
done
