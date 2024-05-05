#!/bin/bash

GIT_BASE=$(git rev-parse --show-toplevel)

export TALOSCONFIG=${GIT_BASE}/tmp/room101-a7d-mc.talosconfig
echo "export TALOSCONFIG=${GIT_BASE}/tmp/room101-a7d-mc.talosconfig"
echo "export TALOSCONFIG=${GIT_BASE}/tmp/room101-a7d-mc.talosconfig" | xclip -selection clipboard
