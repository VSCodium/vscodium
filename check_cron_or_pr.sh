#!/bin/bash

set -e

if [[ $github.event.number ]]; then
	# it's a PR
	
	export SHOULD_BUILD="yes"
	export SHOULD_DEPLOY="no"
else
	export SHOULD_DEPLOY="yes"
fi

if [[ $GITHUB_ENV ]]; then
	echo "SHOULD_BUILD=$SHOULD_BUILD" >> $GITHUB_ENV
	echo "SHOULD_DEPLOY=$SHOULD_DEPLOY" >> $GITHUB_ENV
fi