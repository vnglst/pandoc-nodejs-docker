FROM haskell:7.10.3

MAINTAINER Koen van Gilst <koen@koenvangilst.nl>

# Updating this env variable will trigger automatic build
ENV PANDOC_VERSION "1.16.0.2"
ENV NPM_CONFIG_LOGLEVEL info
ENV NODEJS_VERSION 7.0.0

# install pandoc
RUN cabal update \
  && cabal install pandoc-${PANDOC_VERSION}

# update /etc/apt/sources.list to stretch distribution
RUN echo "deb http://ftp.us.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://ftp.us.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list

# Add package repo for Yarn
RUN apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# install latex packages
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends --fix-missing \
    texlive-full \
    fontconfig \
    curl \
    yarn \
  && apt-get clean -y  

# Install Node
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" \
  ; done

RUN curl -SLO "https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODEJS_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODEJS_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODEJS_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODEJS_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

# Add fonts to system
ADD ./fonts /usr/share/fonts/opentype/
RUN fc-cache -f -v

CMD [ "node" ]
