qml_module(qshell-hyprland
    URI QShell.Hyprland
    SOURCES
        cachingimagemanager.hpp cachingimagemanager.cpp
        circularindicatormanager.hpp circularindicatormanager.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
)
