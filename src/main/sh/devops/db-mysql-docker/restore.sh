#!/bin/bash

## imports

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

## main

main() {
    _init "$1" "$2"
    _validate
    _run
    _exit
}

## tasks

_init() {
    task=db-restore

    _healthCheck

    containerName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').database.server.containerName")

    defaultDatabaseName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').database.connection.databaseName")
    databaseUser=$(node -p -e "require('${PWD}/DEV-INF/configs.json').database.connection.username")
    databasePassword=$(node -p -e "require('${PWD}/DEV-INF/configs.json').database.connection.password")

    databaseName=$1

    databaseDump=$2

    _clearScreen

    _printHeader

    $logger "logInfo" "${task}..."
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
    _restoreIt
}

_exit() {
    $logger "logInfo" "${task}"

    _printFooter

    exit 0
}

## functions

_clearScreen() {
    clearScreenBeforeRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.clearBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi
}

_printHeader() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.printHeader")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi
}

_printFooter() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.printHeader")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printSuccessFooter" "${databaseName} restored"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate containerName"
    if [ -z "$containerName" ]; then
        $logger "logError" "'container name' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate defaultDatabaseName"
    if [ -z "$defaultDatabaseName" ]; then
        $logger "logError" "'default db name' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate databaseUser"
    if [ -z "$databaseUser" ]; then
        $logger "logError" "'db user' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate databasePassword"
    if [ -z "$databasePassword" ]; then
        $logger "logError" "'db passw' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate databaseName"
    if [ -z "$databaseName" ]; then
        databaseName=$defaultDatabaseName

        if [ -z "$databaseName" ]; then
            $logger "logError" "'db name' is required"
            $logger "logInfo" "validateArgs"
            $logger "logInfo" "${task}"
            if [ "$printHeaderToScreen" == "true" ]; then
                $utils "printFailedFooter"
            fi
            exit 1
        fi
    fi

    $logger "logDebug" "validate databaseDump"
    if [ -z "$databaseDump" ]; then
        $logger "logError" "'db dump' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logInfo" "validateArgs"
}

_restoreIt() {
    $logger "logInfo" "docker-exec:mysql-restore..."

    docker exec -i $containerName sh -c "exec mysql -u${databaseUser} -p${databasePassword} ${databaseName}" <$databaseDump

    $logger "logInfo" "docker-exec:mysql-restore"
}

## run

main "$1" "$2"
