#---------------------------------------------------------------------------
# Get and build CLAPACK

message( "External project - CLAPACK" )

include(FindPackageHandleStandardArgs)

macro(DO_FIND_CLAPACK_DOWNLOAD)
    # CLAPACK 3.2.1
    ExternalProject_Add(CLAPACK
            URL "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
            URL_MD5 4fd18eb33f3ff8c5d65a7d43913d661b
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL
            )
    ExternalProject_Get_Property(CLAPACK source_dir)
    set( CLAPACK_SRC_PATH ${source_dir})
endmacro()





if(NOT CLAPACK_FOUND)
    DO_FIND_CLAPACK_DOWNLOAD()
    set(CLAPACK_FOUND 1)
    set( CLAPACK_LIBRARY )
    if( UNIX )
        set( CLAPACK_LIBRARY "${CLAPACK_SRC_PATH}/SRC/liblapack.a;${CLAPACK_SRC_PATH}/BLAS/SRC/libblas.a;${CLAPACK_SRC_PATH}/F2CLIBS/libf2c/libf2c.a" )
    else()
        if( WIN32 )
            set( CLAPACK_LIBRARY ${CLAPACK_SRC_PATH} )
        endif()
    endif()
    set(CLAPACK_LIBRARIES ${CLAPACK_LIBRARY})
endif()