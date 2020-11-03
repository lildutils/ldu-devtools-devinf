#!/bin/bash

## imports

## main

main() {
    logMethod=$1
    if [ -z "$logMethod" ]; then
        echo "'log method' is required"
        exit 1
    fi

    logMessage=$2
    if [ -z "$logMessage" ]; then
        echo "'log message' is required"
        exit 1
    fi

    logLevel=$(node -p -e "require('${PWD}/DEV-INF/configs.json').logger.logLevel")
    if [ -z "$logLevel" ]; then
        logLevel=DEBUG
    fi
    if [ "$logLevel" == "undefined" ]; then
        logLevel=DEBUG
    fi
    if [ "$logLevel" == "null" ]; then
        logLevel=DEBUG
    fi
    if [ "$logLevel" == "" ]; then
        logLevel=DEBUG
    fi

    # process

    if [ "$logLevel" == "DEBUG" ]; then
        if [ "$logMethod" == "logDebug" ]; then
            _logDebug "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logInfo" ]; then
            _logInfo "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logWarn" ]; then
            _logWarn "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logError" ]; then
            _logError "$logMessage"
            exit 0
        fi
    fi

    if [ "$logLevel" == "INFO" ]; then
        if [ "$logMethod" == "logInfo" ]; then
            _logInfo "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logWarn" ]; then
            _logWarn "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logError" ]; then
            _logError "$logMessage"
            exit 0
        fi
    fi

    if [ "$logLevel" == "WARN" ]; then
        if [ "$logMethod" == "logWarn" ]; then
            _logWarn "$logMessage"
            exit 0
        fi
        if [ "$logMethod" == "logError" ]; then
            _logError "$logMessage"
            exit 0
        fi
    fi

    if [ "$logLevel" == "ERROR" ]; then
        if [ "$logMethod" == "logError" ]; then
            _logError "$logMessage"
            exit 0
        fi
    fi

    exit 0
}

## tasks

_logDebug() {
    logMessage=$1
    logLevel=DEBUG
    _log "$logMessage" "$logLevel"
}

_logInfo() {
    logMessage=$1
    logLevel=INFO
    _log "$logMessage" " $logLevel"
}

_logWarn() {
    logMessage=$1
    logLevel=WARN
    _log "$logMessage" " $logLevel"
}

_logError() {
    logMessage=$1
    logLevel=ERROR
    _log "$logMessage" "$logLevel"
}

_log() {
    logMessage=$1
    logLevel=$2
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [${logLevel}] ${logMessage}"
}

## run

main "$1" "$2"
