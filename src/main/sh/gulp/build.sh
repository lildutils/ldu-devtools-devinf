#!/bin/bash

logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

gulp=./node_modules/.bin/gulp

main() {
    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectName")
    projectVersion=$(node -p -e "require('./package.json').version")
    activeProfile=$1
    task=build

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
    $logger "logDebug" "validate activeProfile"
    if [ -z "$activeProfile" ]; then
        $logger "logDebug" "activating default profile"
        activeProfile=prod
    fi
    $logger "logDebug" "check if zip folder exists"
    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")
    if [ -z "$zipFolder" ]; then
        $logger "logError" "'zip folder' is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    if [ ! -d "$zipFolder" ]; then
        $logger "logDebug" "creating zip folder for build archives"
        mkdir $zipFolder
    fi
    $logger "logInfo" "validateArgs"

    $logger "logInfo" "codeAnalyze..."
    $logger "logWarn" "linter is not configured yet"
    $logger "logInfo" "codeAnalyze"

    $logger "logInfo" "cleanDist..."
    $utils "cleanDist"
    $logger "logInfo" "cleanDist"

    $logger "logInfo" "gulpBuild..."
    $logger "logDebug" "project: ${projectName}-${projectVersion}"
    $logger "logDebug" "with profile: '${activeProfile}'"
    $gulp build --activeProfile=${activeProfile}
    $logger "logInfo" "gulpBuild"

    $logger "logInfo" "zipIt..."
    now=$(date +"%Y%m%d%H%M%S")
    $zipit "${projectName}-${projectVersion}-${now}"
    $logger "logInfo" "zipIt"

    $logger "logInfo" "--------------"
    $logger "logInfo" "${task} SUCCESS - ${activeProfile} @ ${projectName}-${projectVersion}"
    $logger "logInfo" "--------------"
    exit 0
}

main
