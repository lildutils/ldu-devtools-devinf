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
    if [ "$logLevel" == "undefined" ]; then
        logLevel=DEBUG
    fi
    if [ "$logLevel" == "null" ]; then
        logLevel=DEBUG
    fi
    if [ "$logLevel" == "" ]; then
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
    echo "[${now}] [DEBUG] ${logMessage}"
    exit 0
}

_logInfo() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ INFO] ${logMessage}"
    exit 0
}

_logWarn() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ WARN] ${logMessage}"
    exit 0
}

_logError() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ERROR] ${logMessage}"
    exit 0
}

_log() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [  LOG] ${logMessage}"
    exit 0
}

## run

main "$1" "$2"
