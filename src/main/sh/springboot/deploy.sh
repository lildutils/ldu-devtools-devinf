#!/bin/bash

logger=./DEV-INF/_logger.sh
utils=./DEV-INF/_utils.sh

dockerit=./DEV-INF/_dockerit.sh

main() {
    projectName=$(./gradlew -q printProjectName)
    projectVersion=$1
    dockerHub=$(node -p -e "require('./DEV-INF/configs.json').dockerHubLink")
    clearScreenBeforeRun=$(node -p -e "require('./DEV-INF/configs.json').clearScreenBeforeRun")
    printHeaderToScreen=$(node -p -e "require('./DEV-INF/configs.json').printHeaderToScreen")

    if [ "$clearScreenBeforeRun" == "true" ]; then
        clear
    fi
    if [ "$printHeaderToScreen" == "true" ]; then
        $utils "printHeader"
    fi

    task=deploy
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
        $logger "logDebug" "activating default version"
        projectVersion=$(./gradlew -q printProjectVersion)

        if [ -z "$projectVersion" ]; then
            $logger "logError" "'project version' is required"
            $logger "logInfo" "${task} FAILED"
            exit 1
        fi
    fi
    $logger "logDebug" "validate dockerHub"
    if [ -z "$dockerHub" ]; then
        $logger "logError" "'docker hub URL' is required"
        $logger "logInfo" "${task} FAILED"
        exit 1
    fi
    $logger "logInfo" "validateArgs"

    $logger "logInfo" "dockerIt..."
    $logger "logDebug" "docker repository: https://www.docker.com/${dockerHub}"
    $logger "logDebug" "docker image: ${projectName}"
    $logger "logDebug" "docker tag: ${projectVersion}"
    $dockerit "login"
    $dockerit "build" "$dockerHub:$projectName-$projectVersion"
    $dockerit "push" "$dockerHub:$projectName-$projectVersion"
    $logger "logInfo" "dockerIt"

    $logger "logInfo" "---------------"
    $logger "logInfo" "${task} SUCCESS - https://hub.docker.com/repository/docker/${dockerHub}/tags?page=1&name=${projectName}-${projectVersion}"
    $logger "logInfo" "---------------"
    exit 0
}

main $1
