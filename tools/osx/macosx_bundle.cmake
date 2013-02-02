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


function (checkLink)
    execute_process(
        COMMAND otool -L "${ARGV0}"
        COMMAND awk "NR >= 2 && $1 !~ /^(\\/usr\\/lib|\\/System|@executable_path)\\// { print $1 }"
        OUTPUT_VARIABLE
            dependencies
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
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
message (STATUS "Copying dependency libraries")
checkLink ("${BUNDLE_MACOS_DIR}/rawtherapee")


message (STATUS "Copying library modules")
file (
    INSTALL     "${GTK_PREFIX}/lib/gtk-2.0"
                "${GTK_PREFIX}/lib/gdk-pixbuf-2.0"
                "${GTK_PREFIX}/lib/pango"
    DESTINATION "${LIBDIR}"
    USE_SOURCE_PERMISSIONS
)
file (
    INSTALL     "${GTK_PREFIX}/etc/gtk-2.0"
                "${GTK_PREFIX}/etc/pango"
    DESTINATION "${ETCDIR}"
    USE_SOURCE_PERMISSIONS
)
message (STATUS "Replacing path in the config files")
execute_process (
    COMMAND sed -i "" -e "s|${GTK_PREFIX}|/tmp/${BUNDLE_MACOS_DIR}|"
            "${ETCDIR}/gtk-2.0/gdk-pixbuf.loaders"
            "${ETCDIR}/gtk-2.0/gtk.immodules"
            "${ETCDIR}/pango/pango.modules"
)
file (WRITE "${ETCDIR}/pango/pangorc" "[Pango]\nModuleFiles = /tmp/${ETCDIR}/pango/pango.modules")


message (STATUS "Copying mime data files")
file (INSTALL "${GTK_PREFIX}/share/mime" DESTINATION "${BUNDLE_MACOS_DIR}/share" USE_SOURCE_PERMISSIONS)


message (STATUS "Copying other resources")
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/start" DESTINATION "${BUNDLE_MACOS_DIR}" USE_SOURCE_PERMISSIONS)
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/Icons.icns" DESTINATION "${BUNDLE_RESOURCES_DIR}" USE_SOURCE_PERMISSIONS)


message (STATUS "Creating Info.plist")
find_program (MERCURIAL hg)
if (NOT MERCURIAL STREQUAL MERCURIAL-NOTFOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.hg")
    execute_process (
        COMMAND ${MERCURIAL} -R "${PROJECT_SOURCE_DIR}" parents --template "{latesttag}.{latesttagdistance}"
        OUTPUT_VARIABLE
            PROJECT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif ()
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


message (STATUS "Creating distribution disk image")
execute_process (
    COMMAND hdiutil create -srcdir "${PROJECT_NAME}.app" "${PROJECT_NAME_LOWERCASE}_mac${PROC_BIT_DEPTH}_${PROJECT_VERSION}.dmg"
)
