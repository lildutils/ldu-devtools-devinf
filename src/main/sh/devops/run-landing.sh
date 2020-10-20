#!/bin/bash

## import core scripts

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
    _healthCheck

    networkName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.networkName")

    containerName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.landing.containerName")
    portNumber=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.landing.portNumber")

    version=$1

    defaultRegion=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.landing.defaultRegion")
    region=$2

    task=run-comingsoon

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
    $logger "logInfo" "container:stop..."
    sudo docker container kill $containerName-$region
    $logger "logInfo" "container:stop"

    $logger "logInfo" "container:remove..."
    sudo docker container rm $containerName-$region
    $logger "logInfo" "container:remove"

    $logger "logInfo" "image:update..."
    sudo docker login
    sudo docker pull ndworks/hub-images:$containerName-$region-$version
    $logger "logInfo" "image:update"

    $logger "logInfo" "container:run..."
    sudo docker container run -d \
        --name=$containerName-$region \
        --network=$networkName \
        -p 127.0.0.1:$portNumber:8080 \
        ndworks/hub-images:$containerName-$region-$version
    $logger "logInfo" "container:run"

    $logger "logDebug" "@see logs: sudo docker logs -f ${containerName}-${region}"
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
        $utils "printSuccessFooter" "${containerName}-${region}-${version}"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate version"
    if [ -z "$version" ]; then
        $logger "logError" "'version' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
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

main "$1" "$2"
