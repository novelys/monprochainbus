FROM ruby:2.3.3
MAINTAINER leo@scalingo.com

ENV NODE_VERSION 6.9.2

RUN cd /opt && \
    curl -L "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" | tar -xJf - && \
    mv -v node-v$NODE_VERSION-linux-x64 node

WORKDIR /usr/src/app

ENTRYPOINT ["/usr/src/app/bin/docker-entrypoint.sh"]
