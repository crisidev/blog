#!/usr/bin/env bash
# shellcheck disable=2154
#
if [ $# -ne 1 ]; then
    echo "usage: $0 asciicast"
    exit 1
fi
agg "$1" "$1".gif --font-family="MonoLisa Nerd Font"
