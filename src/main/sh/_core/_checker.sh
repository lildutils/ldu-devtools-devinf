#!/bin/bash

## imports

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    command=$1

    if [ "$command" == "checkAngularCliInstalled" ]; then
        _checkAngularCliInstalled
        exit 0
    fi

    if [ "$command" == "checkConfigsJsonExists" ]; then
        _checkFileExists "${PWD}/DEV-INF/configs.json"
        exit 0
    fi

    if [ "$command" == "checkPackageJsonExists" ]; then
        _checkFileExists "${PWD}/package.json"
        exit 0
    fi

    if [ "$command" == "checkDockerfileExists" ]; then
        _checkFileExists "${PWD}/Dockerfile"
        exit 0
    fi

    if [ "$command" == "checkDockerInstalled" ]; then
        _checkDockerInstalled
        exit 0
    fi

    if [ "$command" == "checkGradlewInstalled" ]; then
        _checkGradlewInstalled
        exit 0
    fi

    if [ "$command" == "checkJavaInstalled" ]; then
        _checkJavaInstalled
        exit 0
    fi

    if [ "$command" == "checkNodeInstalled" ]; then
        _checkNodeInstalled
        exit 0
    fi

    if [ "$command" == "checkNpmInstalled" ]; then
        _checkNpmInstalled
        exit 0
    fi

    if [ "$command" == "checkOpenSSHInstalled" ]; then
        _checkOpenSSHInstalled
        exit 0
    fi

    if [ "$command" == "checkZipInstalled" ]; then
        _checkZipInstalled
        exit 0
    fi

    exit 0
}

## tasks

_checkAngularCliInstalled() {
    ngVersion=$(./node_modules/.bin/ng v)

    if [ -z "$ngVersion" ]; then
        $logger "logError" "'ng' is not installed yet, please install it first"
        exit 1
    fi
}

_checkDockerInstalled() {
    dockerVersion=$(docker --version)

    if [ -z "$dockerVersion" ]; then
        $logger "logError" "'docker' is not installed yet, please install it first"
        exit 1
    fi
}

_checkFileExists() {
    file=$1

    if [ ! -f "$file" ]; then
        $logger "logError" "'${file}' is not exists"
        exit 1
    fi
}

_checkGradlewInstalled() {
    gradlewVersion=$(${PWD}/gradlew -v)

    if [ -z "$gradlewVersion" ]; then
        $logger "logError" "'${PWD}/gradlew' is not installed yet, please install it first"
        exit 1
    fi
}

_checkJavaInstalled() {
    javaVersion=$(java --version)

    if [ -z "$javaVersion" ]; then
        $logger "logError" "'java' is not installed yet, please install it first"
        exit 1
    fi
}

_checkNodeInstalled() {
    nodeVersion=$(node -v)

    if [ -z "$nodeVersion" ]; then
        $logger "logError" "'node' is not installed yet, please install it first"
        exit 1
    fi
}

_checkNpmInstalled() {
    npmVersion=$(npm -v)

    if [ -z "$npmVersion" ]; then
        $logger "logError" "'npm' is not installed yet, please install it first"
        exit 1
    fi
}

_checkOpenSSHInstalled() {
    sshVersion=$(ssh)

    if [ -z "$npmVersion" ]; then
        $logger "logError" "'ssh' is not installed yet, please install it first"
        exit 1
    fi
}

_checkZipInstalled() {
    zipVersion=$(zip -h2)

    if [ -z "$zipVersion" ]; then
        $logger "logError" "'zip' is not installed yet, please install it first"
        exit 1
    fi
}

## run

main "$1"
