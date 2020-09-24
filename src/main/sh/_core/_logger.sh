#!/bin/bash

main() {
    logLevel=$(node -p -e "require('${PWD}/DEV-INF/configs.json').logLevel")
    logMethod=$1
    logMessage=$2

    if [ -z "$logMethod" ]; then
        echo "'log method' is required"
        exit 1
    fi

    if [ -z "$logMessage" ]; then
        echo "'log message' is required"
        exit 1
    fi

    if [ "$logLevel" == "DEBUG" ]; then
        if [ "$logMethod" == "logDebug" ]; then
            _logDebug "$logMessage"
        else
            if [ "$logMethod" == "logInfo" ]; then
                _logInfo "$logMessage"
            else
                if [ "$logMethod" == "logWarn" ]; then
                    _logWarn "$logMessage"
                else
                    if [ "$logMethod" == "logError" ]; then
                        _logError "$logMessage"
                    fi
                fi
            fi
        fi
    else
        if [ "$logLevel" == "INFO" ]; then
            if [ "$logMethod" == "logInfo" ]; then
                _logInfo "$logMessage"
            else
                if [ "$logMethod" == "logWarn" ]; then
                    _logWarn "$logMessage"
                else
                    if [ "$logMethod" == "logError" ]; then
                        _logError "$logMessage"
                    fi
                fi
            fi
        else
            if [ "$logLevel" == "WARN" ]; then
                if [ "$logMethod" == "logWarn" ]; then
                    _logWarn "$logMessage"
                else
                    if [ "$logMethod" == "logError" ]; then
                        _logError "$logMessage"
                    fi
                fi
            else
                if [ "$logLevel" == "ERROR" ]; then
                    if [ "$logMethod" == "logError" ]; then
                        _logError "$logMessage"
                    fi
                else
                    _logError "Unknown log level: ${logLevel}"
                    exit 1
                fi
            fi
        fi
    fi
    exit 0
}

_logDebug() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [DEBUG]: ${logMessage}"
}

_logInfo() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ INFO]: ${logMessage}"
}

_logWarn() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ WARN]: ${logMessage}"
}

_logError() {
    logMessage=$1
    now=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${now}] [ERROR]: ${logMessage}"
}

main $1 "$2"
