#!/usr/bin/env bash

check_programs() {
    for arg in "$@"
    do
        if ! command -v $arg >/dev/null 2>&1
		then
			echo "$arg could not be found"
			exit
		fi
    done
}

check_programs "icns2png" "composite" "convert" "png2icns" "icotool"

for file in vscode/resources/darwin/*
do
	if [ -f "$file" ]; then
		name=$(basename $file '.icns')

		if [[ $name != 'code' ]] && [ ! -f "src/resources/darwin/$name.icns" ]; then
			icns2png -x -s 512x512 $file -o .

			composite -blend 100% -geometry +323+365 icons/corner_512.png "${name}_512x512x32.png" "$name.png"
			composite icons/code_darwin.png "$name.png" "$name.png"

			convert "$name.png" -resize 256x256 "${name}_256.png"

			png2icns "src/resources/darwin/$name.icns" "$name.png" "${name}_256.png"

			rm "${name}_512x512x32.png" "$name.png" "${name}_256.png"
		fi
	fi
done

for file in vscode/resources/win32/*.ico
do
	if [ -f "$file" ]; then
		name=$(basename $file '.ico')

		if [[ $name != 'code' ]] && [ ! -f "src/resources/win32/$name.ico" ]; then
			icotool -x -w 256 $file

			composite -geometry +150+185 icons/code_64.png "${name}_9_256x256x32.png" "${name}.png"

			convert "${name}.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "src/resources/win32/$name.ico"

			rm "${name}_9_256x256x32.png" "${name}.png"
		fi
	fi
done
