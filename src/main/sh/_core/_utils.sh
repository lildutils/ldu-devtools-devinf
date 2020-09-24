#!/bin/bash

logger=${PWD}/DEV-INF/_logger.sh

main() {
    projectHeaderTitle=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectHeaderTitle")
    command=$1

    if [ "$command" == "cleanBuild" ]; then
        _cleanBuild
    else
        if [ "$command" == "cleanDist" ]; then
            _cleanDist
        else
            if [ "$command" == "cleanZip" ]; then
                __cleanZip
            else
                if [ "$command" == "printHeader" ]; then
                    _printHeader
                else
                    if [ "$command" == "copyFile" ]; then
                        _copyFile $2 $3 $4
                    else
                        $logger "logError" "Unknown command called: ${PWD}/DEV-INF/_utils.sh ${command}"
                        exit 1
                    fi
                fi
            fi
        fi
    fi
    exit 0
}

_cleanBuild() {
    $logger "logDebug" "remove -recursive ${PWD}/build/ folder"
    rm -rf dist/
    $logger "logDebug" "create ${PWD}/build/ folder"
    mkdir dist/
}

_cleanDist() {
    $logger "logDebug" "remove -recursive ${PWD}/dist/ folder"
    rm -rf dist/
    $logger "logDebug" "create ${PWD}/dist/ folder"
    mkdir dist/
}

_cleanZip() {
    $logger "logDebug" "remove -recursive ${PWD}/zip/ folder"
    rm -rf zip/
    $logger "logDebug" "create ${PWD}/zip/ folder"
    mkdir zip/
}

_printHeader() {
    echo "=================================================="
    echo "  ${projectHeaderTitle} - Powered by LDworks"
    echo "=================================================="
}

_copyFile() {
    from=$1
    to=$2
    isSudo=$3
    $logger "logDebug" "copy from ${from} to ${to}"
    if [ "$isSudo" == "true" ]; then
        sudo cp $from $to
    else
        cp $from $to
    fi
}

main $1 $2 $3 $4
