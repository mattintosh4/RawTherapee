#!/bin/bash

cd /usr/local/src/rawtherapee
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/start.patch
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/make-app-bundle.patch
curl -O https://raw.github.com/mattintosh4/RawTherapee/master/patch/info.plist.patch
patch -ubN -p0 < start.patch
patch -ubN -p0 < make-app-bundle.patch
patch -ubN -p0 < info.plist.patch
rm -rf ./build ./Release
mkdir build
cd build
CC="ccache gcc-mp-4.7" \
CXX="ccache g++-mp-4.7" \
cmake \
-DBUILD_BUNDLE:BOOL="ON" \
-DCMAKE_BUILD_TYPE="Release" \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET="10.6" \
-DCMAKE_OSX_SYSROOT="/Developer/SDKs/MacOSX10.6.sdk" \
-DPROC_TARGET_NUMBER="1" ..
make install
cd - > /dev/null
mv ./build/Release ./
cp -r /opt/local/share/locale ./Release/share/locale
sed -i "" -e "s/ccache/gcc-mp-4/g" ./Release/AboutThisBuild.txt
cat <<EOF >> ./Release/AboutThisBuild.txt

***** Unofficial Bundle for MacOS *****

Bundle created by mattintosh4
https://github.com/mattintosh4/RawTherapee

Thanks to all developers.
EOF
./tools/osx/make-app-bundle
