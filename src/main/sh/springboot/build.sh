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
    _build
    _exit
}

## tasks

_init() {
    task=build

    _healthCheck

    projectName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.name")
    projectVersion=$(./gradlew -q printProjectVersion)

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

    $checker checkJavaInstalled
    if [ "$?" == "1" ]; then
        exit 1
    fi

    $checker checkGradlewInstalled
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

_build() {
    _codeAnalyze

    _cleanDist

    if [ "$installIt" == "true" ]; then
        _gradleInstall
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
        activeProfile=$defaultProfile

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

    $logger "logInfo" "cleanDist"
}

_buildDist() {
    $logger "logInfo" "gradleBuild..."

    $logger "logDebug" "project = '${projectName}'"
    $logger "logDebug" "version = '${projectVersion}'"
    $logger "logDebug" "profile = '${activeProfile}'"

    gradlewInSilent=$(node -p -e "require('${PWD}/DEV-INF/configs.json').gradleBuild.silentMode")
    if [ "$gradlewInSilent" == "true" ]; then
        ./gradlew build -q
    else
        ./gradlew build
    fi

    $logger "logInfo" "gradleBuild"
}

_publishDist() {
    mavenCentralRootURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').registry.mavenCentral.rootURL")
    mavenCentralRegistryURL=$(node -p -e "require('${PWD}/DEV-INF/configs.json').registry.mavenCentral.registryURL")

    $logger "logInfo" "gradlePublish..."

    $logger "logDebug" "registry: "
    $logger "logDebug" "project: ${projectName}-${projectVersion}"

    if [ "$gradlewInSilent" == "true" ]; then
        ./gradlew publish -q
    else
        ./gradlew publish
    fi

    $logger "logDebug" " ${mavenCentralRootURL}/${projectName}"

    $logger "logInfo" "gradlePublish"
}

_copyFiles() {
    buildFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.buildFolder")
    buildName=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.buildName")
    distFolder=$(node -p -e "require('${PWD}/DEV-INF/configs.json').project.distFolder")

    $logger "logInfo" "copyFiles..."

    $logger "logDebug" "copy jar file"
    $utils "copyFile" "${PWD}/${buildFolder}/libs/${projectName}-${projectVersion}.jar" "${PWD}/${distFolder}/${buildName}.jar"

    $logger "logDebug" "copy configuration file"
    $utils "copyFile" "${PWD}/src/main/resources/application-${activeProfile}.properties" "${PWD}/${distFolder}/application.properties"

    skipSSLcertCopy=$(node -p -e "require('${PWD}/DEV-INF/configs.json').skipSSLcertCopy")
    if [ ! "$skipSSLcertCopy" == "true" ]; then
        $logger "logDebug" "copy Java SSL cacerts"
        $utils "copyFile" "${PWD}/src/main/resources/certs/java-cacerts" "${PWD}/${distFolder}/cacerts"
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
