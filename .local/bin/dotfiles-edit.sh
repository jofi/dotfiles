#!/bin/sh
GIT_DIR="$HOME/.local/share/yadm/repo.git" \
GIT_WORK_TREE="$HOME" \
cursor "${@:-.}"
