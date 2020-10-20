#!/bin/bash

## set relative path first to DEV-INF
## only for crontab, because of the relative path is not match the required one
## have to change the directory to ${PWD} where the DEV-INF folder is

if [ -z "$PATH_TO_DEVINF_ROOT" ]; then
    logMessage="'PATH_TO_DEVINF_ROOT' is required env variable"
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ERROR] ${logMessage}"
    echo "[${now}] [ERROR] run in terminal: 'export PATH_TO_DEVINF_ROOT=/path/to/DEV-INF/'"
    exit 1
fi

cd "${PATH_TO_DEVINF_ROOT}"

./backup.sh
