#!/bin/bash

## imports

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    command=$1
    args=$2

    # configs

    buildFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.buildFolder")
    confFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.confFolder")
    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.distFolder")
    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.zipFolder")
    headerTitle=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.headerTitle")

    # process

    if [ "$command" == "cleanBuild" ]; then
        _cleanFolder "$buildFolder"
        exit 0
    fi

    if [ "$command" == "cleanConf" ]; then
        _cleanFolder "$confFolder"
        exit 0
    fi

    if [ "$command" == "cleanDist" ]; then
        _cleanFolder "$distFolder"
        exit 0
    fi

    if [ "$command" == "cleanZip" ]; then
        _cleanFolder "$zipFolder"
        exit 0
    fi

    if [ "$command" == "makeBuild" ]; then
        _makeFolder "$buildFolder"
        exit 0
    fi

    if [ "$command" == "makeConf" ]; then
        _makeFolder "$confFolder"
        exit 0
    fi

    if [ "$command" == "makeDist" ]; then
        _makeFolder "$distFolder"
        exit 0
    fi

    if [ "$command" == "makeZip" ]; then
        _makeFolder "$zipFolder"
        exit 0
    fi

    if [ "$command" == "printHeader" ]; then
        _printHeader "$headerTitle"
        exit 0
    fi

    if [ "$command" == "printSuccessFooter" ]; then
        _printSuccessFooter "$args"
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

_cleanFolder() {
    folder=$1

    if [ -z "$folder" ]; then
        exit 0
    fi

    if [ -d "$folder" ]; then
        $logger "logDebug" "removing... ${folder}"
        rm -rf $folder
        $logger "logDebug" "removed"
    fi
}

_makeFolder() {
    folder=$1

    if [ -z "$folder" ]; then
        exit 0
    fi

    if [ ! -d "$folder" ]; then
        $logger "logDebug" "creating... ${folder}"
        mkdir $folder
        $logger "logDebug" "created"
    fi
}

_copyFile() {
    from=$1
    to=$2
    isSudo=$3
    $logger "logDebug" "copying... ${from} --> ${to}"
    if [ "$isSudo" == "true" ]; then
        sudo cp $from $to
    else
        cp $from $to
    fi
    $logger "logDebug" "copyed"
}

_printHeader() {
    textMessage=$1
    echo "=============================================================="
    echo "  ${textMessage}"
    echo "====================================  Powered by LDutils  ===="
}

_printSuccessFooter() {
    textMessage=$1
    echo "--------------------------------------------------------------"
    echo "  SUCCESS:  ${textMessage}  "
    echo "--------------------------------------------------------------"
}

_printFailedFooter() {
    echo "--------------------------------------------------------------"
    echo "  FAILED:  please run the script again with DEBUG mode  "
    echo "--------------------------------------------------------------"
}

## run

main "$1" "$2" "$3" "$4"
