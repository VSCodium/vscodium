#!/bin/bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

powershell.exe -command "Expand-Archive -Force -Path '.\TXT2RTF.zip' -DestinationPath '.'"

LICENSE=$( powershell.exe -Command "[System.IO.Path]::GetFullPath( '../../../vscode/LICENSE.txt' )" )

"./TXT to RTF Converter.exe" "${LICENSE}"

cd "${CALLER_DIR}"
