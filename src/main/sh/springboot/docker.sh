#!/bin/bash

## imports

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

## main

main() {
    _init "$1"
    _validate
    _run
    _exit
}

## tasks

_init() {
    task=dockerIt

    _healthCheck

    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.name")
    packageVersion=$(./gradlew -q printProjectVersion)

    projectVersion=$1

    _clearScreen

    _printHeader

    $logger "logInfo" "${task}..."
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

    $checker checkDockerInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkDockerfileExists
    if [ "$?" == "1" ]; then
        exit 1
    fi
}

_validate() {
    _validateArgs
}

_run() {
    _dockerDist
}

_exit() {
    $logger "logInfo" "${task}"

    _printFooter

    exit 0
}

## functions

_clearScreen() {
    clearScreenBeforeRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.clearBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi
}

_printHeader() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.printHeader")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi
}

_printFooter() {
    printHeaderToScreen=$(node -p -e "require('${PWD}/DEV-INF/configs.json').screen.printHeader")
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printSuccessFooter" "${dockerHubURL}/tags?name=${projectName}-${projectVersion}"
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

    $logger "logDebug" "validate packageVersion"
    if [ -z "$packageVersion" ]; then
        $logger "logError" "'package version' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate projectVersion"
    if [ -z "$projectVersion" ]; then
        projectVersion=$packageVersion

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

    $logger "logInfo" "validateArgs"
}

_deployDist() {
    dockerRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.rootURL")
    dockerRepositoryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.repositoryURL")
    dockerRegistryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.registryURL")
    dockerUsername=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.username")
    dockerUserpass=$(node -p -e "require('${PWD}/DEV-INF/configs.json').dockerHub.password")
    dockerHubURL=$(echo ${dockerRepositoryURL}/${dockerRegistryURL})

    $logger "logInfo" "dockerIt..."

    $logger "logDebug" "registry: ${dockerHub}"
    $logger "logDebug" "project: ${projectName}-${projectVersion}"

    $dockerit "login" "-u ${dockerUsername} -p ${dockerUserpass}"
    $dockerit "build" "${dockerHub}:${projectName}-${projectVersion}"
    $dockerit "push" "${dockerHub}:${projectName}-${projectVersion}"

    $logger "logInfo" "dockerIt"
}

## run

main "$1"
