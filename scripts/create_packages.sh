#!/bin/bash

REPOSITORY_ARCH="${1}"

git config --global --add safe.directory /workspace/void-packages

cd /workspace/void-packages
ln -s / masterdir

for xbps_pkg in $(ls -1 /workspace/packages); do
    xbps_pkg_checksum=$(cat /workspace/packages/${xbps_pkg}/checksums/${REPOSITORY_ARCH}.txt)

    sed -i "s/%XDEB_INSTALL_BINARY_ARCH%/${REPOSITORY_ARCH}/" srcpkgs/${xbps_pkg}/template
    sed -i "s/%XDEB_INSTALL_BINARY_SHA256%/${xbps_pkg_checksum}/" srcpkgs/${xbps_pkg}/template

    xlint ${xbps_pkg} || exit 1
    ./xbps-src pkg -Q ${xbps_pkg} || exit 1
done
