#!/bin/bash

logger=${PWD}/DEV-INF/_logger.sh

main() {
    file=$1
    zipInSilent=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipInSilent")
    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")

    if [ -z "$file" ]; then
        $logger "logError" "'file' is required"
        exit 1
    fi

    $logger "logDebug" "zip files -recursive into ${PWD}/dist/${file}.zip"
    cd dist
    if [ "$zipInSilent" == "true" ]; then
        zip -rq "${file}.zip" .
    else
        zip -r "${file}.zip" .
    fi
    cd ..

    $logger "logDebug" "copy zip file from ${PWD}/dist/ to ${zipFolder}/ folder"
    cp "dist/${file}.zip" "${zipFolder}/"

    $logger "logDebug" "clean zip files from dist/ folder"
    rm "dist/${file}.zip"
}

main "$1"
