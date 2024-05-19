#!/usr/bin/env bash
# shellcheck disable=2154
if [ $# -lt 1 ]; then
	echo "usage: $0 language <silicon arguments>"
	exit 1
fi

language="$1"
shift

echo "saving output to $(pwd)/screenshot.png"
exec silicon \
	--theme tokyonight_storm --font "MonoLisa Nerd Font" \
	--background '#202228' --shadow-color '#202228' \
	--line-pad 0 --pad-horiz 20 --pad-vert 20 \
	--shadow-blur-radius 0 --shadow-offset-x 0 --shadow-offset-y 0 \
	--language "$language" "$@" --output "$(pwd)/screenshot.png"
