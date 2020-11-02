#!/bin/bash

## imports

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    command=$1
    args=$2
    isSudoCall=$3

    if [ "$command" == "login" ]; then
        _dockerLogin "$args" "$isSudoCall"
        exit 0
    fi

    if [ "$command" == "build" ]; then
        _dockerBuild "$args" "$isSudoCall"
        exit 0
    fi

    if [ "$command" == "push" ]; then
        _dockerPush "$args" "$isSudoCall"
        exit 0
    fi

    exit 0
}

## tasks

_dockerLogin() {
    credentials=$1
    isSudo=$2
    if [ "$isSudo" == "true"]; then
        sudo docker login $credentials
    else
        docker login $credentials
    fi
}

_dockerBuild() {
    tagName=$1
    isSudo=$2
    if [ "$isSudo" == "true"]; then
        sudo docker build -t $tagName .
    else
        docker build -t $tagName .
    fi
}

_dockerPush() {
    tagName=$1
    isSudo=$2
    if [ "$isSudo" == "true"]; then
        sudo docker push $tagName
    else
        docker push $tagName
    fi
}

## run

main "$1" "$2" "$3"
