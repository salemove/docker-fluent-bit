FROM gcr.io/google-containers/debian-base-amd64:0.1

# Fluent Bit version
ENV FLB_MAJOR 0
ENV FLB_MINOR 12
ENV FLB_PATCH 0
ENV FLB_VERSION 0.12.0

ENV FLB_GIT_REV 2b2b0fd2b9b54344762691688290f17780b0cb49

RUN mkdir -p /fluent-bit/bin /fluent-bit/etc

RUN apt-get -qq update \
    && apt-get install -y -qq --no-install-recommends \
       ca-certificates \
       build-essential \
       cmake \
       make \
       sudo \
       wget \
       unzip \
       libsystemd-dev \ 
       zlib1g-dev \
       pkg-config \
    && apt-get install -y -qq --reinstall lsb-base lsb-release \
    && cd /tmp \
    && wget -q http://github.com/fluent/fluent-bit/archive/${FLB_GIT_REV}.zip \
    && unzip ${FLB_GIT_REV}.zip \
    && cd fluent-bit-${FLB_GIT_REV}/build/ \
    && cmake -DFLB_DEBUG=On -DFLB_TRACE=On -DFLB_JEMALLOC=On -DFLB_BUFFERING=On ../ \
    && make \
    && install bin/fluent-bit /fluent-bit/bin/ \
    && apt-get remove --purge --auto-remove -y -qq \
       build-essential \
       cmake \
       make \
       wget \
       unzip \
       zlib1g-dev \
       libsystemd-dev \
       pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configuration files
COPY fluent-bit.conf /fluent-bit/etc/
COPY parsers.conf /fluent-bit/etc/
COPY parsers_java.conf /fluent-bit/etc/

# Entry point
CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
