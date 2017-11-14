FROM ubuntu:latest

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 1080
ENV DEBUG_PORT 1081
ENV USER user
ENV PASSWORD password
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.9.1

ENV DEPENDENCIES gettext build-essential autoconf libtool libssl-dev libpcre3-dev \
                 asciidoc xmlto zlib1g-dev libev-dev libudns-dev libsodium-dev \
                 ca-certificates automake libmbedtls-dev

# Set up building environment
RUN apt-get update \
 && apt-get install --no-install-recommends -y $DEPENDENCIES

# necessary dependencies
RUN apt-get install --no-install-recommends -y curl wget git-core python

# get c9-sdk
RUN git clone git://github.com/c9/core.git /c9sdk
WORKDIR /c9sdk
RUN scripts/install-sdk.sh

# install nodejs-lts version
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
# 

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

RUN apt-get --purge autoremove -y $DEPENDENCIES

EXPOSE $SERVER_PORT/tcp $SERVER_PORT/udp $DEBUG_PORT/tcp $DEBUG_PORT/udp

CMD ${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/node /c9sdk/server.js --port $SERVER_PORT \
         --listen $SERVER_ADDR \
         -a $USER:$PASSWORD \
         -w /root/workspace/
