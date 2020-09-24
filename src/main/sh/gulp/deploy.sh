#!/bin/bash

logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh

main() {
    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectName")
    npmjsRegistryName=$(node -p -e "require('${PWD}/package.json').name")
    projectVersion=$(node -p -e "require('${PWD}/package.json').version")
    task=deploy

    clearScreenBeforeRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').clearScreenBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi

    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').printHeaderToScreen")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi

    $logger "logInfo" "${task}..."

    $logger "logInfo" "validateArgs..."
    $logger "logDebug" "validate projectName"
    if [ -z "$projectName" ]; then
        $logger "logError" "'project name' is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    $logger "logDebug" "validate projectVersion"
    if [ -z "$projectVersion" ]; then
        $logger "logError" "'project version' is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    $logger "logDebug" "check if dist folder exists"
    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').distFolder")
    if [ -z "$distFolder" ]; then
        $logger "logError" "'dist folder' is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    if [ ! -d "$distFolder" ]; then
        $logger "logDebug" "dist folder is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    $logger "logInfo" "validateArgs"

    $logger "logInfo" "publishIt..."
    $logger "logDebug" "npm registry: https://registry.npmjs.org/"
    $logger "logDebug" "project: ${projectName}-${projectVersion}"
    cd dist/
    npm publish --access public
    cd ..
    $logger "logInfo" "publishIt"

    $logger "logInfo" "--------------"
    $logger "logInfo" "${task} SUCCESS - https://www.npmjs.com/package/${npmjsRegistryName}"
    $logger "logInfo" "--------------"
    exit 0
}

main
