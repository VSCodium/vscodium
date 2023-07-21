#!/usr/bin/env bash

cd "$( dirname "${BASH_SOURCE[0]}" )"/../../../vscode || { echo "'vscode' dir not found"; exit 1; }

input=LICENSE.txt
target=LICENSE.rtf

cat - >$target <<_EOF
{\rtf1\ansi\deff0{\fonttbl{\f0\fnil\fcharset0 Consolas;}}
\viewkind4\uc1\pard\lang1033\f0\fs22

_EOF

sed -zE -e 's/([A-Za-z,])\r?\n([A-Za-z])/\1 \2/g' -e 's/\r?\n\r?\n/\\par\n\n/g' -e 's/(\\par\n)/\\line\1/g' -e 's/\s*(Copyright)/\\line\n\1/g' -e 's/(\\par)\\line/\1\n/g' $input >> $target


cat - >>$target <<_EOF
\par
}
_EOF
