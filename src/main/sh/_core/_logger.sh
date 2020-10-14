#!/bin/bash

## main

main() {
    if [ -z "$1" ]; then
        echo "'log method' is required"
        exit 1
    fi

    if [ -z "$2" ]; then
        echo "'log message' is required"
        exit 1
    fi

    logLevel=$(node -p -e "require('${PWD}/DEV-INF/configs.json').logLevel")
    if [ -z "$logLevel" ]; then
        logLevel=DEBUG
    fi

    if [ "$logLevel" == "DEBUG" ]; then
        if [ "$1" == "logDebug" ]; then
            _logDebug "$2"
            exit 0
        fi
        if [ "$1" == "logInfo" ]; then
            _logInfo "$2"
            exit 0
        fi
        if [ "$1" == "logWarn" ]; then
            _logWarn "$2"
            exit 0
        fi
        if [ "$1" == "logError" ]; then
            _logError "$2"
            exit 0
        fi
    fi

    if [ "$logLevel" == "INFO" ]; then
        if [ "$1" == "logInfo" ]; then
            _logInfo "$2"
            exit 0
        fi
        if [ "$1" == "logWarn" ]; then
            _logWarn "$2"
            exit 0
        fi
        if [ "$1" == "logError" ]; then
            _logError "$2"
            exit 0
        fi
    fi

    if [ "$logLevel" == "WARN" ]; then
        if [ "$1" == "logWarn" ]; then
            _logWarn "$2"
            exit 0
        fi
        if [ "$1" == "logError" ]; then
            _logError "$2"
            exit 0
        fi
    fi

    if [ "$logLevel" == "ERROR" ]; then
        if [ "$1" == "logError" ]; then
            _logError "$2"
            exit 0
        fi
    fi

    _log "$2"
    exit 0
}

## tasks

_logDebug() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    $logCMD "[${now}] [DEBUG] ${logMessage}"
}

_logInfo() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    $logCMD "[${now}] [ INFO] ${logMessage}"
}

_logWarn() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    $logCMD "[${now}] [ WARN] ${logMessage}"
}

_logError() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    $logCMD "[${now}] [ERROR] ${logMessage}"
}

_log() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    $logCMD "[${now}] [  LOG] ${logMessage}"
}

## run

main "$1" "$2"
