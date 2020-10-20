#!/bin/bash

## import core scripts

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

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

    dockerComposeFile=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.composeFile")

    dataFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.dataFolder")

    dumpFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').db.dumpFolder")

    task=run-db-start

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
    $logger "logInfo" "docker-compose:up..."
    sudo docker-compose -f "${dockerComposeFile}" up -d
    $logger "logInfo" "docker-compose:up"
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

    if [ ! -d "$dataFolder" ]; then
        $logger "logDebug" "creating data folder"
        mkdir "$dataFolder"
    fi

    if [ ! -d "$dumpFolder" ]; then
        $logger "logDebug" "creating dumps folder"
        mkdir "$dumpFolder"
    fi

    $logger "logInfo" "validateArgs"
}

## run

main
