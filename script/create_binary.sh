#!/bin/sh

export CMAKE_SOURCE_DIR="/usr/local/src/rawtherapee"
export CMAKE_BUILD_DIR="/usr/local/src/build_rawtherapee"

mkdir -p ${CMAKE_BUILD_DIR} && cd ${CMAKE_BUILD_DIR} && rm -rf *

# ARCHITECTURE SETTING
if [ ! "${ARCH}" ]; then
#	DEFAULT
	export ARCH="x86_64"
#	SYSTEM DEFAULT
#	export ARCH=`uname -m`
else
# 	CUSTOM
	export ARCH="${ARCH}"
fi

echo "BUILD_ARCHITECTURE: ${ARCH}"

test -x "$HOME/GitHub/RawTherapee/script/compile_commands" && $_ && make install -j3
