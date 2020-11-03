#!/bin/bash

## imports

checker=${PWD}/DEV-INF/_checker.sh
dockerIt=${PWD}/DEV-INF/_dockerIt.sh
logger=${PWD}/DEV-INF/_logger.sh
utils=${PWD}/DEV-INF/_utils.sh
zipit=${PWD}/DEV-INF/_zipit.sh

## main

main() {
    _init "$1" "$2"
    _validate
    _run
    _exit
}

## tasks

_init() {
    task=build

    _healthCheck

    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.name")
    projectVersion=$(node -p -e "require('${PWD}/package.json').version")

    confFile=$(node -p -e "require('${PWD}/DEV-INF/configs.json').ngBuild.confFile")

    defaultProfile=$(node -p -e "require('${PWD}/DEV-INF/configs.json').defaultProfile")

    activeProfile=$1
    args=$2

    installIt=false
    publishIt=false

    if [ ! -z "$1"]; then
        if [ "$1" == "--publish" ]; then
            activeProfile=$defaultProfile
            installIt=false
            publishIt=true
        fi

        if [ "$1" == "--install" ]; then
            activeProfile=$defaultProfile
            installIt=true
            publishIt=false
        fi
    fi

    if [ ! -z "$args"]; then
        if [ "$args" == "--publish" ]; then
            activeProfile=$defaultProfile
            installIt=false
            publishIt=true
        fi

        if [ "$args" == "--install" ]; then
            activeProfile=$defaultProfile
            installIt=true
            publishIt=false
        fi
    fi

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

    $checker checkNpmInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkGulpCliInstalled
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

_run() {
    _codeAnalyze

    _cleanDist

    if [ "$installIt" == "true" ]; then
        _npmInstall
    fi

    _buildDist

    _copyFiles

    if [ "$publishIt" == "true" ]; then
        _publishDist
    fi

    _zipFiles
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

    $logger "logDebug" "validate defaultProfile"
    if [ -z "$defaultProfile" ]; then
        $logger "logError" "'default profile' is required"
        $logger "logInfo" "validateArgs"
        $logger "logInfo" "${task}"
        if [ "$printHeaderToScreen" == "true" ]; then
            $utils "printFailedFooter"
        fi
        exit 1
    fi

    $logger "logDebug" "validate activeProfile"
    if [ -z "$activeProfile" ]; then
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

    $utils "makeDist"

    $utils "makeConf"

    $logger "logInfo" "cleanDist"
}

_buildDist() {
    $logger "logInfo" "gulpBuild..."

    $logger "logDebug" "project = '${projectName}'"
    $logger "logDebug" "version = '${projectVersion}'"
    $logger "logDebug" "profile = '${activeProfile}'"

    ./node_modules/.bin/gulp build --activeProfile=${activeProfile}

    $logger "logInfo" "gulpBuild"
}

_publishDist() {
    npmjsRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').registry.npmjs.rootURL")
    npmjsRegistryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').registry.npmjs.registryURL")

    $logger "logInfo" "npmPublish..."

    $logger "logDebug" "registry (public): ${npmjsRegistryURL}"
    $logger "logDebug" "project: ${projectName}-${projectVersion}"

    cd dist/
    npm publish --access public
    cd ..

    $logger "logDebug" " ${npmjsRootURL}/package/${projectName}"

    $logger "logInfo" "npmPublish"
}

_copyFiles() {
    confFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.confFolder")

    $logger "logInfo" "copyFiles..."

    if [ "$confFileType" == "NGINX" ]; then
        if [ -f "$confFile" ]; then
            $utils "copyFile" "$PWD/$confFile" "$PWD/$confFolder/nginx.conf"
        fi
    fi

    if [ "$confFileType" == "HTACCESS" ]; then
        if [ -f "$confFile" ]; then
            $utils "copyFile" "$PWD/$confFile" "$PWD/$confFolder/.htaccess"
        fi
    fi

    $logger "logInfo" "copyFiles"
}

_zipFiles() {
    $logger "logInfo" "zipFiles..."

    $utils "makeZip"

    now=$(date +"%Y%m%d%H%M%S")
    $zipit "${projectName}-${projectVersion}-${now}"

    $logger "logInfo" "zipFiles"
}

## run

main "$1" "$2"
