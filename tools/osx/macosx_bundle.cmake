set (MACOSX_BUNDLE_CONTENTS     "${PROJECT_NAME}.app/Contents")
set (MACOSX_BUNDLE_MACOS        "${MACOSX_BUNDLE_CONTENTS}/MacOS")
set (MACOSX_BUNDLE_RESOURCES    "${MACOSX_BUNDLE_CONTENTS}/Resources")
set (LIBDIR "${MACOSX_BUNDLE_MACOS}/lib")
set (ETCDIR "${MACOSX_BUNDLE_MACOS}/etc")
set (BUNDLE_CONTENTS_DIR    "${PROJECT_NAME}.app/Contents")
set (BUNDLE_MACOS_DIR       "${BUNDLE_CONTENTS_DIR}/MacOS")
set (BUNDLE_RESOURCES_DIR   "${BUNDLE_CONTENTS_DIR}/Resources")
set (LIBDIR "${BUNDLE_MACOS_DIR}/lib")
set (ETCDIR "${BUNDLE_MACOS_DIR}/etc")
string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWERCASE)


file (GLOB oldfile . "*.app" "*.dmg")
if (NOT oldfile STREQUAL "")
    message (STATUS "Removing old bundle and disk image")
    file (REMOVE_RECURSE ${oldfile})
endif ()


message (STATUS "Creating app bundle container")
file (MAKE_DIRECTORY ${MACOSX_BUNDLE_RESOURCES})


message (STATUS "Copying main files")
file (COPY "${CMAKE_BUILD_TYPE}" DESTINATION "${MACOSX_BUNDLE_CONTENTS}")
file (RENAME "${MACOSX_BUNDLE_CONTENTS}/${CMAKE_BUILD_TYPE}" "${MACOSX_BUNDLE_MACOS}")


function (importDeps)
    execute_process(
        COMMAND otool -L "${ARGV0}"
        COMMAND awk "NR >= 2 && $1 !~ /^(\\/usr\\/lib|\\/System|@executable_path)\\// { print $1 }"
        OUTPUT_VARIABLE
            dependencies
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string (REPLACE "\n" ";" dependencies ${dependencies})
    foreach (x IN LISTS dependencies)
        get_filename_component (x ${x} REALPATH)
        get_filename_component (y ${x} NAME)
        if (NOT EXISTS "${LIBDIR}/${y}")
            file (INSTALL "${x}" DESTINATION ${LIBDIR} USE_SOURCE_PERMISSIONS)
            importDeps (${x})
            file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
            if (IS_SYMLINK "${x}")
                get_filename_component (x ${x} REALPATH)
                file (INSTALL "${x}" DESTINATION "${LIBDIR}" USE_SOURCE_PERMISSIONS)
            endif ()
            checkLink ("${x}")
        endif ()
    endforeach ()
endfunction ()
message (STATUS "Copying executable dependencies")
importDeps ("${MACOSX_BUNDLE_MACOS}/rawtherapee")


############### Library modules ###############
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
message (STATUS "Replacing modules config files")
execute_process (
    COMMAND sed -i "" -e "s|${GTK_PREFIX}|/tmp/${MACOSX_BUNDLE_MACOS}|"
            "${ETCDIR}/gtk-2.0/gdk-pixbuf.loaders"
            "${ETCDIR}/gtk-2.0/gtk.immodules"
            "${ETCDIR}/pango/pango.modules"
)
file (WRITE "${ETCDIR}/pango/pangorc" "[Pango]\nModuleFiles = /tmp/${ETCDIR}/pango/pango.modules")


############### Mime data ###############
message (STATUS "Copying mime data files")
file (INSTALL "${GTK_PREFIX}/share/mime" DESTINATION "${MACOSX_BUNDLE_MACOS}/share" USE_SOURCE_PERMISSIONS)


############### Info.plist ###############
message (STATUS "Creating Info.plist")
find_program (MERCURIAL hg)
if (NOT MERCURIAL STREQUAL MERCURIAL-NOTFOUND AND EXISTS ${PROJECT_SOURCE_DIR}/.hg)
    execute_process (
        COMMAND ${MERCURIAL} -R ${PROJECT_SOURCE_DIR} parents --template "{latesttag}.{latesttagdistance}"
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
configure_file ("${CMAKE_ROOT}/Modules/MacOSXBundleInfo.plist.in" "${MACOSX_BUNDLE_CONTENTS}/Info.plist")


############### Other resources ###############
message (STATUS "Copying other resources")
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/start" DESTINATION "${MACOSX_BUNDLE_MACOS}" USE_SOURCE_PERMISSIONS)
file (INSTALL "${PROJECT_SOURCE_DIR}/tools/osx/Icons.icns" DESTINATION "${MACOSX_BUNDLE_RESOURCES}" USE_SOURCE_PERMISSIONS)


############### Distribution disk image ###############
message (STATUS "Creating distribution disk image")
execute_process (
    COMMAND hdiutil create -srcdir "${PROJECT_NAME}.app" "${PROJECT_NAME_LOWERCASE}_mac${PROC_BIT_DEPTH}_${PROJECT_VERSION}.dmg"
)
