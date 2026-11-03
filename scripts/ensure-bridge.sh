#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if [ ! -f vendor/agent-session-bridge/Package.swift ]; then
    git submodule update --init --recursive -- vendor/agent-session-bridge
fi
