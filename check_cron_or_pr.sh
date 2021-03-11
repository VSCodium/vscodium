#!/bin/bash

set -e

if [[ $github.event.number ]]; then
	echo "It's a PR"
	
	export SHOULD_BUILD="yes"
	export SHOULD_DEPLOY="no"
else
	echo "It's a cron"
	
	export SHOULD_DEPLOY="yes"
fi

if [[ $GITHUB_ENV ]]; then
	echo "SHOULD_BUILD=$SHOULD_BUILD" >> $GITHUB_ENV
	echo "SHOULD_DEPLOY=$SHOULD_DEPLOY" >> $GITHUB_ENV
fi