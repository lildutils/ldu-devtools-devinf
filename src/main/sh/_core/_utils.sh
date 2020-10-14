#!/bin/bash

## import core scripts

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    command=$1

    if [ "$command" == "cleanBuild" ]; then
        buildFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').buildFolder")
        _cleanFolder "$buildFolder"
        exit 0
    fi

    if [ "$command" == "cleanDist" ]; then
        distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').distFolder")
        _cleanFolder "$distFolder"
        exit 0
    fi

    if [ "$command" == "cleanZip" ]; then
        zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")
        _cleanFolder "$zipFolder"
        exit 0
    fi

    if [ "$command" == "makeZip" ]; then
        zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")
        _makeFolder "$zipFolder"
        exit 0
    fi

    if [ "$command" == "printHeader" ]; then
        projectHeaderTitle=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectHeaderTitle")
        _printHeader "$projectHeaderTitle"
        exit 0
    fi

    if [ "$command" == "printSuccessFooter" ]; then
        _printSuccessFooter "$2"
        exit 0
    fi

    if [ "$command" == "printFailedFooter" ]; then
        _printFailedFooter
        exit 0
    fi

    if [ "$command" == "copyFile" ]; then
        _copyFile $2 $3 $4
        exit 0
    fi

    exit 0
}

## tasks

_makeFolder() {
    folder=$1

    if [ -z "$folder" ]; then
        exit 0
    fi

    if [ ! -d "$folder" ]; then
        $logger "logDebug" "create ${folder}/"
        mkdir $folder
    fi
}

_cleanFolder() {
    folder=$1

    if [ -z "$folder" ]; then
        exit 0
    fi

    if [ -d "$folder" ]; then
        $logger "logDebug" "remove --recursive ${folder}/"
        rm -rf $folder
    fi

    if [ ! -d "$folder" ]; then
        $logger "logDebug" "create ${folder}/"
        mkdir $folder
    fi
}

_printHeader() {
    title=$1
    echo "=============================================================="
    echo "  ${title}"
    echo "------------------------------------  Powered by LDworks  ----"
}

_printSuccessFooter() {
    buildName=$1
    echo "--------------------------------------------------------------"
    echo "  SUCCESS:  ${buildName}  "
    echo "--------------------------------------------------------------"
}

_printFailedFooter() {
    echo "--------------------------------------------------------------"
    echo "  FAILED:  please run the script again with DEBUG in configs  "
    echo "--------------------------------------------------------------"
}

_copyFile() {
    from=$1
    to=$2
    isSudo=$3
    $logger "logDebug" "copy file from ${from} to ${to}"
    if [ "$isSudo" == "true" ]; then
        sudo cp $from $to
    else
        cp $from $to
    fi
}

## run

main "$1" "$2" "$3" "$4"
