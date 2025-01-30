#!/usr/bin/env bash
set -o errexit

COUNT=$((RANDOM%3))
echo $COUNT

if [[ "${COUNT}" == "1" ]]; then
    exit 0
else
    exit 1
fi
