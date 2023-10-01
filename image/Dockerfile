FROM ghcr.io/void-linux/void-buildroot-glibc:20230904R2

RUN mkdir -p /etc/xbps.d && cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/ \
    && sed -i 's|repo-default|repo-ci|g' /etc/xbps.d/*-repository-*.conf \
    && xbps-install -Syu || xbps-install -yu xbps \
    && xbps-install -yu \
    && xbps-install -y \
        git \
        cmake \
        python3 \
        tar \
        util-linux \
        xtools \
        grep \
        curl

ENV XBPS_BUILD_ENVIRONMENT="void-packages-ci" \
    XBPS_ALLOW_RESTRICTED="yes" \
    XBPS_CHROOT_CMD="ethereal" \
    XBPS_ALLOW_CHROOT_BREAKOUT="yes"
