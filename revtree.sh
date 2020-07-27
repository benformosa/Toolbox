#!/bin/bash
# List all parent directories
# Adapted from https://unix.stackexchange.com/a/5862
ARG=$1
while [[ "$ARG" != "." && "$ARG" != "/" ]]
do
    echo "${ARG}"
    ARG=`dirname -- "$ARG"`
done
