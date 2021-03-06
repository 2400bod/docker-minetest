FROM lsiobase/alpine
MAINTAINER 2400bod

# environment variables
ENV HOME="/config" \
MINETEST_SUBGAME_PATH="/config/.minetest/games

# build variables
ARG LDFLAGS="-lintl"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	bzip2-dev \
	cmake \
	curl-dev \
	doxygen \
	g++ \
	gcc \
	gettext-dev \
	git \
	gmp-dev \
	hiredis-dev \
	icu-dev \
	irrlicht-dev \
	libjpeg-turbo-dev \
	libpng-dev \
	libtool \
	luajit-dev \
	make \
	openal-soft-dev \
	openssl-dev \
	python-dev \
	sqlite-dev && \

apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb-dev && \

# install runtime packages
 apk add --no-cache \
	curl \
	gmp \
	hiredis \
	libgcc \
	libintl \
	libstdc++ \
	luajit \
	lua-socket \
	sqlite \
	sqlite-libs && \

apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb && \

# compile spatialindex
 git clone https://github.com/libspatialindex/libspatialindex /tmp/spatialindex && \
 cd /tmp/spatialindex && \
 cmake . \
	-DCMAKE_INSTALL_PREFIX=/usr && \
 make && \
 make install && \

# compile minetestserver
 git clone --depth 1 https://github.com/2400bod/minetest.git /tmp/minetest && \
 cp /tmp/minetest/minetest.conf.example /defaults/minetest.conf && \
 cd /tmp/minetest && \
 cmake . \
	-DBUILD_CLIENT=0 \
	-DBUILD_SERVER=1 \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCUSTOM_BINDIR=/usr/bin \
	-DCUSTOM_DOCDIR="/usr/share/doc/minetest" \
	-DCUSTOM_SHAREDIR="/usr/share/minetest" \
	-DENABLE_CURL=1 \
	-DENABLE_GETTEXT=1 \
	-DENABLE_LEVELDB=1 \
	-DENABLE_LUAJIT=1 \
	-DENABLE_REDIS=1 \
	-DENABLE_SOUND=0 \
	-DENABLE_SYSTEM_GMP=1 \
	-DRUN_IN_PLACE=0 && \
 make && \
 make install && \

# copy games to temporary folder
 mkdir -p /defaults/games && \
 cp -pr  /usr/share/minetest/games/* /defaults/games/ && \

# fetch additional game from git
 git clone --depth 1 https://github.com/2400bod/minetest_game.git /defaults/games/minetest && \

# cleanup
 apk del --purge build-dependencies && \
 rm -rf /tmp/*

# add local files
COPY root /

# ports and volumes
EXPOSE 30000/udp
VOLUME /config/.minetest
