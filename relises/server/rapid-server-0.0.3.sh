#!/bin/sh
printf '\033c\033]0;%s\a' rapidserver
base_path="$(dirname "$(realpath "$0")")"
"$base_path/rapid-server-0.0.3.x86_64" "$@"
