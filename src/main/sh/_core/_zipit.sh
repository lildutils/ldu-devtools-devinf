#!/bin/bash

## import core scripts

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    file=$1
    if [ -z "$file" ]; then
        $logger "logError" "'file' is required"
        exit 1
    fi

    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').distFolder")
    if [ ! -d "$distFolder" ]; then
        $logger "logError" "'distFolder' is required"
        exit 1
    fi

    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")
    if [ ! -d "$zipFolder" ]; then
        $logger "logError" "'zipFolder' is required"
        exit 1
    fi

    $logger "logDebug" "zip files --recursive in ${PWD}/${distFolder}/${file}.zip"
    cd "$distFolder"

    zipInSilent=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipInSilent")
    if [ "$zipInSilent" == "true" ]; then
        zip -rq "${file}.zip" .
    else
        zip -r "${file}.zip" .
    fi
    cd ..

    $logger "logDebug" "copy zip file from ${PWD}/${distFolder}/ to ${zipFolder}/"
    cp "${distFolder}/${file}.zip" "${zipFolder}/"

    $logger "logDebug" "clean ${distFolder}/"
    rm "${distFolder}/${file}.zip"
}

## run

main "$1"
