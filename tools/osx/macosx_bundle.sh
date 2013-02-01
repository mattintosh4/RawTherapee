#!/bin/bash

if [ ! -d ${CMAKE_BUILD_TYPE} ]
then
    echo "${CMAKE_BUILD_TYPE} directory not found"
    exit
fi

echo "Project name: ${PROJECT_NAME}"
echo "Source directory: ${PROJECT_SOURCE_DIR}"
echo "Working directory: ${CMAKE_BINARY_DIR}"

APP=${PROJECT_NAME}.app
CONTENTS=${APP}/Contents
RESOURCES=${CONTENTS}/Resources
MACOS=${CONTENTS}/MacOS
ETC=${MACOS}/etc
LIB=${MACOS}/lib

if [ `which hg` -a -d ${PROJECT_SOURCE_DIR}/.hg ]
then
    PROJECT_VERSION=`hg -R "${PROJECT_SOURCE_DIR}" parents --template '{latesttag}.{latesttagdistance}'`
fi
DMG=rawtherapee_mac${PROC_BIT_DEPTH}_${PROJECT_VERSION}.dmg

echo "=> Removing old files"
rm -rf ${PROJECT_NAME}.app rawtherapee*.dmg 2>/dev/null

echo "=> Creating a container"
install -d ${CONTENTS}/{Resources,MacOS/{lib,etc,share/mime}}

echo "=> Installing bundle identifiers"
cp ${PROJECT_SOURCE_DIR}/tools/osx/Info.plist ${CONTENTS}
cp ${PROJECT_SOURCE_DIR}/tools/osx/Icons.icns ${RESOURCES}
cp ${PROJECT_SOURCE_DIR}/tools/osx/start ${MACOS}

echo "=> Updating Info.plist"
defaults write ${CMAKE_BINARY_DIR}/${CONTENTS}/Info CFBundleShortVersionString ${PROJECT_VERSION:0:3}
defaults write ${CMAKE_BINARY_DIR}/${CONTENTS}/Info CFBundleVersion ${PROJECT_VERSION}

echo "=> Installing core files"
cp -R ${CMAKE_BUILD_TYPE}/* ${MACOS}

echo "=> Installing modules"
cp -R ${GTK_PREFIX}/lib/{gdk-pixbuf-2.0,gtk-2.0,pango} ${LIB}
cp -R ${GTK_PREFIX}/etc/{gtk-2.0,pango} ${ETC}
cp -R ${GTK_PREFIX}/share/mime ${MACOS}/share

echo "=> Replacing modules config file"
sed -i "" -e "s|${GTK_PREFIX}|/tmp/${MACOS}|" ${ETC}/{pango/pango.modules,gtk-2.0/{gdk-pixbuf.loaders,gtk.immodules}}
printf '[Pango]\nModuleFiles = %s\n' /tmp/${ETC}/pango/pango.modules > ${ETC}/pango/pangorc

checkLink(){
    otool -L $1 \
    | awk 'NR >= 2 && $1 !~ /^(\/usr\/lib|\/System|@executable_path)\// { print $1 }' \
    | while read
    do
        if [ ! -f ${LIB}/${REPLY##*/} ]
        then
            cp -v ${REPLY} ${LIB}
            checkLink ${LIB}/${REPLY##*/}
        fi
    done
}
echo "=> Installing dependencies"
checkLink ${MACOS}/rawtherapee

echo "=> Creating distribution disk image ${DMG}"
hdiutil create -srcdir ${APP} ${DMG}
