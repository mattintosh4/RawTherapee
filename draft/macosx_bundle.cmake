# **************************************************************
# Create Mac OS X application bundle - macosx_bundle.cmake
# 
# Copyright (c) 2013 Makoto Yoshida <mattintosh4@gmail.com>
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
#   source directory/                     PROJECT_SOURCE_DIR *
#     tools/
#       osx/
#         macosx_bundle.cmake (This file)
# 
#   GTK+ resources/                       GTK_PREFIX *
#     lib/
#     etc/
#     share/
# 
#   build directory/                      CMAKE_BINARY_DIR *
#     bundle resources/                   CMAKE_BUILD_TYPE *
#     bundle.app/                         PROJECT_NAME.app *
#       Contents/                         BUNDLE_CONTENTS_DIR
#         Info.plist
#         MacOS/                          BUNDLE_MACOS_DIR
#           start
#           lib/                          LIBDIR
#           etc/                          ETCDIR
#         Resources/                      BUNDLE_RESOURCES_DIR
#           Icons.icns
# 
# **************************************************************

set (BUNDLE_CONTENTS_DIR  "${PROJECT_NAME}.app/Contents")
set (BUNDLE_MACOS_DIR     "${BUNDLE_CONTENTS_DIR}/MacOS")
set (BUNDLE_RESOURCES_DIR "${BUNDLE_CONTENTS_DIR}/Resources")
set (LIBDIR     "${BUNDLE_MACOS_DIR}/lib")
set (ETCDIR     "${BUNDLE_MACOS_DIR}/etc")
set (executable "${BUNDLE_MACOS_DIR}/rawtherapee")
string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWERCASE)


function (get_dependencies file)
  execute_process(
    COMMAND otool -L "${file}"
    COMMAND awk "NR >= 2 && $1 !~ /^(\\/usr\\/lib|\\/System|@executable_path|@rpath)\\// { print $1 }"
    OUTPUT_VARIABLE x
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (x)
    string (REPLACE "\n" ";" x ${x})   # Convert strings to list
    set (dependencies ${x} PARENT_SCOPE) # Export list variable to parent scope
  endif ()
endfunction ()


## Remove old files
file (GLOB oldfile . "${PROJECT_NAME}.app" "${PROJECT_NAME_LOWERCASE}*.dmg")
if (NOT oldfile STREQUAL "")
  message (STATUS "Removing old bundle and disk image")
  file (REMOVE_RECURSE ${oldfile})
endif ()

## Pre-build
message (STATUS "Creating bundle container")
file (MAKE_DIRECTORY "${BUNDLE_RESOURCES_DIR}")
message (STATUS "Copying main files")
file (COPY "${CMAKE_BUILD_TYPE}" DESTINATION "${BUNDLE_CONTENTS_DIR}")
# Rename CMAKE_BUILD_TYPE to MacOS
file (RENAME "${BUNDLE_CONTENTS_DIR}/${CMAKE_BUILD_TYPE}" "${BUNDLE_MACOS_DIR}")


# --------------------------------------
# Dependent libraries
# --------------------------------------
function (checklink file)
  get_dependencies ("${file}")
  foreach (x IN LISTS dependencies)
    get_filename_component (xname "${x}" NAME)
    if (NOT EXISTS "${LIBDIR}/${xname}")
      file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
      if (IS_SYMLINK "${x}")
        get_filename_component (x "${x}" REALPATH)
        file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
      endif ()
      checklink ("${x}")
    endif ()
  endforeach ()
endfunction ()

message (STATUS "Copying dependent libraries")
checklink ("${executable}")



# --------------------------------------
# Library modules
# --------------------------------------
message (STATUS "Copying library modules")
file (INSTALL     "${GTK_PREFIX}/lib/gtk-2.0"
                  "${GTK_PREFIX}/lib/gdk-pixbuf-2.0"
                  "${GTK_PREFIX}/lib/pango"
      DESTINATION "${LIBDIR}"
      USE_SOURCE_PERMISSIONS
      PATTERN "*.a" EXCLUDE
      PATTERN "*.la" EXCLUDE
      PATTERN "*.cache" EXCLUDE)


# --------------------------------------
# Library module config files
# --------------------------------------
file (MAKE_DIRECTORY  "${ETCDIR}/pango"
                      "${ETCDIR}/gtk-2.0")
file (INSTALL     "${GTK_PREFIX}/etc/gtk-2.0/im-multipress.conf"
      DESTINATION "${ETCDIR}/gtk-2.0"
      USE_SOURCE_PERMISSIONS)

function (regist_modules command output)
  execute_process (
    COMMAND sh -c "${command}"
    COMMAND sed "s|${CMAKE_BINARY_DIR}|/tmp|"
    OUTPUT_FILE "${output}"
    RESULT_VARIABLE res)
  if (res EQUAL 0)
    message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${output}")
  else ()
    message (WARNING "Failed to create ${CMAKE_BINARY_DIR}/${output}")
  endif ()
endfunction (regist_modules)

## Regist utility
# usage: [regist utility] [module files]

# gdk-pixbuf.loaders
regist_modules("${GTK_PREFIX}/bin/gdk-pixbuf-query-loaders ${LIBDIR}/gdk-pixbuf-2.0/*/loaders/*.so"
               "${ETCDIR}/gtk-2.0/gdk-pixbuf.loaders")
# gtk.immodules
regist_modules("${GTK_PREFIX}/bin/gtk-query-immodules-2.0 ${LIBDIR}/gtk-2.0/*/immodules/*.so"
               "${ETCDIR}/gtk-2.0/gtk.immodules")
# pango.modules
regist_modules("${GTK_PREFIX}/bin/pango-querymodules ${LIBDIR}/pango/*/modules/*.so"
               "${ETCDIR}/pango/pango.modules")
# pangorc
message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${ETCDIR}/pango/pangorc")
file (WRITE "${ETCDIR}/pango/pangorc" "[Pango]\nModuleFiles = /tmp/${ETCDIR}/pango/pango.modules\n")


# --------------------------------------
# Mime data files
# --------------------------------------
message (STATUS "Copying mime data files")
file (INSTALL     "${GTK_PREFIX}/share/mime"
      DESTINATION "${BUNDLE_MACOS_DIR}/share"
      USE_SOURCE_PERMISSIONS)


# --------------------------------------
# fontconfig files (X11 Backend only)
# --------------------------------------
if (GTK_LIBRARIES MATCHES "gtk-x11")
  message (STATUS "Copying fontconfig files")
  execute_process(
    COMMAND cp -RL "${GTK_PREFIX}/etc/fonts" "${ETCDIR}" # All symbolic links are followed
    RESULT_VARIABLE x)
  if (x EQUAL 0)
    message (STATUS "Installing: ${CMAKE_BINARY_DIR}/${ETCDIR}/fonts")
  else ()
    message (WARNING "fontconfig directory is not found. If you know the place then copy it to ${ETCDIR}/fonts manually.")
  endif (x EQUAL 0)
endif ()



# --------------------------------------
# Other resources
# --------------------------------------
message (STATUS "Copying other resources")
file (INSTALL     "${PROJECT_SOURCE_DIR}/tools/osx/start"
      DESTINATION "${BUNDLE_MACOS_DIR}"
      USE_SOURCE_PERMISSIONS)
file (INSTALL     "${PROJECT_SOURCE_DIR}/tools/osx/Icons.icns"
      DESTINATION "${BUNDLE_RESOURCES_DIR}"
      USE_SOURCE_PERMISSIONS)



# --------------------------------------
# Info.plist (Generated by CMake)
# --------------------------------------
message (STATUS "Creating Info.plist")
# If project source directory has .hg directory, this process will override the version number.
find_program (MERCURIAL hg)
if (NOT MERCURIAL STREQUAL MERCURIAL-NOTFOUND
    AND EXISTS "${PROJECT_SOURCE_DIR}/.hg")
  execute_process (
    COMMAND ${MERCURIAL} -R "${PROJECT_SOURCE_DIR}" parents --template "{latesttag}.{latesttagdistance}"
    OUTPUT_VARIABLE PROJECT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif ()

# Variables for Info.plist
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
configure_file (
  "${CMAKE_ROOT}/Modules/MacOSXBundleInfo.plist.in"
  "${BUNDLE_CONTENTS_DIR}/Info.plist")


# --------------------------------------
# Exclude 32-bit
# --------------------------------------
if (PROC_BIT_DEPTH EQUAL 64)
  message (STATUS "Excluding 32-bit binary")
  file (GLOB_RECURSE object "${LIBDIR}/*.dylib" "${LIBDIR}/*.so")
  foreach (x IN LISTS object)
    execute_process (
      COMMAND lipo -info "${x}"
      OUTPUT_VARIABLE arch)
    if (arch MATCHES "i386")
      execute_process (
        COMMAND printf "   lipo -thin x86_64 -output ${x} ${x}"
        COMMAND sh -v)
    endif (arch MATCHES "i386")
  endforeach (x IN LISTS object)
endif (PROC_BIT_DEPTH EQUAL 64)


# --------------------------------------
# Change install name
# --------------------------------------
# Add @loader_path to executable
message (STATUS "Add @loader_path to executable")
execute_process (
  COMMAND printf "   install_name_tool -add_rpath @loader_path/lib ${executable}"
  COMMAND sh -v)

file (GLOB_RECURSE frameworks "${LIBDIR}/*.dylib"
                              "${LIBDIR}/*.so") # List object files
list (INSERT frameworks 0 "${executable}") # Insert executable file to first of list

foreach (x IN LISTS frameworks)
  
  ## Variables
  # x     = Path of object file in bundle
  # xname = Basename of 'x'
  # y     = Dependent shared library path (without system path)
  # yname = Basename of 'y'
  
  message ("") # blank line
  message (STATUS "Changing install names: ${x}")
  get_filename_component (xname "${x}" NAME) # Set basename
  
  # Change shared library identification name (*.dylib only)
  if (x MATCHES "\\.dylib$")
    set (xname "@rpath/${xname}")
    execute_process (COMMAND install_name_tool -id "${xname}" "${x}")
    message ("   ${xname}")
  endif ()
  
  # Change dependent shared library install name
  get_dependencies ("${x}")
    foreach (y IN LISTS dependencies) # If 'dependencies' variable is empty then will skip foreach
      get_filename_component (yname "${y}" NAME) # Set basename
      set (yname "@rpath/${yname}")
      execute_process (COMMAND install_name_tool -change "${y}" "${yname}" "${x}")
      message ("   ${y} => ${yname}")
    endforeach ()
endforeach ()
message ("") # blank line


# --------------------------------------
# Disk image
# --------------------------------------
## Disk image name and volume name
set (DMG_NAME         "${PROJECT_NAME_LOWERCASE}_mac${PROC_BIT_DEPTH}_${PROJECT_VERSION}.dmg")
set (DMG_SOURCE_DIR   "${PROJECT_NAME}${PROJECT_VERSION}") # Use as volume name
## Include contents
set (DMG_SOURCE_FILES "${PROJECT_NAME}.app")
list (APPEND DMG_SOURCE_FILES "AboutThisBuild.txt")
list (APPEND DMG_SOURCE_FILES "${PROJECT_SOURCE_DIR}/doc/RawTherapeeManual_en.pdf")
## hdiutil command
set (HDIUTIL_COMMAND hdiutil create)
list (APPEND HDIUTIL_COMMAND -format UDBZ) # bzip2-compressed (default: zlib-compressed)
list (APPEND HDIUTIL_COMMAND -srcdir "${DMG_SOURCE_DIR}")
list (APPEND HDIUTIL_COMMAND "${DMG_NAME}")

message (STATUS "Collecting disk image resources")
file (COPY ${DMG_SOURCE_FILES} DESTINATION "${DMG_SOURCE_DIR}")
execute_process (COMMAND ln -s /Applications "${DMG_SOURCE_DIR}") # Symlink to "/Applications"
execute_process (COMMAND defaults write "${CMAKE_BINARY_DIR}/${DMG_SOURCE_DIR}/RawTherapee Blog" URL "http://www.rawtherapee.com") # .webloc
file (RENAME "${DMG_SOURCE_DIR}/RawTherapee Blog.plist" "${DMG_SOURCE_DIR}/RawTherapee Blog.webloc")

message (STATUS "Creating disk image, please wait")
execute_process (COMMAND ${HDIUTIL_COMMAND})

message (STATUS "Cleaning disk image source")
file (REMOVE_RECURSE "${DMG_SOURCE_DIR}")
