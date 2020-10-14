#!/bin/bash

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
    _deploy
    _exit
}

## tasks

_init() {
    _healthCheck

    projectName=$(./gradlew -q printProjectName)
    projectVersion=$1
    projectBuildName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').projectBuildName")

    dockerRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerRootURL")
    dockerRepositoryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerRepositoryURL")
    dockerHub=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHubLink")

    task=deploy
}

_healthCheck() {
    $checker checkConfigsJsonExists
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkNodeInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkJavaInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkGradlewInstalled
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

_deploy() {
    _deployDist
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
        $utils "printSuccessFooter" "${dockerRepositoryURL}/${dockerHub}/tags?name=${projectName}-${projectVersion}"
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
        $logger "logDebug" "activating default version"
        projectVersion=$(./gradlew -q printProjectVersion)

        if [ -z "$projectVersion" ]; then
            $logger "logError" "'project version' is required"
            $logger "logInfo" "validateArgs"
            $logger "logInfo" "${task}"
            if [ "$printHeaderToScreen" == "true" ]; then
                $utils "printFailedFooter"
            fi
            exit 1
        fi
    fi

    $logger "logDebug" "validate dockerRootURL"
    if [ -z "$dockerRootURL" ]; then
        $logger "logError" "'docker root URL' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate dockerRepositoryURL"
    if [ -z "$dockerRepositoryURL" ]; then
        $logger "logError" "'docker repository URL' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate dockerHub"
    if [ -z "$dockerHub" ]; then
        $logger "logError" "'docker hub URL' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "check if dist folder exists"
    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').distFolder")
    if [ -z "$distFolder" ]; then
        $logger "logError" "'dist folder' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logInfo" "validateArgs"
}

_deployDist() {
    $logger "logInfo" "dockerIt..."

    $logger "logDebug" "docker repository: ${dockerRootURL}/${dockerHub}"
    $logger "logDebug" "docker image: ${projectName}"
    $logger "logDebug" "docker tag: ${projectVersion}"

    $dockerit "login"

    $dockerit "build" "$dockerHub:$projectName-$projectVersion"

    $dockerit "push" "$dockerHub:$projectName-$projectVersion"

    $logger "logInfo" "dockerIt"
}

## run

main "$1"
