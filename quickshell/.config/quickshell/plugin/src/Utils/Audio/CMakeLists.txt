qml_module(utils-audio
    URI Utils.Audio
    SOURCES
        service.hpp service.cpp
        serviceref.hpp serviceref.cpp
        audiocollector.hpp audiocollector.cpp
        audioprovider.hpp audioprovider.cpp
        cavaprovider.hpp cavaprovider.cpp
    LIBRARIES
        PkgConfig::Pipewire
        PkgConfig::Cava
)
