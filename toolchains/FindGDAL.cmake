#---------------------------------------------------------------------------
# Get and build GDAL
# This is to compatible with official FindGDAL function

message( "External project - GDAL " )

include(FindPackageHandleStandardArgs)

macro(DO_FIND_GDAL_DOWNLOAD)
    # SQLite3
    ExternalProject_Add(SQLite3
            URL "https://sqlite.org/2018/sqlite-autoconf-3240000.tar.gz"
            URL_MD5 dcd96fb9bbb603d29f6b0ad9554932ee
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )


    # freexl:  MS Excel format
    ExternalProject_Add(freexl
            URL "http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-1.0.5.tar.gz"
            URL_MD5 3ed2a0486f03318820b25f0ccae5e14d
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # GEOS 3.6.3
    ExternalProject_Add(GEOS
            URL "https://github.com/libgeos/geos/archive/3.6.2.tar.gz"
            URL_MD5 d941923be26aedc9e86e0c0690573756
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # PROJ.4 5.1.0
    ExternalProject_Add(PROJ.4
            URL "http://download.osgeo.org/proj/proj-5.1.0.tar.gz"
            URL_MD5 68c46f6da7e4cd5708f83fe47af80db6
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # Spatialite
    ExternalProject_Add(Spatialite
            DEPENDS SQLite3 PROJ.4 freexl GEOS
            URL "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-4.3.0.tar.gz"
            URL_MD5 59ec162d3e4db2d247945e3a943f64bc
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # libkml 1.3.0
    # zlib / minzip / uriparser will be automatically downloaded and compiled
    ExternalProject_Add(libkml
            URL "https://github.com/libkml/libkml/archive/1.3.0.tar.gz"
            URL_MD5 e663141e9ebd480538b25d226e1b2979
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS} -DBoost_INCLUDE_DIRS={CMAKE_BINARY_DIR}/INSTALL
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # Xerces (GML format)
    ExternalProject_Add(Xerces
            URL "https://github.com/apache/xerces-c/archive/Xerces-C_3_2_1.tar.gz"
            URL_MD5 a409584c98dd5960e2382a69ceb03e15
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CMAKE_COMMAND ${GDA_CMAKE_Command}
            CMAKE_ARGS ${GDA_CMAKE_ARGS}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # openssl 1.1.0h
    ExternalProject_Add(openssl
            URL "https://github.com/openssl/openssl/archive/OpenSSL_1_1_0h.tar.gz"
            URL_MD5 9ff108365face87cbcc729e0580a30f3
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ./config
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )


    # CURL
    ExternalProject_Add(curl
            DEPENDS openssl
            URL "https://curl.haxx.se/download/curl-7.61.0.tar.gz"
            URL_MD5 ef343f64daab4691f528697b58a2d984
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --with-ssl=${GDAL_ROOT}
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    # PostgreSQL
    ExternalProject_Add(PostgreSQL
            URL "https://github.com/postgres/postgres/archive/REL9_6_9.tar.gz"
            URL_MD5 dec8add8c3eff05d6e8bd502d3a69f00
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --prefix=${GDAL_ROOT}
            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )

    set(GDAL_MAYBE_MYSQL)

    if (GDAL_WITH_MYSQL)
        # MySQL (install boost 1.59)
        ExternalProject_Add(MySQL
                URL "https://github.com/mysql/mysql-server/archive/mysql-5.7.22.tar.gz"
                URL_MD5 f16bea5c93e59bcfe4a1dd753db7e830
                BUILD_IN_SOURCE 1
                UPDATE_COMMAND ""
                PATCH_COMMAND ""
                CMAKE_COMMAND ${GDA_CMAKE_Command}
                CMAKE_ARGS ${GDA_CMAKE_ARGS} -DDOWNLOAD_BOOST=1 -DWITH_BOOST=${GDAL_ROOT}
                BUILD_COMMAND ${GDA_Build_Command}
                INSTALL_COMMAND ${GDA_Install_Command}
                INSTALL_DIR ${GDAL_ROOT}
                )
        set(GDAL_MAYBE_MYSQL "--with-mysql=${GDAL_ROOT}/bin/mysql_config")
    endif()


    #GDAL
    ExternalProject_Add(GDAL
            DEPENDS curl Spatialite libkml Xerces curl PostgreSQL MySQL
            URL "http://download.osgeo.org/gdal/2.3.1/gdal-2.3.1.tar.gz"
            URL_MD5 7d66070d83204efb810cdb95d0ed2463
            BUILD_IN_SOURCE 1
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            CONFIGURE_COMMAND ${GDA_Config_Command}
            --without-libtool
            --without-pam
            --with-xml2=no
            --with-jpeg=internal
            --with-libiconv-prefix="-L/usr/lib"
            --prefix=${GDAL_ROOT}
            --with-freexl=${GDAL_ROOT}
            --with-sqlite3=${GDAL_ROOT}
            --with-spatialite=${GDAL_ROOT}
            --with-static-proj4=${GDAL_ROOT}
            --with-curl=${GDAL_ROOT}/bin/curl-config
            --with-geos=${GDAL_ROOT}/bin/geos-config
            --with-libkml=${GDAL_ROOT}
            --with-xerces=${GDAL_ROOT}
            --with-xerces-inc=${GDAL_ROOT}/include
            --with-xerces-lib="-L${GDAL_ROOT}/lib -lxerces-c -framework CoreServices"
            --with-pg=${GDAL_ROOT}/bin/pg_config
            ${GDAL_MAYBE_MYSQL}

            BUILD_COMMAND ${GDA_Build_Command}
            INSTALL_COMMAND ${GDA_Install_Command}
            INSTALL_DIR ${GDAL_ROOT}
            )
endmacro()

if(NOT GDAL_FOUND)
    DO_FIND_GDAL_DOWNLOAD()
    set(GDAL_FOUND 1)
    set(GDAL_LIBRARIES ${GDAL_ROOT}/lib/libgdal.dylib)
    set(GDAL_INCLUDE_DIRS ${GDAL_ROOT}/include)
    mark_as_advanced(GDAL_LIBRARIES GDAL_INCLUDE_DIRS)
endif()
