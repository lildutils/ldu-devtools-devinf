#!/bin/bash

logger=${PWD}/DEV-INF/_logger.sh

main() {
    command=$1
    dockerImageWithTag=$2

    if [ "$command" == "login" ]; then
        _dockerLogin
    else
        if [ "$command" == "build" ]; then
            _dockerBuild $dockerImageWithTag
        else
            if [ "$command" == "push" ]; then
                _dockerPush $dockerImageWithTag
            else
                $logger "logError" "Unknown command called: ${PWD}/DEV-INF/_dockerit.sh ${command}"
                exit 1
            fi
        fi
    fi
    exit 0
}

_dockerLogin() {
    sudo docker login
}

_dockerBuild() {
    sudo docker build -t $1 .
}

_dockerPush() {
    sudo docker push $1
}

main $1 "$2"
