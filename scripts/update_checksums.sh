#!/bin/bash

PACKAGE_NAME="${1}"
PACKAGE_VERSION="${2}"

# Update checksums of binaries
curl -fsSL --output /tmp/changelog.md "https://github.com/thetredev/${PACKAGE_NAME}/releases/download/${PACKAGE_VERSION}/changelog.md"

lines=$(cat /tmp/changelog.md | grep "  ${PACKAGE_NAME}-linux-" | sed 's/  */ /g' | tr ' ' ';')

for line in ${lines}; do
    checksum=$(echo ${line} | cut -d ';' -f 1)
    binary=$(echo ${line} | cut -d ';' -f 2)
    arch=$(echo ${binary} | rev | cut -d '-' -f 1 | rev)

    echo "${checksum}" > packages/${PACKAGE_NAME}/checksums/${arch}.txt
done

rm -rf /tmp/changelog.md

# Update checksum of LICENSE file
curl -fsSL --output /tmp/LICENSE "https://raw.githubusercontent.com/thetredev/${PACKAGE_NAME}/${PACKAGE_VERSION}/LICENSE"
echo $(sha256sum /tmp/LICENSE | cut -d ' ' -f 1) > packages/${PACKAGE_NAME}/checksums/license.txt
rm -rf /tmp/LICENSE
