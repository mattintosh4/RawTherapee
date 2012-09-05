#!/bin/sh

cd /usr/local/src/rawtherapee
rm -rf ./build ./Release
mkdir build && cd $_
[ -x ~/GitHub/RawTherapee/compile_commands.sh ] && $_ && /opt/local/bin/gmake install -j3
cd - > /dev/null && mv ./build/Release . && sed -i "" \
-e "4s/ccache/gcc-mp-4/" \
-e "9s/$/ (Development)/" ./Release/AboutThisBuild.txt
cat <<EOF >> ./Release/AboutThisBuild.txt

***** Unofficial Bundle for MacOS *****

Bundle created by mattintosh4
https://github.com/mattintosh4/RawTherapee

Thanks to all developers.
EOF
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/start.patch
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/make-app-bundle.patch
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/info.plist.patch
patch -ubN -p0 < start.patch
patch -ubN -p0 < make-app-bundle.patch
patch -ubN -p0 < info.plist.patch
./tools/osx/make-app-bundle
