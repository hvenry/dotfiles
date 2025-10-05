cmake_minimum_required(VERSION 3.19)

# -----------------------------------------------------------------------------
# Project Metadata
# -----------------------------------------------------------------------------
if(NOT DEFINED VERSION)
    execute_process(COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if("${VERSION}" STREQUAL "")
        message(FATAL_ERROR "VERSION is not set and failed to get from git")
    endif()
endif()

if(NOT DEFINED GIT_REVISION)
    execute_process(COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE GIT_REVISION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if("${GIT_REVISION}" STREQUAL "")
        message(FATAL_ERROR "GIT_REVISION is not set and failed to get from git")
    endif()
endif()

string(REGEX REPLACE "^v" "" VERSION "${VERSION}")

project(caelestia-shell VERSION ${VERSION} LANGUAGES CXX)

# -----------------------------------------------------------------------------
# Build Settings
# -----------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

set(DISTRIBUTOR "Unset" CACHE STRING "Distributor")
set(ENABLE_MODULES "extras;plugin;shell" CACHE STRING "Modules to build/install")
set(INSTALL_LIBDIR "usr/lib/caelestia" CACHE STRING "Library install dir")
set(INSTALL_QMLDIR "usr/lib/qt6/qml" CACHE STRING "QML install dir")
set(INSTALL_QSCONFDIR "etc/xdg/quickshell/caelestia" CACHE STRING "Quickshell config install dir")

add_compile_options(
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion
    -Wold-style-cast -Wnull-dereference -Wdouble-promotion
    -Wformat=2 -Wfloat-equal -Woverloaded-virtual
    -Wsign-conversion -Wredundant-decls -Wswitch
    -Wunreachable-code
)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wunused-lambda-capture)
endif()

# -----------------------------------------------------------------------------
# Subdirectories
# -----------------------------------------------------------------------------
if("extras" IN_LIST ENABLE_MODULES)
    add_subdirectory(extras)
endif()

if("plugin" IN_LIST ENABLE_MODULES)
    add_subdirectory(plugin)
endif()

if("shell" IN_LIST ENABLE_MODULES)
    foreach(dir assets components config modules services utils)
        install(DIRECTORY ${dir} DESTINATION "${INSTALL_QSCONFDIR}")
    endforeach()
    install(FILES shell.qml LICENSE DESTINATION "${INSTALL_QSCONFDIR}")
endif()

# -----------------------------------------------------------------------------
# QML Language Server configuration generation
# -----------------------------------------------------------------------------
find_package(Qt6 6.6 REQUIRED COMPONENTS Qml Quick)

set(QT_QML_GENERATE_QMLLS_INI ON)

# Include all local + system import paths for QMLLS
set(QML_IMPORT_PATHS
    "${CMAKE_SOURCE_DIR}/modules"
    "${CMAKE_SOURCE_DIR}/components"
    "${CMAKE_SOURCE_DIR}/config"
    "${CMAKE_SOURCE_DIR}/services"
    "${CMAKE_SOURCE_DIR}/utils"
    "${CMAKE_SOURCE_DIR}/plugin"
    "/usr/lib/qt6/qml"
    "/usr/lib/quickshell/qml"
)
set_property(DIRECTORY PROPERTY QT_QML_IMPORT_PATHS ${QML_IMPORT_PATHS})

# Create dummy source to drive QML metadata generation
file(WRITE "${CMAKE_BINARY_DIR}/main.cpp" "int main() { return 0; }")

qt_add_executable(qml_dummy "${CMAKE_BINARY_DIR}/main.cpp")

# Enable AUTOMOC for metatype generation
set_target_properties(qml_dummy PROPERTIES AUTOMOC ON)

# Silence policy warning about resource prefixes
qt_policy(SET QTP0001 NEW)

# Add dummy QML module — make sure QML_FILES are relative!
qt_add_qml_module(qml_dummy
    URI "Caelestia.Dummy"
    VERSION 1.0
    QML_FILES "shell.qml"
)

# Make sure shell.qml is findable in build dir for QMLLS
file(COPY "${CMAKE_SOURCE_DIR}/shell.qml" DESTINATION "${CMAKE_BINARY_DIR}")

target_link_libraries(qml_dummy PRIVATE Qt6::Qml Qt6::Quick)

qt_finalize_target(qml_dummy)

# Ignore missing system plugins
set_property(TARGET qml_dummy PROPERTY QT_QML_IMPORT_SCAN_IGNORE_MISSING TRUE)

message(STATUS "✅ QMLLS ini will be generated at: ${CMAKE_BINARY_DIR}/.qmlls.ini")

# -----------------------------------------------------------------------------
# Force generation of QML Language Server configuration
# -----------------------------------------------------------------------------
if(QT_QML_GENERATE_QMLLS_INI)
    set(QMLLS_PATH "${CMAKE_BINARY_DIR}/.qmlls.ini")

    file(WRITE "${QMLLS_PATH}" "[General]\n")
    file(APPEND "${QMLLS_PATH}" "ImportPaths=\n")

    # Append all QML import paths, joined by semicolons
    foreach(path IN LISTS QML_IMPORT_PATHS)
        file(APPEND "${QMLLS_PATH}" "${path};")
    endforeach()

    file(APPEND "${QMLLS_PATH}" "\n")

    message(STATUS "✅ Forced QMLLS ini generated at: ${QMLLS_PATH}")
endif()

