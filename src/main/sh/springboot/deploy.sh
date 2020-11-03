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
    _deploy
    _exit
}

## tasks

_init() {
    task=deploy

    _healthCheck

    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.name")
    packageVersion=$(./gradlew -q printProjectVersion)

    sshUser=$(node -p -e "require('${PWD}/DEV-INF/configs.json').remote.sshUser")
    sshDomain=$(node -p -e "require('${PWD}/DEV-INF/configs.json').remote.sshDomain")
    sshKey=$(node -p -e "require('${PWD}/DEV-INF/configs.json').remote.sshKey")
    sshRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').remote.sshRun")

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

    $checker checkOpenSSHInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi
}

_validate() {
    _validateArgs
}

_deploy() {
    _deploySSH
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
        $utils "printSuccessFooter" "${projectName}-${projectVersion}"
    fi
}

_validateArgs() {
    $logger "logInfo" "validateArgs..."

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

    $logger "logDebug" "validate sshUser"
    if [ -z "$sshUser" ]; then
        $logger "logError" "'ssh user' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate sshDomain"
    if [ -z "$sshDomain" ]; then
        $logger "logError" "'ssh domain' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate sshKey"
    if [ -z "$sshKey" ]; then
        $logger "logError" "'ssh key' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate sshRun"
    if [ -z "$sshRun" ]; then
        $logger "logError" "'ssh run command' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logInfo" "validateArgs"
}

_deploySSH() {
    $logger "logInfo" "deploy:ssh..."

    $logger "logDebug" "ssh => ${sshUser}@${sshDomain}"
    $logger "logDebug" "run: ${sshRun} '${projectVersion}' && exit"

    ssh -t -i $sshKey $sshUser@$sshDomain "${sshRun} '${projectVersion}' && exit"

    $logger "logInfo" "deploy:ssh"
}

## run

main "$1"
