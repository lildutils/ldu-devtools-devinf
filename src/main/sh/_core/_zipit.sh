#!/bin/bash

## imports

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    file=$1

    # configs

    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.distFolder")
    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.zip.outputFolder")
    zipInSilent=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.zip.silentMode")

    # validate

    if [ -z "$file" ]; then
        $logger "logError" "'file' is required"
        exit 1
    fi

    if [ ! -d "$distFolder" ]; then
        $logger "logError" "'distFolder' is required"
        exit 1
    fi

    if [ ! -d "$zipFolder" ]; then
        $logger "logError" "'zipFolder' is required"
        exit 1
    fi

    # process

    $logger "logDebug" "zipping..."

    $logger "logDebug" "create zip ${PWD}/${distFolder}/${file}.zip"
    cd "$distFolder"
    if [ "$zipInSilent" == "true" ]; then
        zip -rq "${file}.zip" .
    else
        zip -r "${file}.zip" .
    fi
    cd ..

    $logger "logDebug" "copy zip ${PWD}/${distFolder} --> ${zipFolder}"
    cp "${distFolder}/${file}.zip" "${zipFolder}/"

    $logger "logDebug" "clean zip ${distFolder}/"
    rm "${distFolder}/${file}.zip"

    $logger "logDebug" "zipped"
}

## run

main "$1"
