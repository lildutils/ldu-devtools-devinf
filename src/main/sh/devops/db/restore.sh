#!/bin/bash

## import core scripts

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

## main

main() {
    _init "$1"
    _validate
    _run
    _exit
}

## tasks

_init() {
    _healthCheck

    containerName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.containerName")

    databaseName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.name")
    databaseUser=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.user")
    databasePassword=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.password")

    databaseDump=$1

    task=run-db-restore

    _clearScreen

    _printHeader
}

_healthCheck() {
    $checker checkConfigsJsonExists
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkNodeInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkDockerInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi
}

_validate() {
    _validateArgs
}

_run() {
    $logger "logInfo" "docker-exec:mysql_dump..."
    sudo docker exec -i $containerName sh -c "exec mysql -u${databaseUser} -p${databasePassword} ${databaseName}" <$databaseDump
    $logger "logInfo" "docker-exec:mysql_dump"
}

_exit() {
    _printFooter

    exit 0
}

## functions

_clearScreen() {
    clearScreenBeforeRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').clearScreenBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi
}

_printHeader() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').printHeaderToScreen")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi

    $logger "logInfo" "${task}..."
}

_printFooter() {
    $logger "logInfo" "${task}"

    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').printHeaderToScreen")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printSuccessFooter" "database-server START"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate dumpFile"
    if [ -z "$databaseDump" ]; then
        $logger "logError" "'dumpFile' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logInfo" "validateArgs"
}

## run

main "$1"