#!/bin/bash

REPOSITORY_DIR="/workspace/${1}"
USER_NAME="${2}"
USER_EMAIL="${3}"

PRIVATE_KEY="/workspace/private.pem"

xbps-rindex -a ${REPOSITORY_DIR}/*.xbps
xbps-rindex --sign \
    --signedby "${USER_NAME} <${USER_EMAIL}>" \
    --privkey ${PRIVATE_KEY} \
    ${REPOSITORY_DIR}

for pkg in $(ls -d -1 ${REPOSITORY_DIR}/*.xbps); do
    xbps-rindex --privkey ${PRIVATE_KEY} --sign-pkg ${pkg}
done
