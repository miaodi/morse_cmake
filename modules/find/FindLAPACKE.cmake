###
#
# @copyright (c) 2012-2020 Inria. All rights reserved.
# @copyright (c) 2012-2014 Bordeaux INP, CNRS (LaBRI UMR 5800), Inria, Univ. Bordeaux. All rights reserved.
#
# Copyright 2012-2013 Emmanuel Agullo
# Copyright 2012-2013 Mathieu Faverge
# Copyright 2012      Cedric Castagnede
# Copyright 2013-2020 Florent Pruvost
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file MORSE-Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of Morse, substitute the full
#  License text for the above reference.)
###
#
# - Find LAPACKE include dirs and libraries
# Use this module by invoking find_package with the form:
#  find_package(LAPACKE
#               [REQUIRED] # Fail with error if lapacke is not found
#               [COMPONENTS <comp1> <comp2> ...] # dependencies
#              )
#
#  LAPACKE depends on the following libraries:
#   - LAPACK
#
#  COMPONENTS are optional libraries LAPACKE could be linked with,
#  Use it to drive detection of a specific compilation chain
#  COMPONENTS can be some of the following:
#   - TMG: to check that LAPACKE provides the tmglib interface
#
#  LAPACKE_FOUND_WITH_PKGCONFIG - True if found with pkg-config
#  if found the following variables may be set
#  LAPACKE_PREFIX            - installation path of the lib found
#  <PREFIX>  = LAPACKE
#  <XPREFIX> = <PREFIX>        for common case
#  <XPREFIX> = <PREFIX>_STATIC for static linking
#  <XPREFIX>_FOUND          ... set to 1 if module(s) exist
#  <XPREFIX>_LIBRARIES      ... only the libraries (w/o the '-l')
#  <XPREFIX>_LIBRARY_DIRS   ... the paths of the libraries (w/o the '-L')
#  <XPREFIX>_LDFLAGS        ... all required linker flags
#  <XPREFIX>_LDFLAGS_OTHER  ... all other linker flags
#  <XPREFIX>_INCLUDE_DIRS   ... the '-I' preprocessor flags (w/o the '-I')
#  <XPREFIX>_CFLAGS         ... all required cflags
#  <XPREFIX>_CFLAGS_OTHER   ... the other compiler flags
#
# Set LAPACKE_STATIC to 1 to force using static libraries if exist.
# Set LAPACKE_MT to 1 to force using multi-threaded lapack libraries if exist (Intel MKL).
#
# This module defines the following :prop_tgt:`IMPORTED` target:
#
# ``MORSE::LAPACKE``
#   The headers and libraries to use for LAPACKE, if found.
#
# The user can give specific paths where to find the libraries adding cmake
# options at configure (ex: cmake path/to/project -DLAPACKE_DIR=path/to/lapacke):
#  LAPACKE_DIR             - Where to find the base directory of lapacke
#  LAPACKE_INCDIR          - Where to find the header files
#  LAPACKE_LIBDIR          - Where to find the library files
# The module can also look for the following environment variables if paths
# are not given as cmake variable: LAPACKE_DIR, LAPACKE_INCDIR, LAPACKE_LIBDIR
#
# LAPACKE could be directly embedded in LAPACK library (ex: Intel MKL) so that
# we test a lapacke function with the lapack libraries found and set LAPACKE
# variables to LAPACK ones if test is successful. To skip this feature and
# look for a stand alone lapacke, please set LAPACKE_STANDALONE to TRUE

#=============================================================================

# Common macros to use in finds
include(FindMorseInit)

if (NOT LAPACKE_FOUND)
  set(LAPACKE_DIR "" CACHE PATH "Installation directory of LAPACKE library")
  if (NOT LAPACKE_FIND_QUIETLY)
    message(STATUS "A cache variable, namely LAPACKE_DIR, has been set to specify the install directory of LAPACKE")
  endif()
endif()

# to check LAPACKE components
set(LAPACKE_WITH_TMG OFF)
if( LAPACKE_FIND_COMPONENTS )
  foreach( component ${LAPACKE_FIND_COMPONENTS} )
    if (${component} STREQUAL "TMG")
      set(LAPACKE_WITH_TMG ON)
    endif()
  endforeach()
endif()

# LAPACKE may depend on TMG, try to find it
if (LAPACKE_WITH_TMG)
  if(LAPACKE_FIND_REQUIRED)
    find_package(TMG REQUIRED)
  else()
    find_package(TMG)
  endif()
endif()

# LAPACKE depends on LAPACK, try to find it
if(LAPACKE_FIND_REQUIRED)
  find_package(LAPACKEXT QUIET REQUIRED)
else()
  find_package(LAPACKEXT QUIET)
endif()

# LAPACKE depends on LAPACK
if (LAPACKEXT_FOUND)

  if (NOT LAPACKE_STANDALONE)
    # check if a lapacke function exists in the LAPACK lib
    include(CheckFunctionExists)
    if (LAPACK_LIBRARIES)
      set(CMAKE_REQUIRED_LIBRARIES "${LAPACK_LIBRARIES}")
    endif()
    if (LAPACK_LDFLAGS_OTHER)
      list(APPEND CMAKE_REQUIRED_LIBRARIES "${LAPACK_LDFLAGS_OTHER}")
    endif()
    if (LAPACK_LINKER_FLAGS)
      list(APPEND CMAKE_REQUIRED_LIBRARIES "${LAPACK_LINKER_FLAGS}")
    endif()
    if (LAPACK_CFLAGS_OTHER)
      set(CMAKE_REQUIRED_FLAGS "${LAPACK_CFLAGS_OTHER}")
    endif()
    if (LAPACK_INCLUDE_DIRS)
      set(CMAKE_REQUIRED_INCLUDES "${LAPACK_INCLUDE_DIRS}")
    endif()
    unset(LAPACKE_WORKS CACHE)
    check_function_exists(LAPACKE_dgeqrf LAPACKE_WORKS)
    mark_as_advanced(LAPACKE_WORKS)
    unset(LAPACKE_WITH_LASCL CACHE)
    check_function_exists(LAPACKE_dlascl_work LAPACKE_WITH_LASCL)
    mark_as_advanced(LAPACKE_WITH_LASCL)
    set(CMAKE_REQUIRED_LIBRARIES)

    if(LAPACKE_WORKS)
      if(NOT LAPACKE_FIND_QUIETLY)
        message(STATUS "Looking for lapacke: test with lapack succeeds")
      endif()
      # test succeeds: LAPACKE is in LAPACK
      if (LAPACK_LIBRARIES)
        set(LAPACKE_LIBRARIES "${LAPACK_LIBRARIES}")
      endif()
      if (LAPACK_LINKER_FLAGS)
        list(APPEND LAPACKE_LIBRARIES "${LAPACK_LINKER_FLAGS}")
      endif()
      if (LAPACK_INCLUDE_DIRS)
        set(LAPACKE_INCLUDE_DIRS "${LAPACK_INCLUDE_DIRS}")
      endif()
      if (LAPACK_LIBRARY_DIRS)
        set(LAPACKE_LIBRARY_DIRS "${LAPACK_LIBRARY_DIRS}")
      endif()
      if (LAPACK_CFLAGS_OTHER)
        set(LAPACKE_CFLAGS_OTHER "${LAPACK_CFLAGS_OTHER}")
      endif()
      if (LAPACK_LDFLAGS_OTHER)
        set(LAPACKE_LDFLAGS_OTHER "${LAPACK_LDFLAGS_OTHER}")
      endif()

      if (LAPACKE_LIBRARIES MATCHES "libmkl" AND DEFINED ENV{MKLROOT})
        set(LAPACKE_PREFIX "$ENV{MKLROOT}" CACHE PATH "Installation directory of LAPACKE library" FORCE)
        set(LAPACKE_INCLUDE_DIRS "${LAPACKE_PREFIX}/include")
        set(LAPACKE_LIBRARY_DIRS "${LAPACKE_PREFIX}/lib/intel64")
      endif()

      if (NOT LAPACKE_INCLUDE_DIRS)
        # Looking for include
        # -------------------

        # Add system include paths to search include
        # ------------------------------------------
        unset(_inc_env)
        set(ENV_LAPACKE_DIR "$ENV{LAPACKE_DIR}")
        set(ENV_LAPACKE_INCDIR "$ENV{LAPACKE_INCDIR}")
        if(ENV_LAPACKE_INCDIR)
          list(APPEND _inc_env "${ENV_LAPACKE_INCDIR}")
        elseif(ENV_LAPACKE_DIR)
          list(APPEND _inc_env "${ENV_LAPACKE_DIR}")
          list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include")
          list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include/lapacke")
          list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include/mkl")
        else()
          if(WIN32)
            string(REPLACE ":" ";" _inc_env "$ENV{INCLUDE}")
          else()
            string(REPLACE ":" ";" _path_env "$ENV{INCLUDE}")
            list(APPEND _inc_env "${_path_env}")
            string(REPLACE ":" ";" _path_env "$ENV{C_INCLUDE_PATH}")
            list(APPEND _inc_env "${_path_env}")
            string(REPLACE ":" ";" _path_env "$ENV{CPATH}")
            list(APPEND _inc_env "${_path_env}")
            string(REPLACE ":" ";" _path_env "$ENV{INCLUDE_PATH}")
            list(APPEND _inc_env "${_path_env}")
          endif()
        endif()
        list(APPEND _inc_env "${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")
        list(REMOVE_DUPLICATES _inc_env)


        # Try to find the lapacke header in the given paths
        # -------------------------------------------------

        if (LAPACKE_LIBRARIES MATCHES "libmkl")
          set(LAPACKE_hdrs_to_find "mkl.h")
        else()
          set(LAPACKE_hdrs_to_find "lapacke.h")
        endif()

        # call cmake macro to find the header path
        if(LAPACKE_INCDIR)
          set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
          find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
            NAMES ${LAPACKE_hdrs_to_find}
            HINTS ${LAPACKE_INCDIR}
            NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
        else()
          if(LAPACKE_DIR)
            set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
            find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
              NAMES ${LAPACKE_hdrs_to_find}
              HINTS ${LAPACKE_DIR}
              PATH_SUFFIXES "include" "include/lapacke" "include/mkl"
              NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
          else()
            set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
            find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
              NAMES ${LAPACKE_hdrs_to_find}
              HINTS ${_inc_env})
          endif()
        endif()
        mark_as_advanced(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS)

        # If found, add path to cmake variable
        # ------------------------------------
        if (LAPACKE_${LAPACKE_hdrs_to_find}_DIRS)
          set(LAPACKE_INCLUDE_DIRS "${LAPACKE_${LAPACKE_hdrs_to_find}_DIRS}")
        else ()
          set(LAPACKE_INCLUDE_DIRS "LAPACKE_INCLUDE_DIRS-NOTFOUND")
          if(NOT LAPACKE_FIND_QUIETLY)
            message(STATUS "Looking for lapacke -- ${LAPACKE_hdrs_to_find} not found")
          endif()
        endif()
      endif()
    endif()
  endif (NOT LAPACKE_STANDALONE)

  # test fails with lapack: try to find LAPACKE lib exterior to LAPACK
  if (LAPACKE_STANDALONE OR NOT LAPACKE_WORKS)

    if(NOT LAPACKE_WORKS AND NOT LAPACKE_FIND_QUIETLY)
      message(STATUS "Looking for lapacke : test with lapack fails")
    endif()

    # try with pkg-config
    set(ENV_LAPACKE_DIR "$ENV{LAPACKE_DIR}")
    set(ENV_MKL_DIR "$ENV{MKLROOT}")
    set(ENV_LAPACKE_INCDIR "$ENV{LAPACKE_INCDIR}")
    set(ENV_LAPACKE_LIBDIR "$ENV{LAPACKE_LIBDIR}")
    set(LAPACKE_GIVEN_BY_USER "FALSE")
    if ( LAPACKE_DIR OR ( LAPACKE_INCDIR AND LAPACKE_LIBDIR) OR ENV_LAPACKE_DIR OR ENV_MKL_DIR OR (ENV_LAPACKE_INCDIR AND ENV_LAPACKE_LIBDIR) )
      set(LAPACKE_GIVEN_BY_USER "TRUE")
    endif()

    if( PKG_CONFIG_EXECUTABLE AND NOT LAPACKE_GIVEN_BY_USER)

      if (BLA_STATIC)
        set(MKL_STR_BLA_STATIC "static")
      else()
        set(MKL_STR_BLA_STATIC "dynamic")
      endif()
      # try different blas
      if (BLA_VENDOR STREQUAL "Intel10_64lp")
        pkg_search_module(LAPACKE mkl-${MKL_STR_BLA_STATIC}-lp64-iomp)
      elseif(BLA_VENDOR STREQUAL "Intel10_64lp_seq")
        pkg_search_module(LAPACKE mkl-${MKL_STR_BLA_STATIC}-lp64-seq)
      elseif(BLA_VENDOR STREQUAL "Open")
        pkg_search_module(LAPACKE openblas)
      elseif(BLA_VENDOR STREQUAL "Generic")
        pkg_search_module(LAPACKE lapacke)
      else()
        pkg_search_module(LAPACKE lapacke)
        pkg_search_module(LAPACKE openblas)
        pkg_search_module(LAPACKE mkl-${MKL_STR_BLA_STATIC}-lp64-seq)
      endif()

      if (NOT LAPACKE_FIND_QUIETLY)
        if (LAPACKE_FOUND AND LAPACKE_LIBRARIES)
          message(STATUS "Looking for LAPACKE - found using PkgConfig")
        else()
          message(STATUS "${Magenta}Looking for LAPACKE - not found using PkgConfig."
            "\n   Perhaps you should add the directory containing lapacke.pc to"
            "\n   the PKG_CONFIG_PATH environment variable.${ColourReset}")
        endif()
      endif()

      if (LAPACKE_FOUND AND LAPACKE_LIBRARIES)
        set(LAPACKE_FOUND_WITH_PKGCONFIG "TRUE")
        morse_find_pkgconfig_libraries_absolute_path(LAPACKE)
      else()
        set(LAPACKE_FOUND_WITH_PKGCONFIG "FALSE")
      endif()

      if (LAPACKE_STATIC AND LAPACKE_STATIC_LIBRARIES)
        set (LAPACKE_DEPENDENCIES ${LAPACKE_STATIC_LIBRARIES})
        list (REMOVE_ITEM LAPACKE_DEPENDENCIES "lapacke")
        list (APPEND LAPACKE_LIBRARIES ${LAPACKE_DEPENDENCIES})
        set(LAPACKE_CFLAGS_OTHER ${LAPACKE_STATIC_CFLAGS_OTHER})
        set(LAPACKE_LDFLAGS_OTHER ${LAPACKE_STATIC_LDFLAGS_OTHER})
            if (NOT LAPACKE_FIND_QUIETLY)
          message(STATUS "LAPACKE_STATIC set to 1 by user, LAPACKE_LIBRARIES: ${LAPACKE_LIBRARIES}.")
        endif()
      endif()

    endif()

    if (NOT LAPACKE_FOUND_WITH_PKGCONFIG OR LAPACKE_GIVEN_BY_USER)

      # Try to find LAPACKE lib
      #######################

      # Looking for include
      # -------------------

      # Add system include paths to search include
      # ------------------------------------------
      unset(_inc_env)
      set(ENV_LAPACKE_DIR "$ENV{LAPACKE_DIR}")
      set(ENV_LAPACKE_INCDIR "$ENV{LAPACKE_INCDIR}")
      if(ENV_LAPACKE_INCDIR)
        list(APPEND _inc_env "${ENV_LAPACKE_INCDIR}")
      elseif(ENV_LAPACKE_DIR)
        list(APPEND _inc_env "${ENV_LAPACKE_DIR}")
        list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include")
        list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include/lapacke")
        list(APPEND _inc_env "${ENV_LAPACKE_DIR}/include/mkl")
      else()
        if(WIN32)
          string(REPLACE ":" ";" _inc_env "$ENV{INCLUDE}")
        else()
          string(REPLACE ":" ";" _path_env "$ENV{INCLUDE}")
          list(APPEND _inc_env "${_path_env}")
          string(REPLACE ":" ";" _path_env "$ENV{C_INCLUDE_PATH}")
          list(APPEND _inc_env "${_path_env}")
          string(REPLACE ":" ";" _path_env "$ENV{CPATH}")
          list(APPEND _inc_env "${_path_env}")
          string(REPLACE ":" ";" _path_env "$ENV{INCLUDE_PATH}")
          list(APPEND _inc_env "${_path_env}")
        endif()
      endif()
      list(APPEND _inc_env "${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")
      list(REMOVE_DUPLICATES _inc_env)


      # Try to find the lapacke header in the given paths
      # -------------------------------------------------

      if (LAPACKE_LIBRARIES MATCHES "libmkl")
        set(LAPACKE_hdrs_to_find "mkl.h")
      else()
        set(LAPACKE_hdrs_to_find "lapacke.h")
      endif()

      # call cmake macro to find the header path
      if(LAPACKE_INCDIR)
        set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
        find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
          NAMES ${LAPACKE_hdrs_to_find}
          HINTS ${LAPACKE_INCDIR}
          NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
      else()
        if(LAPACKE_DIR)
          set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
          find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
            NAMES ${LAPACKE_hdrs_to_find}
            HINTS ${LAPACKE_DIR}
            PATH_SUFFIXES "include" "include/lapacke" "include/mkl"
            NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
        else()
          set(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS "LAPACKE_${LAPACKE_hdrs_to_find}_DIRS-NOTFOUND")
          find_path(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS
            NAMES ${LAPACKE_hdrs_to_find}
            HINTS ${_inc_env})
        endif()
      endif()
      mark_as_advanced(LAPACKE_${LAPACKE_hdrs_to_find}_DIRS)

      # If found, add path to cmake variable
      # ------------------------------------
      if (LAPACKE_${LAPACKE_hdrs_to_find}_DIRS)
        set(LAPACKE_INCLUDE_DIRS "${LAPACKE_${LAPACKE_hdrs_to_find}_DIRS}")
      else ()
        set(LAPACKE_INCLUDE_DIRS "LAPACKE_INCLUDE_DIRS-NOTFOUND")
        if(NOT LAPACKE_FIND_QUIETLY)
          message(STATUS "Looking for lapacke -- ${LAPACKE_hdrs_to_find} not found")
        endif()
      endif()


      # Looking for lib
      # ---------------

      # Add system library paths to search lib
      # --------------------------------------
      unset(_lib_env)
      set(ENV_LAPACKE_LIBDIR "$ENV{LAPACKE_LIBDIR}")
      if(ENV_LAPACKE_LIBDIR)
        list(APPEND _lib_env "${ENV_LAPACKE_LIBDIR}")
      elseif(ENV_LAPACKE_DIR)
        list(APPEND _lib_env "${ENV_LAPACKE_DIR}")
        list(APPEND _lib_env "${ENV_LAPACKE_DIR}/lib")
      else()
        list(APPEND _lib_env "$ENV{LIBRARY_PATH}")
        if(WIN32)
          string(REPLACE ":" ";" _lib_env2 "$ENV{LIB}")
        elseif(APPLE)
          string(REPLACE ":" ";" _lib_env2 "$ENV{DYLD_LIBRARY_PATH}")
        else()
          string(REPLACE ":" ";" _lib_env2 "$ENV{LD_LIBRARY_PATH}")
        endif()
        list(APPEND _lib_env "${_lib_env2}")
        list(APPEND _lib_env "${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")
      endif()
      list(REMOVE_DUPLICATES _lib_env)

      # Try to find the lapacke lib in the given paths
      # ----------------------------------------------

      if (LAPACKE_STATIC)
        set (CMAKE_FIND_LIBRARY_SUFFIXES_COPY ${CMAKE_FIND_LIBRARY_SUFFIXES})
        set (CMAKE_FIND_LIBRARY_SUFFIXES ".a")
      endif()

      # call cmake macro to find the lib path
      if(LAPACKE_LIBDIR)
        set(LAPACKE_lapacke_LIBRARY "LAPACKE_lapacke_LIBRARY-NOTFOUND")
        find_library(LAPACKE_lapacke_LIBRARY
          NAMES lapacke
          HINTS ${LAPACKE_LIBDIR}
          NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
      else()
        if(LAPACKE_DIR)
          set(LAPACKE_lapacke_LIBRARY "LAPACKE_lapacke_LIBRARY-NOTFOUND")
          find_library(LAPACKE_lapacke_LIBRARY
            NAMES lapacke
            HINTS ${LAPACKE_DIR}
            PATH_SUFFIXES lib lib32 lib64
            NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_FIND_ROOT_PATH)
        else()
          set(LAPACKE_lapacke_LIBRARY "LAPACKE_lapacke_LIBRARY-NOTFOUND")
          find_library(LAPACKE_lapacke_LIBRARY
            NAMES lapacke
            HINTS ${_lib_env})
        endif()
      endif()
      mark_as_advanced(LAPACKE_lapacke_LIBRARY)

      if (LAPACKE_STATIC)
        set (CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_COPY})
      endif()

      # If found, add path to cmake variable
      # ------------------------------------
      if (LAPACKE_lapacke_LIBRARY)
        get_filename_component(lapacke_lib_path "${LAPACKE_lapacke_LIBRARY}" PATH)
        # set cmake variables
        set(LAPACKE_LIBRARIES    "${LAPACKE_lapacke_LIBRARY}")
        set(LAPACKE_LIBRARY_DIRS "${lapacke_lib_path}")
      else ()
        set(LAPACKE_LIBRARIES    "LAPACKE_LIBRARIES-NOTFOUND")
        set(LAPACKE_LIBRARY_DIRS "LAPACKE_LIBRARY_DIRS-NOTFOUND")
        if (NOT LAPACKE_FIND_QUIETLY)
          message(STATUS "Looking for lapacke -- lib lapacke not found")
        endif()
      endif ()

    endif (NOT LAPACKE_FOUND_WITH_PKGCONFIG OR LAPACKE_GIVEN_BY_USER)

  endif (LAPACKE_STANDALONE OR NOT LAPACKE_WORKS)

  # check a function to validate the find
  if(LAPACKE_LIBRARIES)

    # check if static or dynamic lib
    morse_check_static_or_dynamic(LAPACKE LAPACKE_LIBRARIES)
    if(LAPACKE_STATIC)
      set(STATIC "_STATIC")
    endif()

    if (LAPACKE_FOUND_WITH_PKGCONFIG)
      # set required libraries for link
      morse_set_required_test_lib_link(LAPACKE)
    else()
      set(REQUIRED_INCDIRS)
      set(REQUIRED_LIBDIRS)
      set(REQUIRED_LIBS)
      set(REQUIRED_FLAGS)
      set(REQUIRED_LDFLAGS)

      # LAPACKE
      if (LAPACKE_INCLUDE_DIRS)
        set(REQUIRED_INCDIRS "${LAPACKE_INCLUDE_DIRS}")
      endif()
      if (LAPACKE_CFLAGS_OTHER)
        list(APPEND REQUIRED_FLAGS "${LAPACKE_CFLAGS_OTHER}")
      endif()
      if (LAPACKE_LDFLAGS_OTHER)
        list(APPEND REQUIRED_LDFLAGS "${LAPACKE_LDFLAGS_OTHER}")
      endif()
      if (LAPACKE_LIBRARY_DIRS)
        set(REQUIRED_LIBDIRS "${LAPACKE_LIBRARY_DIRS}")
      endif()
      set(REQUIRED_LIBS "${LAPACKE_LIBRARIES}")
      # TMG
      if (LAPACKE_WITH_TMG)
        if (TMG_INCLUDE_DIRS)
          list(APPEND REQUIRED_INCDIRS "${TMG_INCLUDE_DIRS}")
        endif()
        if (TMG_CFLAGS_OTHER)
          list(APPEND REQUIRED_FLAGS "${TMG_CFLAGS_OTHER}")
        endif()
        if (TMG_LDFLAGS_OTHER)
          list(APPEND REQUIRED_LDFLAGS "${TMG_LDFLAGS_OTHER}")
        endif()
        if (TMG_LIBRARY_DIRS)
          list(APPEND REQUIRED_LIBDIRS "${TMG_LIBRARY_DIRS}")
        endif()
        list(APPEND REQUIRED_LIBS "${TMG_LIBRARIES}")
      endif()
      # LAPACK
      if (LAPACK_INCLUDE_DIRS)
        list(APPEND REQUIRED_INCDIRS "${LAPACK_INCLUDE_DIRS}")
      endif()
      if (LAPACK_CFLAGS_OTHER)
        list(APPEND REQUIRED_FLAGS "${LAPACK_CFLAGS_OTHER}")
      endif()
      if (LAPACK_LDFLAGS_OTHER)
        list(APPEND REQUIRED_LDFLAGS "${LAPACK_LDFLAGS_OTHER}")
      endif()
      if (LAPACK_LIBRARY_DIRS)
        list(APPEND REQUIRED_LIBDIRS "${LAPACK_LIBRARY_DIRS}")
      endif()
      list(APPEND REQUIRED_LIBS "${LAPACK_LIBRARIES}")
      # m
      find_library(M_LIBRARY NAMES m HINTS ${_lib_env})
      mark_as_advanced(M_LIBRARY)
      if(M_LIBRARY)
        list(APPEND REQUIRED_LIBS "${M_LIBRARY}")
      endif()
      # set required libraries for link
      set(CMAKE_REQUIRED_INCLUDES "${REQUIRED_INCDIRS}")
      if (REQUIRED_FLAGS)
        set(REQUIRED_FLAGS_COPY "${REQUIRED_FLAGS}")
        set(REQUIRED_FLAGS)
        set(REQUIRED_DEFINITIONS)
        foreach(_flag ${REQUIRED_FLAGS_COPY})
          if (_flag MATCHES "^-D")
            list(APPEND REQUIRED_DEFINITIONS "${_flag}")
          endif()
          string(REGEX REPLACE "^-D.*" "" _flag "${_flag}")
          list(APPEND REQUIRED_FLAGS "${_flag}")
        endforeach()
      endif()
      morse_finds_remove_duplicates()
      set(CMAKE_REQUIRED_DEFINITIONS "${REQUIRED_DEFINITIONS}")
      set(CMAKE_REQUIRED_FLAGS "${REQUIRED_FLAGS}")
      set(CMAKE_REQUIRED_LIBRARIES)
      list(APPEND CMAKE_REQUIRED_LIBRARIES "${REQUIRED_LDFLAGS}")
      list(APPEND CMAKE_REQUIRED_LIBRARIES "${REQUIRED_LIBS}")
      string(REGEX REPLACE "^ -" "-" CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES}")
    endif()

    # test link
    unset(LAPACKE_WORKS CACHE)
    include(CheckFunctionExists)
    check_function_exists(LAPACKE_dgeqrf LAPACKE_WORKS)
    if(NOT LAPACKE_WORKS AND NOT LAPACKE_FIND_QUIETLY)
      message(STATUS "Looking for lapacke: test of LAPACKE_dgeqrf with lapacke and lapack libraries fails")
    endif()
    if (LAPACKE_WORKS AND LAPACKE_WITH_TMG)
      unset(LAPACKE_WORKS CACHE)
      check_function_exists(LAPACKE_dlatms_work LAPACKE_WORKS)
      if(NOT LAPACKE_WORKS AND NOT LAPACKE_FIND_QUIETLY)
        message(STATUS "Looking for lapacke tmg interface : test of LAPACKE_dlatms_work with lapacke and lapack libraries fails")
      endif()
    endif()
    mark_as_advanced(LAPACKE_WORKS)
    unset(LAPACKE_WITH_LASCL CACHE)
    check_function_exists(LAPACKE_dlascl_work LAPACKE_WITH_LASCL)
    mark_as_advanced(LAPACKE_WITH_LASCL)

    if(LAPACKE_WORKS)
      if (LAPACKE_FOUND_WITH_PKGCONFIG)
        if (LAPACKE_STATIC OR CBLAS_STATIC OR BLA_STATIC)
          # save link with dependencies
          set(LAPACKE_LIBRARIES "${LAPACKE_STATIC_LIBRARIES}")
        endif()
      else()
        set(LAPACKE_LIBRARY_DIRS "${REQUIRED_LIBDIRS}")
        set(LAPACKE_INCLUDE_DIRS "${REQUIRED_INCDIRS}")
        set(LAPACKE_CFLAGS_OTHER "${REQUIRED_FLAGS}")
        set(LAPACKE_LDFLAGS_OTHER "${REQUIRED_LDFLAGS}")
        if (LAPACKE_STATIC OR CBLAS_STATIC OR BLA_STATIC)
          # save link with dependencies
          set(LAPACKE_LIBRARIES "${REQUIRED_LIBS}")
        endif()
      endif()
    else()
      if(NOT LAPACKE_FIND_QUIETLY)
        message(STATUS "CMAKE_REQUIRED_LIBRARIES: ${CMAKE_REQUIRED_LIBRARIES}")
        message(STATUS "CMAKE_REQUIRED_INCLUDES: ${CMAKE_REQUIRED_INCLUDES}")
        message(STATUS "CMAKE_REQUIRED_FLAGS: ${CMAKE_REQUIRED_FLAGS}")
        message(STATUS "Check in CMakeFiles/CMakeError.log to figure out why it fails")
      endif()
    endif()
    set(CMAKE_REQUIRED_INCLUDES)
    set(CMAKE_REQUIRED_FLAGS)
    set(CMAKE_REQUIRED_LIBRARIES)

    list(GET LAPACKE_LIBRARIES 0 first_lib)
    get_filename_component(first_lib_path "${first_lib}" DIRECTORY)
    if (NOT LAPACKE_LIBRARY_DIRS)
      set(LAPACKE_LIBRARY_DIRS "${first_lib_path}")
    endif()
    if (NOT LAPACKE_PREFIX)
      if (${first_lib_path} MATCHES "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)")
        string(REGEX REPLACE "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)" "" not_cached_dir "${first_lib_path}")
        set(LAPACKE_PREFIX "${not_cached_dir}" CACHE PATH "Installation directory of LAPACKE library" FORCE)
      else()
        set(LAPACKE_PREFIX "${first_lib_path}" CACHE PATH "Installation directory of LAPACKE library" FORCE)
      endif()
    endif (NOT LAPACKE_PREFIX)
    if (NOT LAPACKE_INCLUDE_DIRS)
      if (EXISTS "${LAPACKE_PREFIX}/include")
        set(LAPACKE_INCLUDE_DIRS "${LAPACKE_PREFIX}/include")
      endif()
    endif()
    mark_as_advanced(LAPACKE_DIR)
    mark_as_advanced(LAPACKE_PREFIX)

  endif(LAPACKE_LIBRARIES)

else(LAPACKEXT_FOUND)

  if (NOT LAPACKE_FIND_QUIETLY)
    message(STATUS "LAPACKE requires LAPACK but LAPACK has not been found."
      "Please look for LAPACK first.")
  endif()

endif(LAPACKEXT_FOUND)

if(LAPACKE_MT)
  if (LAPACKE_LIBRARIES MATCHES "libmkl" AND LAPACK_MT_LIBRARIES)
    set(LAPACKE_LIBRARIES "${LAPACK_MT_LIBRARIES}")
  else()
    set(LAPACKE_LIBRARIES "LAPACKE_LIBRARIES-NOTFOUND")
  endif()
else()
  if (LAPACKE_LIBRARIES MATCHES "libmkl" AND LAPACK_SEQ_LIBRARIES)
    set(LAPACKE_LIBRARIES "${LAPACK_SEQ_LIBRARIES}")
  endif()
endif()

# check that LAPACKE has been found
# ---------------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LAPACKE DEFAULT_MSG
  LAPACKE_LIBRARIES
  LAPACKE_WORKS)

# Add imported target
if (LAPACKE_FOUND)
  morse_create_imported_target(LAPACKE)
endif()
