#!/bin/sh

cd /usr/local/src/rawtherapee
patch -ubN -p0 < ~/GitHub/RawTherapee/patch/start.patch
patch -ubN -p0 < ~/GitHub/RawTherapee/patch/make-app-bundle.patch
patch -ubN -p0 < ~/GitHub/RawTherapee/patch/info.plist.patch
patch -ubN -p0 < ~/GitHub/RawTherapee/patch/config.h.in.patch
rm -rf ./build ./Release
mkdir build && cd $_
test -x ~/GitHub/RawTherapee/compile_commands.sh && $_ && /opt/local/bin/gmake install -j3
cd - > /dev/null && mv ./build/Release . && sed -i "" \
-e "4s/ccache/gcc-mp-4/" \
-e "9s/$/ (Development)/" ./Release/AboutThisBuild.txt
cat <<EOF >> ./Release/AboutThisBuild.txt

***** Unofficial Bundle for MacOS *****

Bundle created by mattintosh4
https://github.com/mattintosh4/RawTherapee

Thanks to all developers.
EOF
./tools/osx/make-app-bundle
