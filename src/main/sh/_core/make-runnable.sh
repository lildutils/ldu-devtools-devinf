#!/bin/bash

## import core scripts

logger=${PWD}/DEV-INF/_logger.sh

## main

main() {
    $logger "logInfo" "make:runnable..."
    sudo chmod -R 755 ${PWD}/*.sh
    $logger "logInfo" "make:runnable"
}

## run

main
