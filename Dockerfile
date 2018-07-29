FROM jfloff/alpine-python:2.7-slim
MAINTAINER Julien BIJOUX <julien@vidomia.biz>
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.11.3
# --no-cache: download package index on-the-fly, no need to cleanup afterwards
# --virtual: bundle packages, remove whole bundle at once, when done
### CIRCLECI DEPS
RUN \
  apk --no-cache add \
    ca-certificates \
    curl \
    python  \
    git \
    openssh-client \
    openssl \
    parallel \
    libc6-compat \
    libstdc++ \
    openssh
### Everything needed for building GRPC dependencies
### and clean node 9.0.0 version  
### https://raw.githubusercontent.com/daveamit/node-apline-grpc/master/Dockerfile
RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make  \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION"

### DEPLOYMENT & BUILD TOOLS
RUN apk add --no-cache python-dev \
    && pip install python-keystoneclient \
    && pip install python-swiftclient \
    && touch ~/.profile \
    && npm install --global yarn  \
    && apk del .build-deps  \
    && apk del python-dev 