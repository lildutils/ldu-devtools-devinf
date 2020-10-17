#!/bin/bash

####################
containerName=
port=9080
####################

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

    network=$(node -p -e "require('${PWD}/DEV-INF/configs.json').network")

    version=$1

    task=run_api
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
    $logger "logInfo" "${task}..."

    $logger "logInfo" "container:stop..."
    sudo docker container kill $containerName
    $logger "logInfo" "container:stop"

    $logger "logInfo" "container:remove..."
    sudo docker container rm $containerName
    $logger "logInfo" "container:remove"

    $logger "logInfo" "image:update..."
    sudo docker login
    sudo docker pull ndworks/hub-images:$containerName-$version
    $logger "logInfo" "image:update"

    $logger "logInfo" "container:run..."
    sudo docker container run -d \
        --name=$containerName \
        --network=$network \
        -p 127.0.0.1:$port:9080 \
        ndworks/hub-images:$containerName-$version
    $logger "logInfo" "container:run"

    $logger "logDebug" "sudo docker logs -f ${containerName}"

    $logger "logInfo" "${task}"
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

    $logger "logInfo" "validateArgs"
}

## run

main
