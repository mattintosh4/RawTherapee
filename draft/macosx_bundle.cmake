# **************************************************************
# Create Mac OS X application bundle - macosx_bundle.cmake
# 
# Copyright (c) 2013 Makoto Yoshida
# 
# 
# Require variables
# -----------------
#   - PROJECT_NAME
#   - PROJECT_VERSION
#   - PROJECT_SOURCE_DIR
#   - CMAKE_BUILD_TYPE
#   - GTK_PREFIX
#   - GTK_LIBRARIES
#   - PROC_BIT_DEPTH
# 
# 
# Layout and variables
# --------------------
# 
# * = Imported variable
# 
#   source directory/                   PROJECT_SOURCE_DIR *
#       tools/
#           osx/
#               macosx_bundle.cmake (This file)
# 
#   GTK+ resources/                     GTK_PREFIX *
#       lib/
#       etc/
#       share/
# 
#   build directory/                    CMAKE_BINARY_DIR *
#       bundle resources/               CMAKE_BUILD_TYPE *
#       bundle.app/                     PROJECT_NAME.app *
#           Contents/                   BUNDLE_CONTENTS_DIR
#               Info.plist
#               MacOS/                  BUNDLE_MACOS_DIR
#                   start
#                   lib/                LIBDIR
#                   etc/                ETCDIR
#               Resources/              BUNDLE_RESOURCES_DIR
#                   Icons.icns
# 
# **************************************************************

set (BUNDLE_CONTENTS_DIR    "${PROJECT_NAME}.app/Contents")
set (BUNDLE_MACOS_DIR       "${BUNDLE_CONTENTS_DIR}/MacOS")
set (BUNDLE_RESOURCES_DIR   "${BUNDLE_CONTENTS_DIR}/Resources")
set (LIBDIR "${BUNDLE_MACOS_DIR}/lib")
set (ETCDIR "${BUNDLE_MACOS_DIR}/etc")
string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWERCASE)


file (GLOB oldfile . "${PROJECT_NAME}.app" "${PROJECT_NAME_LOWERCASE}*.dmg")
if (NOT oldfile STREQUAL "")
    message (STATUS "Removing old bundle and disk image")
    file (REMOVE_RECURSE ${oldfile})
endif ()


message (STATUS "Creating bundle container")
file (MAKE_DIRECTORY "${BUNDLE_RESOURCES_DIR}")
message (STATUS "Copying main files")
file (COPY "${CMAKE_BUILD_TYPE}" DESTINATION "${BUNDLE_CONTENTS_DIR}")
file (RENAME "${BUNDLE_CONTENTS_DIR}/${CMAKE_BUILD_TYPE}" "${BUNDLE_MACOS_DIR}")


# --------------------------------------
# Dependent libraries
# --------------------------------------
function (checkLink)
    execute_process(
        COMMAND otool -L "${ARGV0}"
        COMMAND awk "NR >= 2 && $1 !~ /^(\\/usr\\/lib|\\/System|@executable_path)\\// { print $1 }"
        OUTPUT_VARIABLE dependencies
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    ### Convert strings to list
    string (REPLACE "\n" ";" dependencies ${dependencies})
    foreach (x IN LISTS dependencies)
        get_filename_component (xname "${x}" NAME)
        if (NOT EXISTS "${LIBDIR}/${xname}")
            file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
            if (IS_SYMLINK "${x}")
                get_filename_component (x "${x}" REALPATH)
                file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
            endif ()
            checkLink ("${x}")
        endif ()
    endforeach ()
endfunction ()
message (STATUS "Copying dependent libraries")
checkLink ("${BUNDLE_MACOS_DIR}/rawtherapee")


# --------------------------------------
# Library modules
# --------------------------------------
message (STATUS "Copying library modules")
file (
    INSTALL     "${GTK_PREFIX}/lib/gtk-2.0"
                "${GTK_PREFIX}/lib/gdk-pixbuf-2.0"
                "${GTK_PREFIX}/lib/pango"
    DESTINATION "${LIBDIR}"
    USE_SOURCE_PERMISSIONS
    PATTERN "*.a" EXCLUDE
    PATTERN "*.la" EXCLUDE
    PATTERN "*.cache" EXCLUDE
)


# --------------------------------------
# Library module config files
# --------------------------------------
file (MAKE_DIRECTORY "${ETCDIR}/pango" "${ETCDIR}/gtk-2.0")
file (INSTALL "${GTK_PREFIX}/etc/gtk-2.0/im-multipress.conf" DESTINATION "${ETCDIR}/gtk-2.0" USE_SOURCE_PERMISSIONS)

function (registModules)
    
    # Arguments
    # ---------
    # ARGV0[0]: Path to registration utility
    # ARGV0[1]: Path to module files 
    # ARGV1   : Output path
    
    execute_process (
        COMMAND sh -c "${ARGV0}"
        COMMAND sed "s|${CMAKE_BINARY_DIR}|/tmp|"
        OUTPUT_FILE "${ARGV1}"
        RESULT_VARIABLE x
    )
    if (x EQUAL 0)
        message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${ARGV1}")
    endif (x EQUAL 0)
endfunction (registModules)

### gdk-pixbuf.loaders
registModules ("${GTK_PREFIX}/bin/gdk-pixbuf-query-loaders ${LIBDIR}/gdk-pixbuf-2.0/*/loaders/*.so"
               "${ETCDIR}/gtk-2.0/gdk-pixbuf.loaders")
### gtk.immodules
registModules ("${GTK_PREFIX}/bin/gtk-query-immodules-2.0 ${LIBDIR}/gtk-2.0/*/immodules/*.so"
               "${ETCDIR}/gtk-2.0/gtk.immodules")
### pango.modules
registModules ("${GTK_PREFIX}/bin/pango-querymodules ${LIBDIR}/pango/*/modules/*.so"
               "${ETCDIR}/pango/pango.modules")
### pangorc
message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${ETCDIR}/pango/pangorc")
file (WRITE "${ETCDIR}/pango/pangorc" "[Pango]\nModuleFiles = /tmp/${ETCDIR}/pango/pango.modules\n")


# --------------------------------------
# Mime data files
# --------------------------------------
message (STATUS "Copying mime data files")
file (INSTALL "${GTK_PREFIX}/share/mime" DESTINATION "${BUNDLE_MACOS_DIR}/share" USE_SOURCE_PERMISSIONS)


# --------------------------------------
# fontconfig files (X11 Backend only)
# --------------------------------------
if (GTK_LIBRARIES MATCHES "gtk-x11")
    message (STATUS "Copying fontconfig files")
    execute_process(
        ### All symbolic links are followed
        COMMAND cp -RL "${GTK_PREFIX}/etc/fonts" "${ETCDIR}"
        RESULT_VARIABLE x
    )
    if (x EQUAL 0)
        message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${ETCDIR}/fonts")
    endif (x EQUAL 0)
endif ()


message (STATUS "Copying other resources")
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/start" DESTINATION "${BUNDLE_MACOS_DIR}" USE_SOURCE_PERMISSIONS)
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/Icons.icns" DESTINATION "${BUNDLE_RESOURCES_DIR}" USE_SOURCE_PERMISSIONS)


# --------------------------------------
# Info.plist
# --------------------------------------
# Info.plist is generated by CMake.

message (STATUS "Creating Info.plist")

### If project source directory has .hg directory, this process will override the version number.
find_program (MERCURIAL hg)
if (NOT MERCURIAL STREQUAL MERCURIAL-NOTFOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.hg")
    execute_process (
        COMMAND ${MERCURIAL} -R "${PROJECT_SOURCE_DIR}" parents --template "{latesttag}.{latesttagdistance}"
        OUTPUT_VARIABLE PROJECT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif ()

### Variables for Info.plist
set (MACOSX_BUNDLE_COPYRIGHT            "Copyright © 2004-2013 Gábor Horváth")
set (MACOSX_BUNDLE_INFO_STRING          "${PROJECT_VERSION}, ${MACOSX_BUNDLE_COPYRIGHT}")
set (MACOSX_BUNDLE_BUNDLE_NAME          "${PROJECT_NAME}")
set (MACOSX_BUNDLE_GUI_IDENTIFIER       "com.${PROJECT_NAME_LOWERCASE}.${PROJECT_NAME_LOWERCASE}")
set (MACOSX_BUNDLE_EXECUTABLE_NAME      "start")
set (MACOSX_BUNDLE_ICON_FILE            "Icons.icns")
set (MACOSX_BUNDLE_BUNDLE_VERSION       "1.0")
set (MACOSX_BUNDLE_LONG_VERSION_STRING  "${PROJECT_VERSION}")
#set (MACOSX_BUNDLE_SHORT_VERSION_STRING "")
string (SUBSTRING "${PROJECT_VERSION}" 0 3 MACOSX_BUNDLE_SHORT_VERSION_STRING)
configure_file ("${CMAKE_ROOT}/Modules/MacOSXBundleInfo.plist.in" "${BUNDLE_CONTENTS_DIR}/Info.plist")


# --------------------------------------
# Exclude 32-bit
# --------------------------------------
if (PROC_BIT_DEPTH EQUAL 64)
    message (STATUS "Excluding 32-bit binary")
    file (GLOB_RECURSE object "${LIBDIR}/*.dylib" "${LIBDIR}/*.so")
    foreach (x IN LISTS object)
        execute_process (
            COMMAND lipo -info "${x}"
            OUTPUT_VARIABLE arch
        )
        if (arch MATCHES "i386")
            execute_process (
                COMMAND sh -v -c "lipo -thin x86_64 -output ${x} ${x}"
            )
        endif (arch MATCHES "i386")
    endforeach (x IN LISTS object)
endif (PROC_BIT_DEPTH EQUAL 64)


# --------------------------------------
# Disk image
# --------------------------------------
set (DMG_NAME           "${PROJECT_NAME_LOWERCASE}_mac${PROC_BIT_DEPTH}_${PROJECT_VERSION}.dmg")
set (DMG_SOURCE_DIR     "${PROJECT_NAME}${PROJECT_VERSION}") # Use as disk image volume name
set (DMG_SOURCE_FILES   "${PROJECT_NAME}.app")
list (APPEND DMG_SOURCE_FILES "AboutThisBuild.txt")
list (APPEND DMG_SOURCE_FILES "${PROJECT_SOURCE_DIR}/doc/RawTherapeeManual_en.pdf")

set (HDIUTIL_COMMAND hdiutil create)
list (APPEND HDIUTIL_COMMAND -format UDBZ) # bzip2-compressed (default: zlib-compressed)
list (APPEND HDIUTIL_COMMAND -srcdir "${DMG_SOURCE_DIR}")
list (APPEND HDIUTIL_COMMAND "${DMG_NAME}")

message (STATUS "Creating disk image, please wait")
file (COPY ${DMG_SOURCE_FILES} DESTINATION "${DMG_SOURCE_DIR}")
execute_process (COMMAND ln -s /Applications "${DMG_SOURCE_DIR}")
execute_process (COMMAND ${HDIUTIL_COMMAND})

message (STATUS "Cleaning disk image source")
file (REMOVE_RECURSE "${DMG_SOURCE_DIR}")
