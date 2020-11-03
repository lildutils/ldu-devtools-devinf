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
    task=admin-start

    _healthCheck

    networkName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.networkName")

    containerName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.admin.containerName")

    redirectPortNumber=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.admin.redirectPortNumber")
    dockerPortNumber=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.admin.dockerPortNumber")

    defaultRegion=$(node -p -e "require('${PWD}/DEV-INF/configs.json').frontend.admin.defaultRegion")

    version=$1

    region=$2

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
    _start
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
        $utils "printSuccessFooter" "${containerName}-${region}-${version}"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate networkName"
    if [ -z "$networkName" ]; then
        $logger "logError" "'network name' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

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

    $logger "logDebug" "validate dockerPortNumber"
    if [ -z "$dockerPortNumber" ]; then
        $logger "logError" "'container port' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate redirectPortNumber"
    if [ -z "$redirectPortNumber" ]; then
        $logger "logError" "'redirect port' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate defaultRegion"
    if [ -z "$defaultRegion" ]; then
        $logger "logError" "'default reion' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate region"
    if [ -z "$region" ]; then
        region=$defaultRegion

        if [ -z "$region" ]; then
            $logger "logError" "'reion' is required"
            $logger "logInfo" "validateArgs"
            $logger "logInfo" "${task}"
            if [ "$printHeaderToScreen" == "true" ]; then
                $utils "printFailedFooter"
            fi
            exit 1
        fi
    fi

    $logger "logDebug" "validate version"
    if [ -z "$version" ]; then
        $logger "logError" "'image version' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logInfo" "validateArgs"
}

_start() {
    $logger "logInfo" "docker:login..."
    dockerUsername=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.username")
    dockerUserpass=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.password")
    $dockerit "login" "-u ${dockerUsername} -p ${dockerUserpass}"
    if [ "$?" == "1" ]; then
        exit 1
    fi
    $logger "logInfo" "docker:login"

    $logger "logInfo" "container:stop..."
    docker container kill $containerName-$region
    $logger "logInfo" "container:stop"

    $logger "logInfo" "container:remove..."
    docker container rm $containerName-$region
    $logger "logInfo" "container:remove"

    $logger "logInfo" "image:update..."
    dockerRegistryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.registryURL")
    docker pull $dockerRegistryURL:$containerName-$region-$version
    $logger "logInfo" "image:update"

    $logger "logInfo" "container:run..."
    docker container run -d \
        --name=$containerName-$region \
        --network=$networkName \
        -p 127.0.0.1:$redirectPortNumber:$dockerPortNumber \
        $dockerRegistryURL:$containerName-$region-$version
    $logger "logInfo" "container:run"

    $logger "logDebug" "@see logs: 'docker logs -f ${containerName}-${region}'"
}

## run

main "$1" "$2"
