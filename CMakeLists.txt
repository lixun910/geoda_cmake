# Top level CMakeLists.txt
# At Least 2.8 but newer is better
# Author: Xun Li xunli@uchicago.edu
# NOTE:
# Morden Cmake is all about TARGETS and PROPERTIES: make a list of targets and define the properties of them
# Target properties are defined in one of two scopes: INTERFACE and PRIVATE.
# Declare module with ADD_LIBRARY or ADD_EXECUTABLE
# Declare your build flags with TARGET_xxx()
# Declare your dependencies with TARGET_LINK_LIBRARIES
# Specify what is PUBLIC and what is PRIVATE
# Dont use macros that affect all targets: INCLUDE_DIRECTORIES() ADD_DEFINITIONS() LINK_LIBRARIES
# Don't use TARGET_INCLUDE_DIRECTORIES() with a path outside your module
# External packages should be targets and use modern finders that declare targets
# CMAKE version 3.7 provide targets OPENCL 3.8 provides OPENGL


# Function:                 EXCLUDE_FILES_FROM_DIR_IN_LIST
# Description:              Exclude all files from a list under a specific directory.
# Param _InFileList:        Input and returned List
# Param _excludeDirName:    Name of the directory, which shall be ignored.
# Param _verbose:           Print the names of the files handled

FUNCTION (EXCLUDE_FILES_FROM_DIR_IN_LIST _InFileList _excludeDirName _verbose)
    foreach (ITR ${_InFileList})
        if ("${_verbose}")
            message(STATUS "ITR=${ITR}")
        endif ("${_verbose}")

        if ("${ITR}" MATCHES "(.*)${_excludeDirName}(.*)")                   # Check if the item matches the directory name in _excludeDirName
            message(STATUS "Remove Item from List:${ITR}")
            list (REMOVE_ITEM _InFileList ${ITR})                              # Remove the item from the list
        endif ("${ITR}" MATCHES "(.*)${_excludeDirName}(.*)")

    endforeach(ITR)
    set(FOUND_SOURCES ${_InFileList} PARENT_SCOPE)                          # Return the SOURCE_FILES variable to the calling parent
ENDFUNCTION (EXCLUDE_FILES_FROM_DIR_IN_LIST)


include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)

## Global Setup
cmake_minimum_required(VERSION 2.8)

if (POLICY CMP0015)
    cmake_policy(SET CMP0015 NEW)
endif ()
if (POLICY CMP0026)
    cmake_policy(SET CMP0026 NEW)
endif ()
if (POLICY CMP0028)
    cmake_policy(SET CMP0028 NEW)
endif ()
if (POLICY CMP0048)
    cmake_policy(SET CMP0048 NEW)
endif ()
if (POLICY CMP0074)
    cmake_policy(SET CMP0074 NEW) # CMake 3.12
endif ()


project(geoda)

set (CMAKE_CXX_STANDARD 11)
set (CMAKE_BUILD_TYPE Release)

set (DEPS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/deps)


# 1. Define your library, only source files here!
# Manually add sources using set command
#set(SOURCES geoda/rc/GeoDa.rc geoda/internationalization/GeoDa.mo)
# file(GLOB...) allows for wildcard additions:
#file(GLOB SOURCES "geoda/*.cpp")

set (SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/geoda)
file(GLOB_RECURSE FOUND_SOURCES "${SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE FOUND_HEADERS "${SOURCE_DIR}/*.h")

#list(REMOVE_ITEM FOUND_HEADERS "${SOURCE_DIR}")
EXCLUDE_FILES_FROM_DIR_IN_LIST("${FOUND_SOURCES}" "/CommonDistFiles/" FALSE)
EXCLUDE_FILES_FROM_DIR_IN_LIST("${FOUND_SOURCES}" "/BuildTools/" FALSE)
EXCLUDE_FILES_FROM_DIR_IN_LIST("${FOUND_SOURCES}" "/Generic/" FALSE)
EXCLUDE_FILES_FROM_DIR_IN_LIST("${FOUND_SOURCES}" "/swig/" FALSE)


add_executable(${PROJECT_NAME} ${FOUND_SOURCES} ${FOUND_HEADERS})

# Or build a static library
#add_library(geoda STATIC ${SOURCES})
# Set location for library installation. Use "sudo make install" to apply
#install(TARGETS geoda DESTINATION /usr/lib)

# 2. Define some properties on target
target_include_directories(geoda
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
	$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/INSTALL/include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/geoda>
)




# 4. Declare your dependencies
# Public (interface) dependencies
#target_link_libraries(mylib PUBLIC abc)
# Private (implementation) dependencies
#target_link_libraries(mylib PRIVATE xyz)
## Header-only librarie: nothing to build so it must be INTERFACE
#add_library(mylib INTERFACE)
#target_include_directories(mylib INTERFACE include)
#target_link_libraries(mylib INTERFACE Boost::Boost)

# some variables used for building dep libraries ONLY
if( UNIX )
    set( GDA_Config_Command ./configure )
    set( GDA_CMAKE_Command cmake )
    set( GDA_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL)
    set( GDA_Build_Command make -j8)
    set( GDA_Install_Command make install)
else()
    if( WIN32 )
        set( GDA_Build_Command "nmake -f makefile.vc")
    endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/toolchains)

set(GEODA_DEPENDS)
set(GEODA_DEP_LIBRARY_PATH ${CMAKE_BINARY_DIR}/INSTALL)

#### request wxWidgets 3.1.1 source code and compile on-the-fly
include(External-wxWidgets)
set(CMAKE_STAGING_PREFIX ${GEODA_DEP_LIBRARY_PATH}/bin)
find_program(wxWidgets_CONFIG_EXECUTABLE
      NAMES $ENV{WX_CONFIG} wx-config wx-config-3.1 wx-config-3.0 wx-config-2.9 wx-config-2.8
      DOC "Location of wxWidgets library configuration provider binary (wx-config)."
      PATHS ${GEODA_DEP_LIBRARY_PATH}/bin
      ONLY_CMAKE_FIND_ROOT_PATH
      )

find_package(wxWidgets COMPONENTS xrc stc richtext ribbon propgrid aui gl html qa adv core webview xml net base)
if (wxWidgets_FOUND)
    include(${wxWidgets_USE_FILE})
    target_link_libraries(geoda ${wxWidgets_LIBRARIES})
endif()

#### request JsonSpirit 4.08
set(JSONSPIRIT_ROOT_DIR ${GEODA_DEP_LIBRARY_PATH})

find_package(JsonSpirit)
if (JsonSpirit_FOUND)
    message(STATUS "Install JsonSpirit includes: ${JsonSpirit_INCLUDE_DIRS}")
    message(STATUS "Install JsonSpirit libraries: ${JsonSpirit_LIBRARIES}")
    include_directories(${JsonSpirit_INCLUDE_DIRS})
    target_link_libraries(geoda ${JsonSpirit_LIBRARIES})
endif()


#### request boost 1.59.0 source code and compile on-the-fly
set(BOOST_REQUESTED_VERSION 1.59.0)
set(BOOST_ROOT_DIR ${GEODA_DEP_LIBRARY_PATH})
set(BOOST_USE_STATIC_LIBS ON)
set(BOOST_USE_MULTITHREADED ON)

find_package(Boost COMPONENTS system thread date_time chrono)
if(BOOST_FOUND)
    message(STATUS "Install Boost includes: ${BOOST_INCLUDE_DIRS}")
    message(STATUS "Install Boost libraries: ${BOOST_LIBRARIES}")
    include_directories(${BOOST_INCLUDE_DIRS})
    target_link_libraries(geoda ${BOOST_LIBRARIES})
endif()

#### request GDAL 2.1.0 source code and compile on-the-fly
set(GDAL_ROOT ${GEODA_DEP_LIBRARY_PATH})
set(GDAL_WITH_MYSQL ON)

find_package(GDAL)
if (GDAL_FOUND)
    message(STATUS "Install GDAL includes: ${GDAL_INCLUDE_DIRS}")
    message(STATUS "Install GDAL libraries: ${GDAL_LIBRARIES}")
    include_directories(${GDAL_INCLUDE_DIRS})
    target_link_libraries(geoda ${GDAL_LIBRARIES})
endif()

#### request CLAPACK 3.2.1 source code and compile on-the-fly
find_package(CLAPACK)
if (CLAPACK_FOUND)
    message(STATUS "Install CPALACK libraries: ${CLAPACK_LIBRARIES}")
    target_link_libraries(geoda ${CLAPACK_LIBRARIES})
endif()

### Eigen3 
find_package (Eigen3)
if (Eigen3_FOUND)
    message(STATUS "Install Eigen3 libraries: ${EIGEN3_INCLUDE_DIRS}")
    target_link_libraries (geoda Eigen3::Eigen)
else()
     # request Eigen 3 source code
    ExternalProject_Add(Eigen3
            URL "http://bitbucket.org/eigen/eigen/get/3.3.5.tar.gz"
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND ""
            INSTALL_DIR ""
            )
    ExternalProject_Get_Property(Eigen3 source_dir)
    include_directories(${source_dir})
endif()

### OpenCL
find_package( OpenCL REQUIRED )
include_directories( ${OpenCL_INCLUDE_DIRS} )
target_link_libraries(geoda ${OpenCL_LIBRARY})
message(STATUS "FIND openCL: ${OpenCL_LIBRARY}")

### libcurl
find_path(CURL_INCLUDE_DIR NAMES curl/curl.h
	PATHS  ${GEODA_DEP_LIBRARY_PATH})
set(CURL_LIBRARY "-lcurl") 
find_package(CURL REQUIRED) 
include_directories(${CURL_INCLUDE_DIR})
target_link_libraries(geoda ${CURL_LIBRARIES})
message(STATUS "FIND libcurl: ${CURL_INCLUDE_DIRS}")

# compile anything in deps
add_subdirectory(${DEPS_DIR})

# 3. Declare your flags
# Leave CMAKE_CXX_FLAGS alone
target_compile_options(geoda
        PRIVATE -Wall -Wno-writable-strings -Wno-redeclared-class-member -Wno-unused-variable -Wno-reorder -Wno-logical-op-parentheses -Wno-unused-private-field -Wno-unused-local-typedef
        )

# set language standard to c++11
target_compile_features(geoda PRIVATE cxx_std_11)


## External projcts
#---------------------------------------------------------------------------

# Use GNUInstallDirs to install libraries into correct locations on all platform
#include(GNUInstallDirs)

# Include Boost as an imported target
#find_package(Boost REQUIRED)
#add_library(boost INTERFACE IMPORTED)
#set_property(TARGET boost PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIR})

# Some other library that we import that was built using Cmake and has an exported target
#find_package(Curl REQUIRED)

# For shared library
# set(PROOJECT_LINK_LIBS libiconv.so)
#link_directories(libs/iconv/buid)
#add_executable(geoda {SOURCES})
#target_link_libraries(geoda {PROJECT_LINK_LIBS})

# Targets that we develop here
#enable_testing()
#add_subdirectory(geoda)
#add_subdirectory(app)


