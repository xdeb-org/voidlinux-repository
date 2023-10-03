#!/bin/bash

PACKAGE_NAME="${1}"
PACKAGE_VERSION="${2}"

curl -fsSL --output /tmp/checksums.md "https://github.com/thetredev/${PACKAGE_NAME}/releases/download/${PACKAGE_VERSION}/checksums.md"

lines=$(cat /tmp/checksums.md | grep "${PACKAGE_NAME}" | sed 's/  */ /g' | tr ' ' ';')

for line in ${lines}; do
    checksum=$(echo ${line} | cut -d ';' -f 1)
    binary=$(echo ${line} | cut -d ';' -f 2)
    arch=$(echo ${binary} | rev | cut -d '-' -f 1 | rev)

    echo "${checksum}" > packages/${PACKAGE_NAME}/checksums/${arch}.txt
done

rm -rf /tmp/checksums.md
