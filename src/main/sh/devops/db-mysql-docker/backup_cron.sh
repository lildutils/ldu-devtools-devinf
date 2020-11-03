#!/bin/bash

PATH_TO_DEVINF_ROOT=

main() {
    # PATH_TO_DEVINF_ROOT
    ## set relative path to DEV-INF only for crontab
    ## because of the relative path is not match the required one
    ## so have to change the directory to ${PWD}
    ## where the DEV-INF folder is
    ## --> this section can be deleted after setup
    if [ -z "$PATH_TO_DEVINF_ROOT" ]; then
        logMessage="Missing a required variable, please set the PATH_TO_DEVINF_ROOT"
        now=$(date +"%Y-%m-%d %H:%M:%S")
        echo "[${now}] [ERROR] ${logMessage}"
        exit 1
    fi
    # /PATH_TO_DEVINF_ROOT

    # DB_BACKUPS_BY_DB_NAME
    ## --> this section can be deleted after setup
    logMessage="CHECK the database names for backup runners, see examples below..."
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ WARN] ${logMessage}"
    exit 1
    # /DB_BACKUPS_BY_DB_NAME

    cd "$PATH_TO_DEVINF_ROOT"

    _runbBackup "$databaseName1"

    _runbBackup "$databaseName2"
}

_runBackup() {
    databaseName=$1
    source ${PWD}/DEV-INF/backup.sh $databaseName
}

main
