#!/bin/sh
printf '\033c\033]0;%s\a' spaceshipsserver
base_path="$(dirname "$(realpath "$0")")"
"$base_path/spaceships-server-0.0.2.x86_64" "$@"
