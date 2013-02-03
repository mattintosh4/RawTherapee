set (MACOSX_BUNDLE_COMMAND  ${CMAKE_COMMAND}
                            -D PROJECT_NAME:STRING="${PROJECT_NAME}"
                            -D PROJECT_SOURCE_DIR:PATH="${PROJECT_SOURCE_DIR}"
                            -D CMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                            -D GTK_PREFIX:PATH="${GTK_PREFIX}"
                            -D GTK_LIBRARIES:STRING="${GTK_LIBRARIES}"
)

# PROC_BIT_DEPTH (Use as disk image name)
if (PROC_BIT_DEPTH MATCHES 32)
    list (APPEND MACOSX_BUNDLE_COMMAND -D PROC_BIT_DEPTH:STRING=32)
elseif (PROC_BIT_DEPTH MATCHES 64)
    list (APPEND MACOSX_BUNDLE_COMMAND -D PROC_BIT_DEPTH:STRING=64)
endif (PROC_BIT_DEPTH MATCHES 32)

# CMake process script
list (APPEND MACOSX_BUNDLE_COMMAND -P "${PROJECT_SOURCE_DIR}/tools/osx/macosx_bundle.cmake")

add_custom_target(macosx_bundle
    COMMAND ${MACOSX_BUNDLE_COMMAND}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    COMMENT "Creating Mac OS X bundle"
)