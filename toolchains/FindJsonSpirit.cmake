#---------------------------------------------------------------------------
# Get and build JsonSpirit
# This is to compatible with official FindWxWidgets function

message( "External project - JsonSpirit" )

include(FindPackageHandleStandardArgs)

macro(DO_FIND_WXWIDGETS_DOWNLOAD)
    # JSON_Spirit
    ExternalProject_Add(JsonSpirit
            URL "https://s3.us-east-2.amazonaws.com/geodabuild/json_spirit_v4.08.zip"
            URL_MD5 63174241933d3c52b1568febb89dfee5
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS} -DBOOST_ROOT=${CMAKE_BINARY_DIR}/INSTALL
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL
            )
endmacro()

set( JsonSpirit_LIBRARY )
if( UNIX )
    set( JsonSpirit_LIBRARY ${JSONSPIRIT_ROOT_DIR}/lib/libjson_spirit.a )
else()
    if( WIN32 )
        set( JsonSpirit_LIBRARY ${JSONSPIRIT_ROOT_DIR}/lib/libjson_spirit.a )
    endif()
endif()

if(NOT JsonSpirit_FOUND)
    DO_FIND_WXWIDGETS_DOWNLOAD()
    set(JsonSpirit_FOUND 1)
    set(JsonSpirit_INCLUDE_DIRS ${JSONSPIRIT_ROOT_DIR}/include)
    set(JsonSpirit_LIBRARIES ${JsonSpirit_LIBRARY})
    #set(JsonSpirit_CXX_FLAGS -D_FILE_OFFSET_BITS=64 -D__WXMAC__ -D__WXOSX__ -D__WXOSX_COCOA__)
endif()
