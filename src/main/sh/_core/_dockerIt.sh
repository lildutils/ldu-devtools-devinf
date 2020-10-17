#!/bin/bash

## import core scripts

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    command=$1

    if [ "$command" == "login" ]; then
        _dockerLogin
        exit 0
    fi

    if [ "$command" == "build" ]; then
        _dockerBuild $2
        exit 0
    fi

    if [ "$command" == "push" ]; then
        _dockerPush $2
        exit 0
    fi

    exit 0
}

## tasks

_dockerLogin() {
    sudo docker login
}

_dockerBuild() {
    tagName=$1
    sudo docker build -t $tagName .
}

_dockerPush() {
    tagName=$1
    sudo docker push $tagName
}

## run

main "$1" "$2"
