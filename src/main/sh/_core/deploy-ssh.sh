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

    sshUser=$(node -p -e "require('${PWD}/DEV-INF/configs.json').sshUser")
    sshDomain=$(node -p -e "require('${PWD}/DEV-INF/configs.json').sshDomain")
    sshKey=$(node -p -e "require('${PWD}/DEV-INF/configs.json').sshKey")
    sshRun=$(node -p -e "require('${PWD}/DEV-INF/configs.json').sshRun")

    task=deploy-ssh
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
}

_validate() {
    _validateArgs
}

_deploy() {
    _deploySSH
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

    $logger "logInfo" "validateArgs"
}

_deploySSH() {
    $logger "logInfo" "deploy:ssh..."

    $logger "logDebug" "ssh to ${sshUser}@${sshDomain}"

    ssh -t -i $sshKey $sshUser@$sshDomain "${sshRun}"

    $logger "logInfo" "deploy:ssh"
}

## run

main
