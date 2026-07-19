#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$here"

export GDK_BACKEND="${GDK_BACKEND:-x11}"
export __GL_THREADED_OPTIMIZATIONS="${__GL_THREADED_OPTIMIZATIONS:-1}"
export R3_STEAM_DECK="${R3_STEAM_DECK:-1}"

exec ./R3 "$@"
