cmake_minimum_required(VERSION 3.14)
project(quickmeshviewer LANGUAGES CXX)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 COMPONENTS Core)
find_package(Qt6 COMPONENTS Gui)
find_package(Qt6 COMPONENTS Quick)
find_package(Qt6 COMPONENTS Quick3D)

find_package(Eigen3 REQUIRED)
find_package(IGL REQUIRED)

include_directories(${EIGEN3_INCLUDE_DIR})
include_directories(${IGL_INCLUDE_DIR})

qt_add_executable(quickmeshviewer
    examplegeometry.cpp examplegeometry.h
    trigeometry.cpp trigeometry.h
    main.cpp
)
set_target_properties(quickmeshviewer PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
target_link_libraries(quickmeshviewer PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Quick
    Qt::Quick3D
)


# Resources:
set(resources_resource_files
    "main.qml"
    "qt_logo_rect.png"
)

qt6_add_resources(quickmeshviewer "resources"
    PREFIX
        "/"
    FILES
        ${resources_resource_files}
)

#install(TARGETS quickmeshviewer 
#    RUNTIME DESTINATION "${INSTALL_EXAMPLEDIR}"
#    BUNDLE DESTINATION "${INSTALL_EXAMPLEDIR}"
#    LIBRARY DESTINATION "${INSTALL_EXAMPLEDIR}"
#)
#
set_target_properties(quickmeshviewer PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI QuickMeshViewer
)

qt6_qml_type_registration(quickmeshviewer)
