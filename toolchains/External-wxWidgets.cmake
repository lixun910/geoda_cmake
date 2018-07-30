#---------------------------------------------------------------------------
# Get and build wxWidgets
# This is to compatible with official FindWxWidgets function

message( "External project - wxWidgets3.1.1" )

set(WX_MAYBE_COCOA)
if(APPLE)
    set(WX_MAYBE_COCOA "--with-cocoa")
endif()

# wxWidgets 3.1.1 (zlib, expat)
ExternalProject_Add(wxWidgets
        URL "https://github.com/wxWidgets/wxWidgets/archive/v3.1.1.tar.gz"
        URL_MD5 f6ea5303455bb6817f83b9eeb55879ec
        BUILD_IN_SOURCE 1
        BUILD_ALWAYS 1
        UPDATE_COMMAND ""
        PATCH_COMMAND ""
        CONFIGURE_COMMAND ${GDA_Config_Command}
        --enable-cxx11
        --disable-mediactrl
        --disable-shared
        --disable-monolithic
        --with-opengl
        --with-regex
        --enable-postscript
        --enable-textfile
        --without-liblzma
        --enable-webview
        --prefix=${CMAKE_BINARY_DIR}/INSTALL
        ${WX_MAYBE_COCOA}
        BUILD_COMMAND ${GDA_Build_Command}
        INSTALL_COMMAND ${GDA_Install_Command}
        INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL
        )

ExternalProject_Get_Property(wxWidgets install_dir)