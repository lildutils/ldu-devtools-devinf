#!/bin/bash

logger=./DEV-INF/_logger.sh
utils=./DEV-INF/_utils.sh
zipit=./DEV-INF/_zipit.sh

javalinter=./DEV-INF/_javalinter.sh

gradlew=./gradlew

main() {
    projectName=$(./gradlew -q printProjectName)
    projectVersion=$(./gradlew -q printProjectVersion)
    activeProfile=$1
    task=build

    clearScreenBeforeRun=$(node -p -e "require('./DEV-INF/configs.json').clearScreenBeforeRun")
    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi

    printHeaderToScreen=$(node -p -e "require('./DEV-INF/configs.json').printHeaderToScreen")
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
    if [ ! -d "zip" ]; then
        $logger "logDebug" "creating zip folder for build archives"
        mkdir zip
    fi
    $logger "logInfo" "validateArgs"

    $logger "logInfo" "codeAnalyze..."
    $javalinter "codeAnalyze"
    $logger "logInfo" "codeAnalyze"

    $logger "logInfo" "cleanDist..."
    $utils "cleanDist"
    $logger "logInfo" "cleanDist"

    $logger "logInfo" "gradleBuild..."
    $logger "logDebug" "project: ${projectName}-${projectVersion}"
    $logger "logDebug" "with profile: '${activeProfile}'"
    gradlewInSilent=$(node -p -e "require('./DEV-INF/configs.json').gradlewInSilent")
    if [ "$gradlewInSilent" == "true" ]; then
        $gradlew build -q
    else
        $gradlew build
    fi
    $logger "logInfo" "gradleBuild"

    $logger "logInfo" "copyFiles..."
    $logger "logDebug" "copy jar file"
    $utils "copyFile" "build/libs/${projectName}-${projectVersion}.jar" "dist/backend.jar"
    $logger "logDebug" "copy configuration file"
    $utils "copyFile" "src/main/resources/application-${activeProfile}.properties" "dist/application.properties"
    $logger "logDebug" "copy SSL cert"
    skipSSLcertCopy=$(node -p -e "require('./DEV-INF/configs.json').skipSSLcertCopy")
    if [ "$skipSSLcertCopy" == "true" ]; then
        $logger "logDebug" "copy java SSL cacerts skipped"
    else
        $logger "logDebug" "copy Java SSL cacerts"
        $utils "copyFile" "/etc/ssl/certs/java/cacerts" "dist/cacerts" "true"
    fi
    $logger "logInfo" "copyFiles"

    $logger "logInfo" "zipIt..."
    now=$(date +"%Y%m%d%H%M%S")
    $zipit "${projectName}-${projectVersion}-${now}"
    $logger "logInfo" "zipIt"

    $logger "logInfo" "--------------"
    $logger "logInfo" "${task} SUCCESS - ${activeProfile} @ ${projectName}-${projectVersion}"
    $logger "logInfo" "--------------"
    exit 0
}

main $1
