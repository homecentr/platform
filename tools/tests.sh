#!/usr/bin/env bash

ENV_NAME=$1

echo "Loading environment variables..."

set -a
source ./tests/environments/$ENV_NAME.env
set +a

if [ -z "${WEBDRIVER_HOST}" ]; then
    export WEBDRIVER_HOST="localhost"
fi

if [ -z "${WEBDRIVER_PORT}" ]; then
    export WEBDRIVER_PORT="4444"
fi

if [ "${SKIP_SELENIUM_CONTAINER}" != "1" ]; then
    echo "Starting webdriver container..."
    docker compose -f ./tests/client/docker-compose.yaml up --force-recreate --detach --remove-orphans

    echo "Waiting for the webdriver to be ready..."

    x=1
    READY=$(curl http://${WEBDRIVER_HOST}:${WEBDRIVER_PORT}/status 2>/dev/null | jq .value.ready)
    while [[ "${READY}" -ne "true" ]]
    do
        sleep 10
        x=$(( $x + 1 ))

        if [ $x -gt 10 ]
        then
            echo "The selenium container did not get ready in time, ending test run..."
            exit 255
        fi

        READY=$(curl http://${WEBDRIVER_HOST}:${WEBDRIVER_PORT}/status 2>/dev/null | jq .value.ready)
    done

    echo "Webdriver ready..."
fi

echo "Running nightwatch..."
TST_COMMAND="nightwatch ${@:2}"
eval $TST_COMMAND
