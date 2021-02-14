#!/usr/bin/env bash

##
# Compile ffmpeg with selected modules
#
# Version MacOS
# - build static & dynamic
#
# Versions:
# - NASM 2.14.02
# - Yasm 1.3.0
#
# Modules :
# - libfdk_aac (Fraunhofer FDK AAC)
# - libx264
# - libx265
# - libndi_newtek
##

SRC_PATH=$HOME/Documents/Work/ffmpeg/ffmpeg_sources
BUILD_PATH=$HOME/Documents/Work/ffmpeg/ffmpeg_build
BIN_PATH=$HOME/bin
FFMPEG_ENABLE="--enable-gpl --enable-nonfree"

[ ! -d "$SRC_PATH" ] && mkdir -pv "$SRC_PATH"
[ ! -d "$BUILD_PATH" ] && mkdir -pv "$BUILD_PATH"
[ ! -d "$BIN_PATH" ] && mkdir -pv "$BIN_PATH"

##
# libSDL2 necessary to compile ffplay
##
installLibSDL2() {
  echo "* installLibSDL2"
  cd "$SRC_PATH" || return
  if [ ! -d "SDL2-2.0.9" ]; then
    curl -O -L http://www.libsdl.org/release/SDL2-2.0.9.tar.gz && \
    tar fvxz SDL2-2.0.9.tar.gz && \
    rm tar fvxz SDL2-2.0.9.tar.gz
  fi
  cd SDL2-2.0.9 && \
  PATH="$BIN_PATH:$PATH" ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" --enable-static && \
  make && \
  make install
}

##
# enable ffplay
##
enableFfplay() {
  installLibSDL2
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --enable-ffplay"
}

##
# disable ffplay
##
disableFfplay() {
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --disable-ffplay"
}

##
# NASM : que pour liblame ??
##
installNASM() {
  cd "$SRC_PATH" || return
  if [ ! -d "nasm-2.14.02" ]; then
    echo "* téléchargement NASM"
    curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2
    tar xjvf nasm-2.14.02.tar.bz2
  fi
  cd nasm-2.14.02 || return
  echo "* compilation NASM"
  ./autogen.sh
  ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" && \
  make && \
  make install
}

##
# Yasm
##
installYasm() {
  cd "$SRC_PATH" || return
  if [ ! -d "yasm-1.3.0" ]; then
    curl -O -L http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
    tar xzvf yasm-1.3.0.tar.gz
  fi
  cd yasm-1.3.0 && \
  ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" && \
  make && \
  make install
}

##
# libx264
##
installLibX264() {
  cd "$SRC_PATH" || return
  if [ ! -d "x264" ]; then
    git clone --depth 1 https://code.videolan.org/videolan/x264.git
  fi
  cd x264 && \
  PATH="$BIN_PATH:$PATH" ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" --enable-static && \
  PATH="$BIN_PATH:$PATH" make && \
  make install
}

##
# enable libx264
##
enableLibX264() {
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --enable-libx264"
}

##
# libx265
##
installLibX265() {
  cd "$SRC_PATH" || return
  if [ ! -d "x265" ]; then
    brew install mercurial x265
    hg clone https://bitbucket.org/multicoreware/x265
  fi
  cd x265/build/linux && \
  PATH="$BIN_PATH:$PATH" ./configure --prefix="$BUILD_PATH" --bindir="$BIN_PATH" --enable-static && \
  PATH="$BIN_PATH:$PATH" make && \
  make install
}

##
# enable libx265
##
enableLibX265() {
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --enable-libx265"
}

##
# fdk_aac
##
installLibFdkAac() {
  cd "$SRC_PATH" || return
  if [ ! -d "fdk-aac" ]; then
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac
  fi
  brew install libtool
  cd fdk-aac && \
  autoreconf -fiv && \
  ./configure --prefix="$BUILD_PATH" --disable-shared && \
  make && \
  make install
}

##
# enable libFdkAAC
##
enableLibFdkAac() {
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --enable-libfdk_aac"
}

##
#
##
enableLibNDINewTek() {
  FFMPEG_ENABLE="${FFMPEG_ENABLE} --enable-libndi_newtek"
}

##
# ffmpeg
##
installFfmpeg() {
  cd "$SRC_PATH" || return
  if [ ! -d "ffmpeg-4.1.5" ]; then
    curl -O -L https://ffmpeg.org/releases/ffmpeg-4.1.5.tar.bz2 && \
    tar xjvf ffmpeg-4.1.5.tar.bz2
  fi
  cd ffmpeg-4.1.5 && \
  PATH="$BIN_PATH:$PATH" PKG_CONFIG_PATH="$BUILD_PATH/lib/pkgconfig" ./configure \
    --prefix="$BUILD_PATH" \
    --extra-cflags="-I$BUILD_PATH/include" \
    --extra-ldflags="-L$BUILD_PATH/lib" \
    --bindir="$BIN_PATH" \
    ${FFMPEG_ENABLE} && \
  PATH="$BIN_PATH:$PATH" make && \
  make install
}
#    --extra-cflags="-I$BUILD_PATH/include" \
#    --extra-ldflags="-L$BUILD_PATH/lib" \
#    --extra-cflags="-I$BUILD_PATH/include -I/Library/NDI\ SDK\ for\ Apple/include" \
#    --extra-ldflags="-L$BUILD_PATH/lib -L/Library/NDI\ SDK\ for\ Apple/lib/x64" \

if ! command -v "brew" > /dev/null; then
  echo "install homebrew !!"
  exit 1
fi

brew install automake pkg-config

#installNASM
#installYasm

installLibX264
installLibX265
installLibFdkAac

enableLibX264
enableLibX265
enableLibFdkAac
enableLibNDINewTek

#disableFfplay
enableFfplay

installFfmpeg
