#!/bin/bash

set -e

if [[ "${TRAVIS_BRANCH}" != "${DOCKERHUB_BUILD_BRANCH}" ]]
then
    echo "branch [${TRAVIS_BRANCH}] not [${DOCKERHUB_BUILD_BRANCH}]"
    exit 0
fi

REPO_URL="https://github.com/wangyu-/UDPspeeder.git"
REPO_NAME="udpspeeder"
REPO_VERSION_FILE_DIR=".."
REPO_VERSION_FILE="${REPO_NAME}.gitversion"

REPO_ROOT="${HOME}/repo"
REPO_VERSION_FILE_PATH="${REPO_ROOT}/${REPO_NAME}/${REPO_VERSION_FILE_DIR}/${REPO_VERSION_FILE}"

VERSION_ROOT="${HOME}/cache/version"
VERSION_DIR="${VERSION_ROOT}/${REPO_NAME}"
VERSION_FILE_PATH="${VERSION_DIR}/${REPO_VERSION_FILE}"

echo "REPO_ROOT=${REPO_ROOT}"
echo "VERSION_DIR=${VERSION_DIR}"

mkdir -p ${REPO_ROOT}
mkdir -p ${VERSION_DIR}

[[ -f ${VERSION_FILE_PATH}.new ]] || touch ${VERSION_FILE_PATH}.new
rm -f ${VERSION_FILE_PATH}
mv ${VERSION_FILE_PATH}.new ${VERSION_FILE_PATH}

rm -rf ${REPO_ROOT}/${REPO_NAME}
git clone --depth=10 ${REPO_URL} ${REPO_ROOT}/${REPO_NAME}
pushd ${REPO_ROOT}/${REPO_NAME}
git rev-parse HEAD > ${REPO_ROOT}/${REPO_NAME}.gitversion
popd
cp ${REPO_VERSION_FILE_PATH} ${VERSION_FILE_PATH}.new

rm -rf ${REPO_ROOT}

echo "new version file:"
echo "------------------------------------"
head -n 10 ${VERSION_FILE_PATH}.new
echo "------------------------------------"
echo
echo "old version file:"
echo "------------------------------------"
head -n 10 ${VERSION_FILE_PATH}
echo "------------------------------------"
echo

set +e

diff ${VERSION_FILE_PATH}.new ${VERSION_FILE_PATH} >/dev/null
[[ $? == 0 ]] && echo "same version" && exit 0

set -e

curl --request POST \
    --header "Content-Type: application/json" \
    --data '{"source_type": "Branch", "source_name": "${DOCKERHUB_BUILD_BRANCH}"}' \
    ${DOCKERHUB_BUILD_TRIGGER}
