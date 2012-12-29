#!/bin/bash
# Function checkLink:
# args: $1 - file
#
# Will loop through all dynamic links for $file, and update each to be relative.
function checkLink {
	#echo "checkLink called with $1 $2"
	local FILE=$1

	otool -L $FILE | grep -v "${APP}" | grep -v '/usr/lib' | grep -v '/System/' | grep -v "@executable_path" | cut -f 1 -d ' ' | while read X
	do 
		local NAME=${LIB}/`basename "$X"`
		if [ ! -f "${NAME}" ]
		then
			cp $X "${NAME}"
		
			#Recursively update the linkage of libraries
			checkLink "${NAME}"
		fi
	done
}

APP=RawTherapee.app
CONTENTS=${APP}/Contents
RESOURCES=${CONTENTS}/Resources
MACOS=${CONTENTS}/MacOS
BIN=${MACOS}/bin
ETC=${MACOS}/etc
LIB=${MACOS}/lib
SHARE=${MACOS}/share
RELEASE=Release
EXECUTABLE=rawtherapee
RT_VERSION=`awk '/^Version: / { print $2 }' ./Release/AboutThisBuild.txt`
BIT_DEPTH=`awk '/^Bit depth: / { print $3 }' ./Release/AboutThisBuild.txt`
DMG=rawtherapee_mac${BIT_DEPTH}_`date +%F`_`hg -R . branch`_`hg parents --template '{latesttag}i.{latesttagdistance}-{node|short}'`.dmg

#Find where MacPorts is installed.  We take a known binary (cmake), which is in <MacPorts>/bin, and 
# go up a level to get the main install folder.
MACPORTS_PREFIX=`otool -L $RELEASE/$EXECUTABLE | awk '/libgtk-.*dylib/ { print $1 }'`
MACPORTS_PREFIX=${MACPORTS_PREFIX%/lib/*}

#MACPORTS_PREFIX=`which port`
#MACPORTS_PREFIX=${MACPORTS_PREFIX%/bin/port}

if [ ! -d ${RELEASE} ]; then
	echo "Please run this from the root of the project; i.e. './tools/osx/make-app-bundle'."
	exit
fi

if [ -d "${APP}" ]; then
	echo "Removing old application..."
	rm -rf "${APP}"
fi
echo "Removing any old disk images..."
rm ${RELEASE}/rawtherapee*.dmg
rm ${RELEASE}/rawtherapee*.dmg.zip

echo "Making application directory structure..."
mkdir -p "${RESOURCES}"
mkdir -p "${ETC}"
mkdir -p "${LIB}"
mkdir -p "${SHARE}/mime"

#Copy over non-explicitly linked libraries
echo "Copying libraries from ${MACPORTS_PREFIX}..."
cp -R ${MACPORTS_PREFIX}/lib/pango ${LIB}
cp -R ${MACPORTS_PREFIX}/lib/gtk-2.0 ${LIB}
cp -R ${MACPORTS_PREFIX}/lib/gdk-pixbuf* ${LIB}

#Copy over mimes (if a mime is copied, and nobody hears, is it really copied?)
echo "Copying shared files from ${MACPORTS_PREFIX}..."
cp -R ${MACPORTS_PREFIX}/share/mime/* ${SHARE}/mime

#Copy over etc files, and modify as needed
echo "Copying configuration files from ${MACPORTS_PREFIX} and modifying for standalone app bundle..."
cp -R $MACPORTS_PREFIX/etc/gtk-2.0 ${ETC}
cp -R $MACPORTS_PREFIX/etc/pango ${ETC}

$MACPORTS_PREFIX/bin/gtk-query-immodules-2.0 \
$MACPORTS_PREFIX/lib/gtk-2.0/*/immodules/*.so | sed "s|$MACPORTS_PREFIX|@executable_path|" > $ETC/gtk-2.0/gtk.immodules
$MACPORTS_PREFIX/bin/gdk-pixbuf-query-loaders | sed "s|$MACPORTS_PREFIX|@executable_path|" > $ETC/gtk-2.0/gdk-pixbuf.loaders
$MACPORTS_PREFIX/bin/pango-querymodules | sed "s|$MACPORTS_PREFIX|/tmp/$MACOS|" > $ETC/pango/pango.modules
cat > $ETC/pango/pangorc <<__EOF__
[Pango]
ModuleFiles = /tmp/$ETC/pango/pango.modules
__EOF__
rm ${LIB}/gdk-pixbuf-2.0/2.10.0/loaders.cache

#Copy over the release files
echo "Copying release files..."
cp -R ${RELEASE}/* ${MACOS}

#Copy application-specific stuff like icons and startup script
echo "Creating required application bundle files..."
cp tools/osx/Icons.icns ${RESOURCES}
curl -o $MACOS/start "https://raw.github.com/mattintosh4/RawTherapee/master/tools/osx/start_sub.sh" && chmod +x $MACOS/start
cat > $CONTENTS/Info.plist <<__EOF__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleExecutable</key>
	<string>start</string>
	<key>CFBundleIconFile</key>
	<string>Icons.icns</string>
	<key>CFBundleIdentifier</key>
	<string>com.rawtherapee.rawtherapee</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>RawTherapee</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${RT_VERSION:0:3}</string>
	<key>CFBundleSignature</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>${RT_VERSION}</string>
</dict>
</plist>
__EOF__

#Copy and relink the explicitly defined libraries
echo "Recursively copying libraries referenced by executable..."
checkLink "${MACOS}/${EXECUTABLE}"


#Make a .dmg for distribution and delete the .app
echo "Creating distribution .dmg..."
hdiutil create -srcdir ${APP} ${RELEASE}/${DMG}
echo "Cleaning up..."
rm -rf ${APP}

cd ${RELEASE}
zip ${DMG}.zip ${DMG} AboutThisBuild.txt

echo "All done!"