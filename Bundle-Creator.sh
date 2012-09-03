#!/bin/sh

cd /usr/local/src/rawtherapee
rm -rf ./build ./Release
mkdir build && cd $_
export FLAGS="-isysroot /Developer/SDKs/MacOSX10.6.sdk -mmacosx-version-min=10.6 -arch x86_64 -lm -I/Library/Frameworks -I/System/Library/Frameworks -I/opt/local/include/gcc47/c++ -I/opt/local/include/gcc47/c++/backward -I/opt/local/include/gcc47/c++/x86_64-apple-darwin10 -I/opt/local/lib/gcc47/gcc/x86_64-apple-darwin10/4.7.1/include -I/opt/local/lib/gcc47/gcc/x86_64-apple-darwin10/4.7.1/include-fixed"
cmake \
-DBUILD_BUNDLE="ON" \
-DCMAKE_BUILD_TYPE="Release" \
-DCMAKE_CXX_COMPILER="/opt/local/bin/ccache" \
-DCMAKE_CXX_COMPILER_ARG1="/opt/local/bin/g++-mp-4.7 ${FLAGS}" \
-DCMAKE_C_COMPILER="/opt/local/bin/ccache" \
-DCMAKE_C_COMPILER_ARG1="/opt/local/bin/gcc-mp-4.7 ${FLAGS}" \
-DCMAKE_EXPORT_COMPILE_COMMANDS="ON" \
-DOPTION_OMP="ON" \
-DPROC_TARGET_NUMBER="1" \
-DRTENGINE_CXX_FLAGS="-ffast-math -funroll-loops -fomit-frame-pointer" .. && /opt/local/bin/gmake install -j3
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
