#
# Dockerfile for udpspeeder
#

FROM alpine AS builder

RUN set -ex \
 # Build environment setup
 && apk update \
 && apk upgrade \
 && apk add --no-cache --virtual .build-deps \
      linux-headers \
      git \
      gcc \
      g++ \
      make \
 # Build & install
 && mkdir -p /tmp/repo \
 && cd /tmp/repo \
 && git clone https://github.com/wangyu-/UDPspeeder.git \
 && cd UDPspeeder \
 && make \
 && install speederv2 /usr/local/bin \
 && speederv2 --help

# ------------------------------------------------

FROM alpine

COPY --from=builder /usr/local/bin/speederv2 /usr/local/bin/speederv2

RUN set -ex \
 # Build environment setup
 && speederv2 --help

USER nobody

ENTRYPOINT [ "speederv2" ]
