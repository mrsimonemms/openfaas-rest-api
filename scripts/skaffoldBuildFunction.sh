#!/usr/bin/env bash

set -uo pipefail;

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
FUNCTION_NAME="${1}"

rm -Rf ./build
faas build -f "${SCRIPT_DIR}/../functions.yaml" --shrinkwrap
docker build -t "${IMAGE}" "./build/${FUNCTION_NAME}"

if "${PUSH_IMAGE}"; then
  echo "Pushing ${IMAGE}"
  docker push "${IMAGE}"
else
  echo "Not pushing ${IMAGE}"
fi
