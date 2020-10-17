#!/bin/bash

## import core scripts

checker=${PWD}/devops/DEV-INF/_checker.sh
dockerIt=${PWD}/devops/DEV-INF/_dockerIt.sh
logger=${PWD}/devops/DEV-INF/_logger.sh
utils=${PWD}/devops/DEV-INF/_utils.sh
zipit=${PWD}/devops/DEV-INF/_zipit.sh

## main

main() {
    _init
    _validate
    _run
    _exit
}

## tasks

_init() {
    _healthCheck
}

_healthCheck() {
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
    sudo docker-compose up -d
}

_exit() {
    exit 0
}

## functions

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate version"
    if [ -z "$version" ]; then
        $logger "logError" "'version' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        exit 1
    fi

    $logger "logDebug" "validate region"
    if [ -z "$region" ]; then
        $logger "logDebug" "activate default region: ${defaultRegion}"
        region=$defaultRegion
    fi

    $logger "logInfo" "validateArgs"
}

## run

main
