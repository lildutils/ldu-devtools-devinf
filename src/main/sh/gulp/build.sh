#!/bin/bash

## import core scripts

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

## main

main() {
    _init "$1" "$2"
    _validate
    _analyze
    _build
    _zipIt
    _exit
}

## tasks

_init() {
    _healthCheck

    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectBuildName")
    projectVersion=$(node -p -e "require('${PWD}/package.json').version")
    projectBuildName=$projectName

    defaultProfile=$(node -p -e "require('${PWD}/DEV-INF/configs.json').defaultProfile")
    activeProfile=$1

    publishIt=$2
    if [ -z "$publishIt" ]; then
        if [ "$1" == "--publish" ]; then
            activeProfile=$default
            publishIt=true
        fi
    else
        if [ "$2" == "--publish" ]; then
            publishIt=true
        fi
    fi

    npmjsRegistryRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').npmjsRegistryRootURL")
    npmjsPackagesRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').npmjsPackagesRootURL")

    task=build

    _clearScreen

    _printHeader
}

_healthCheck() {
    $checker checkConfigsJsonExists
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkPackageJsonExists
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkNodeInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkNpmInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkZipInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi
}

_validate() {
    _validateArgs
}

_analyze() {
    _codeAnalyze
}

_build() {
    _cleanDist

    _buildDist

    if [ "$publishIt" == "true" ]; then
        _publishDist
    fi

    _copyFiles
}

_zipIt() {
    _zipFiles
}

_exit() {
    _printFooter

    exit 0
}

## functions

_clearScreen() {
    clearScreenBeforeRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').clearScreenBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi
}

_printHeader() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').printHeaderToScreen")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi

    $logger "logInfo" "${task}..."
}

_printFooter() {
    $logger "logInfo" "${task}"

    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').printHeaderToScreen")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printSuccessFooter" "${activeProfile} @ ${projectName}-${projectVersion}"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

    $logger "logDebug" "validate projectName"
    if [ -z "$projectName" ]; then
        $logger "logError" "'project name' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate projectVersion"
    if [ -z "$projectVersion" ]; then
        $logger "logError" "'project version' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate projectBuildName"
    if [ -z "$projectBuildName" ]; then
        $logger "logError" "'project build name' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate activeProfile"
    if [ -z "$activeProfile" ]; then
        $logger "logDebug" "activating default profile"
        activeProfile=${defaultProfile}

        if [ -z "$activeProfile" ]; then
            $logger "logError" "'active profile' is required"
            $logger "logInfo" "validateArgs"
            $logger "logInfo" "${task}"
            if [ "$printHeaderToScreen" == "true" ]; then
                $utils "printFailedFooter"
            fi
            exit 1
        fi
    fi

    $logger "logDebug" "check if zip folder exists"
    zipFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').zipFolder")
    if [ -z "$zipFolder" ]; then
        $logger "logDebug" "creating zip folder for build archives"
        mkdir $zipFolder

        if [ ! -d "$zipFolder" ]; then
            $logger "logError" "'zip folder' is required"
            $logger "logInfo" "validateArgs"
            $logger "logInfo" "${task}"
            if [ "$printHeaderToScreen" == "true" ]; then
                $utils "printFailedFooter"
            fi
            exit 1
        fi
    fi

    $logger "logInfo" "validateArgs"
}

_codeAnalyze() {
    $logger "logInfo" "codeAnalyze..."
    $logger "logDebug" "linter is not configured yet"
    $logger "logInfo" "codeAnalyze"
}

_cleanDist() {
    $logger "logInfo" "cleanDist..."
    $utils "cleanDist"
    $logger "logInfo" "cleanDist"
}

_buildDist() {
    $logger "logInfo" "gulpBuild..."

    $logger "logDebug" "project: ${projectName}-${projectVersion}"
    $logger "logDebug" "with profile: '${activeProfile}'"

    ./node_modules/.bin/gulp build --activeProfile=${activeProfile}

    $logger "logInfo" "gulpBuild"
}

_publishDist() {
    $logger "logInfo" "npmPublish..."

    $logger "logDebug" "npm registry: ${npmjsRegistryRootURL}"
    $logger "logDebug" "project: ${projectName}-${projectVersion}"

    cd dist/
    npm publish --access public
    cd ..

    $logger "logDebug" " ${npmjsPackagesRootURL}/package/${projectBuildName}"

    $logger "logInfo" "npmPublish"
}

_copyFiles() {
    $logger "logInfo" "copyFiles..."
    $logger "logDebug" "np files to copy"
    $logger "logInfo" "copyFiles"
}

_zipFiles() {
    $logger "logInfo" "zipIt..."

    now=$(date +"%Y%m%d%H%M%S")
    $zipit "${projectName}-${projectVersion}-${now}"

    $logger "logInfo" "zipIt"
}

## run

main "$1" "$2"
