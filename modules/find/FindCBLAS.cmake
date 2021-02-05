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
# - Find CBLAS include dirs and libraries
# Use this module by invoking find_package with the form:
#  find_package(CBLAS
#               [REQUIRED] # Fail with error if cblas is not found
#               [COMPONENTS <comp1> <comp2> ...] # dependencies
#              )
#
#  CBLAS depends on the following libraries:
#   - BLAS
#
#  CBLAS_HAS_ZGEMM3M       - True if cblas contains zgemm3m fast complex mat-mat product
#
#  CBLAS_FOUND_WITH_PKGCONFIG - True if found with pkg-config
#  if found the following variables are set
#  CBLAS_PREFIX            - installation path of the lib found
#  <PREFIX>  = CBLAS
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
# Set CBLAS_STATIC to 1 to force using static libraries if exist.
# Set CBLAS_MT to 1 to force using multi-threaded blas libraries if exist (Intel MKL).
#
# This module defines the following :prop_tgt:`IMPORTED` target:
#
# ``MORSE::CBLAS``
#   The headers and libraries to use for CBLAS, if found.
#
# The user can give specific paths where to find the libraries adding cmake
# options at configure (ex: cmake path/to/project -DCBLAS_DIR=path/to/cblas):
#  CBLAS_DIR              - Where to find the base directory of cblas
#  CBLAS_INCDIR           - Where to find the header files
#  CBLAS_LIBDIR           - Where to find the library files
# The module can also look for the following environment variables if paths
# are not given as cmake variable: CBLAS_DIR, CBLAS_INCDIR, CBLAS_LIBDIR
#
# CBLAS could be directly embedded in BLAS library (ex: Intel MKL) so that
# we test a cblas function with the blas libraries found and set CBLAS
# variables to BLAS ones if test is successful. To skip this feature and
# look for a stand alone cblas, please set CBLAS_STANDALONE to TRUE
###
# We handle different modes to find the dependency
#
# - Detection if already installed on the system
#   - CBLAS libraries can be detected from different ways
#     Here is the order of precedence:
#     1) we look in cmake variable CBLAS_LIBDIR or CBLAS_DIR (we guess the libdirs) if defined
#     2) we look in environment variable CBLAS_LIBDIR or CBLAS_DIR (we guess the libdirs) if defined
#
#=============================================================================

# Common macros to use in finds
include(FindMorseInit)

# Set variables from environment if needed
# ----------------------------------------
morse_find_package_get_envdir(CBLAS)

# Check if a cblas function exists in the lib, and check if the
# advanced complex gemm functions are available
# -------------------------------------------------------------
#
# _prefix helps to check on BLAS or CBLAS variables
#
macro(check_cblas_library _prefix)
  set(CMAKE_REQUIRED_LIBRARIES)
  if (${_prefix}_LIBRARIES)
    set(CMAKE_REQUIRED_LIBRARIES "${${_prefix}_LIBRARIES}")
  endif()
  if (${_prefix}_LDFLAGS_OTHER)
    list(APPEND CMAKE_REQUIRED_LIBRARIES "${${_prefix}_LDFLAGS_OTHER}")
  endif()
  if (${_prefix}_LINKER_FLAGS)
    list(APPEND CMAKE_REQUIRED_LIBRARIES "${${_prefix}_LINKER_FLAGS}")
  endif()
  if (${_prefix}_CFLAGS_OTHER)
    set(CMAKE_REQUIRED_FLAGS "${${_prefix}_CFLAGS_OTHER}")
  endif()
  if (${_prefix}_INCLUDE_DIRS)
    set(CMAKE_REQUIRED_INCLUDES "${C${_prefix}_INCLUDE_DIRS}")
  endif()
  unset(CBLAS_WORKS CACHE)
  check_function_exists(cblas_dscal   CBLAS_WORKS)
  check_function_exists(cblas_zgemm3m CBLAS_ZGEMM3M_FOUND)
  check_function_exists(cblas_cgemm3m CBLAS_CGEMM3M_FOUND)
  mark_as_advanced(CBLAS_WORKS)
  set(CMAKE_REQUIRED_LIBRARIES)
endmacro()

# Look  for the cblas header files
# ---------------------------------
macro(check_cblas_include)
  if ( CBLAS_INCLUDE_DIRS )
    return()
  endif()

  # Try to find the cblas header in the given paths
  # -------------------------------------------------
  if (CBLAS_LIBRARIES MATCHES "libmkl")
    set(CBLAS_hdrs_to_find "mkl.h")
  else()
    set(CBLAS_hdrs_to_find "cblas.h")
  endif()

  # call cmake macro to find the header path
  # ----------------------------------------
  morse_find_path(CBLAS
    HEADERS  ${CBLAS_hdrs_to_find}
    SUFFIXES "include" "include/cblas")

endmacro()

# CBLAS depends on BLAS anyway, try to find it
if(CBLAS_FIND_REQUIRED)
  find_package(BLASEXT QUIET REQUIRED)
else()
  find_package(BLASEXT QUIET)
endif()

# find CBLAS
if (BLASEXT_FOUND)

  if (NOT CBLAS_STANDALONE)
    # Check if the blas library includes cblas
    check_cblas_library(BLAS)

    # Blas lib includes cblas
    if(CBLAS_WORKS)

      # # Check for faster complex GEMM routine
      # # (only C/Z, no S/D version)
      # if ( CBLAS_ZGEMM3M_FOUND )
      #   add_definitions(-DCBLAS_HAS_ZGEMM3M -DCBLAS_HAS_CGEMM3M)
      # endif()

      if(NOT CBLAS_FIND_QUIETLY)
        message(STATUS "Looking for cblas: test with blas succeeds")
      endif()
      # test succeeds: CBLAS is in BLAS
      if (BLAS_LIBRARIES)
        set(CBLAS_LIBRARIES "${BLAS_LIBRARIES}")
      endif()
      if (BLAS_LINKER_FLAGS)
        list(APPEND CBLAS_LIBRARIES "${BLAS_LINKER_FLAGS}")
      endif()
      if (BLAS_INCLUDE_DIRS)
        set(CBLAS_INCLUDE_DIRS "${BLAS_INCLUDE_DIRS}")
      endif()
      if (BLAS_LIBRARY_DIRS)
        set(CBLAS_LIBRARY_DIRS "${BLAS_LIBRARY_DIRS}")
      endif()
      if (BLAS_CFLAGS_OTHER)
        set(CBLAS_CFLAGS_OTHER "${BLAS_CFLAGS_OTHER}")
      endif()
      if (BLAS_LDFLAGS_OTHER)
        set(CBLAS_LDFLAGS_OTHER "${BLAS_LDFLAGS_OTHER}")
      endif()

      # Set the mkl library dirs for compatibility with former version
      # --------------------------------------------------------------
      if (CBLAS_LIBRARIES MATCHES "libmkl" AND DEFINED ENV{MKLROOT})
        set(CBLAS_PREFIX "$ENV{MKLROOT}" CACHE PATH "Installation directory of CBLAS library" FORCE)
        set(CBLAS_LIBRARY_DIRS "${CBLAS_PREFIX}/lib/intel64")
      endif()

      check_cblas_include()

    endif()

  endif (NOT CBLAS_STANDALONE)

  # test fails with blas: try to find CBLAS lib exterior to BLAS
  if (CBLAS_STANDALONE OR NOT CBLAS_WORKS)

    if(NOT CBLAS_WORKS AND NOT CBLAS_FIND_QUIETLY)
      message(STATUS "Looking for cblas : test with blas fails or CBLAS_STANDALONE enabled")
    endif()

    # try with pkg-config
    set(ENV_MKLROOT "$ENV{MKLROOT}")
    set(CBLAS_GIVEN_BY_USER "FALSE")
    if ( CBLAS_DIR OR ( CBLAS_INCDIR AND CBLAS_LIBDIR ) OR ( ENV_MKLROOT ) )
      set(CBLAS_GIVEN_BY_USER "TRUE")
    endif()

    find_package(PkgConfig QUIET)
    if( PKG_CONFIG_EXECUTABLE AND (NOT (CBLAS_GIVEN_BY_USER)))

      if (BLA_STATIC)
        set(MKL_STR_BLA_STATIC "static")
      else()
        set(MKL_STR_BLA_STATIC "dynamic")
      endif()
      # try different blas
      if (BLA_VENDOR STREQUAL "Intel10_64lp")
        pkg_search_module(CBLAS mkl-${MKL_STR_BLA_STATIC}-lp64-iomp)
      elseif(BLA_VENDOR STREQUAL "Intel10_64lp_seq")
        pkg_search_module(CBLAS mkl-${MKL_STR_BLA_STATIC}-lp64-seq)
      elseif(BLA_VENDOR STREQUAL "OpenBLAS")
        pkg_search_module(CBLAS openblas)
      elseif(BLA_VENDOR STREQUAL "Generic")
        pkg_search_module(CBLAS cblas)
      else()
        pkg_search_module(CBLAS cblas)
        pkg_search_module(CBLAS openblas)
        pkg_search_module(CBLAS mkl-${MKL_STR_BLA_STATIC}-lp64-seq)
      endif()

      if (NOT CBLAS_FIND_QUIETLY)
        if (CBLAS_FOUND AND CBLAS_LIBRARIES)
          message(STATUS "Looking for CBLAS - found using PkgConfig")
        else()
          message(STATUS "${Magenta}Looking for CBLAS - not found using PkgConfig."
            "\n   Perhaps you should add the directory containing cblas.pc to"
            "\n   the PKG_CONFIG_PATH environment variable.${ColourReset}")
        endif()
      endif()

      if (CBLAS_FOUND AND CBLAS_LIBRARIES)
        set(CBLAS_FOUND_WITH_PKGCONFIG "TRUE")
        morse_find_pkgconfig_libraries_absolute_path(CBLAS)
      else()
        set(CBLAS_FOUND_WITH_PKGCONFIG "FALSE")
      endif()

      if (CBLAS_STATIC AND CBLAS_STATIC_LIBRARIES)
        set (CBLAS_DEPENDENCIES ${CBLAS_STATIC_LIBRARIES})
        list (REMOVE_ITEM CBLAS_DEPENDENCIES "cblas")
        list (APPEND CBLAS_LIBRARIES ${CBLAS_DEPENDENCIES})
        set(CBLAS_CFLAGS_OTHER ${CBLAS_STATIC_CFLAGS_OTHER})
        set(CBLAS_LDFLAGS_OTHER ${CBLAS_STATIC_LDFLAGS_OTHER})
            if (NOT CBLAS_FIND_QUIETLY)
          message(STATUS "CBLAS_STATIC set to 1 by user, CBLAS_LIBRARIES: ${CBLAS_LIBRARIES}.")
        endif()
      endif()
    endif()

    if (NOT CBLAS_FOUND_WITH_PKGCONFIG OR CBLAS_GIVEN_BY_USER)
      # Try to find CBLAS lib
      #######################

      # Looking for include
      # -------------------
      check_cblas_include()

      # Looking for lib
      # ---------------
      morse_find_library(CBLAS
        LIBRARIES cblas
        SUFFIXES lib lib32 lib64)

    endif (NOT CBLAS_FOUND_WITH_PKGCONFIG OR CBLAS_GIVEN_BY_USER)

  endif (CBLAS_STANDALONE OR NOT CBLAS_WORKS)

  # check a function to validate the find
  if(CBLAS_LIBRARIES)

    # check if static or dynamic lib
    morse_check_static_or_dynamic(CBLAS CBLAS_LIBRARIES)
    if(CBLAS_STATIC)
      set(STATIC "_STATIC")
    endif()

    set(REQUIRED_INCDIRS)
    set(REQUIRED_LIBDIRS)
    set(REQUIRED_LIBS)
    set(REQUIRED_FLAGS)
    set(REQUIRED_LDFLAGS)

    # CBLAS
    if (CBLAS_INCLUDE_DIRS)
      set(REQUIRED_INCDIRS "${CBLAS_INCLUDE_DIRS}")
    endif()
    if (CBLAS_CFLAGS_OTHER)
      set(REQUIRED_FLAGS "${CBLAS_CFLAGS_OTHER}")
    endif()
    if (CBLAS_LDFLAGS_OTHER)
      set(REQUIRED_LDFLAGS "${CBLAS_LDFLAGS_OTHER}")
    endif()
    if (CBLAS_LIBRARY_DIRS)
      set(REQUIRED_LIBDIRS "${CBLAS_LIBRARY_DIRS}")
    endif()
    set(REQUIRED_LIBS "${CBLAS_LIBRARIES}")
    # BLAS
    if (BLAS_INCLUDE_DIRS)
      list(APPEND REQUIRED_INCDIRS "${BLAS_INCLUDE_DIRS}")
    endif()
    if (BLAS_CFLAGS_OTHER)
      list(APPEND REQUIRED_FLAGS "${BLAS_CFLAGS_OTHER}")
    endif()
    if (BLAS_LDFLAGS_OTHER)
      list(APPEND REQUIRED_LDFLAGS "${BLAS_LDFLAGS_OTHER}")
    endif()
    if (BLAS_LIBRARY_DIRS)
      list(APPEND REQUIRED_LIBDIRS "${BLAS_LIBRARY_DIRS}")
    endif()
    list(APPEND REQUIRED_LIBS "${BLAS_LIBRARIES}")

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

    # test link
    unset(CBLAS_WORKS CACHE)
    include(CheckFunctionExists)
    check_function_exists(cblas_dscal CBLAS_WORKS)
    mark_as_advanced(CBLAS_WORKS)

    if(CBLAS_WORKS)

      # Check for faster complex GEMM routine
      # (only C/Z, no S/D version)
      check_function_exists(cblas_zgemm3m CBLAS_ZGEMM3M_FOUND)
      if ( CBLAS_ZGEMM3M_FOUND )
        add_definitions(-DCBLAS_HAS_ZGEMM3M -DCBLAS_HAS_CGEMM3M)
      endif()

      set(CBLAS_LIBRARY_DIRS "${REQUIRED_LIBDIRS}")
      set(CBLAS_INCLUDE_DIRS "${REQUIRED_INCDIRS}")
      set(CBLAS_CFLAGS_OTHER "${REQUIRED_FLAGS}")
      set(CBLAS_LDFLAGS_OTHER "${REQUIRED_LDFLAGS}")
      if (CBLAS_STATIC OR BLA_STATIC)
        # save link with dependencies
        set(CBLAS_LIBRARIES "${REQUIRED_LIBS}")
      endif()
    else()
      if(NOT CBLAS_FIND_QUIETLY)
        message(STATUS "Looking for cblas : test of cblas_dscal with cblas and blas libraries fails")
        message(STATUS "CMAKE_REQUIRED_LIBRARIES: ${CMAKE_REQUIRED_LIBRARIES}")
        message(STATUS "CMAKE_REQUIRED_INCLUDES: ${CMAKE_REQUIRED_INCLUDES}")
        message(STATUS "CMAKE_REQUIRED_FLAGS: ${CMAKE_REQUIRED_FLAGS}")
        message(STATUS "Check in CMakeFiles/CMakeError.log to figure out why it fails")
      endif()
    endif()
    set(CMAKE_REQUIRED_INCLUDES)
    set(CMAKE_REQUIRED_FLAGS)
    set(CMAKE_REQUIRED_LIBRARIES)

    list(GET CBLAS_LIBRARIES 0 first_lib)
    get_filename_component(first_lib_path "${first_lib}" DIRECTORY)
    if (NOT CBLAS_LIBRARY_DIRS)
      set(CBLAS_LIBRARY_DIRS "${first_lib_path}")
    endif()
    if (NOT CBLAS_PREFIX)
      if (${first_lib_path} MATCHES "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)")
        string(REGEX REPLACE "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)" "" not_cached_dir "${first_lib_path}")
        set(CBLAS_PREFIX "${not_cached_dir}" CACHE PATH "Installation directory of CBLAS library" FORCE)
      else()
        set(CBLAS_PREFIX "${first_lib_path}" CACHE PATH "Installation directory of CBLAS library" FORCE)
      endif()
    endif (NOT CBLAS_PREFIX)
    if (NOT CBLAS_INCLUDE_DIRS)
      if (EXISTS "${CBLAS_PREFIX}/include")
        set(CBLAS_INCLUDE_DIRS "${CBLAS_PREFIX}/include")
      endif()
    endif()
    mark_as_advanced(CBLAS_DIR)
    mark_as_advanced(CBLAS_PREFIX)

  endif(CBLAS_LIBRARIES)

else(BLASEXT_FOUND)

  if (NOT CBLAS_FIND_QUIETLY)
    message(STATUS "CBLAS requires BLAS but BLAS has not been found."
      "Please look for BLAS first.")
  endif()

endif(BLASEXT_FOUND)

if(CBLAS_MT)
  if (CBLAS_LIBRARIES MATCHES "libmkl" AND BLAS_MT_LIBRARIES)
    set(CBLAS_LIBRARIES "${BLAS_MT_LIBRARIES}")
  else()
    set(CBLAS_LIBRARIES "CBLAS_LIBRARIES-NOTFOUND")
  endif()
else()
  if (CBLAS_LIBRARIES MATCHES "libmkl" AND BLAS_SEQ_LIBRARIES)
    set(CBLAS_LIBRARIES "${BLAS_SEQ_LIBRARIES}")
  endif()
endif()

# Enable variables to defined advanced complex gemm
# -------------------------------------------------
if ( CBLAS_ZGEMM3M_FOUND )
  set( CBLAS_HAS_ZGEMM3M ON )
  mark_as_advanced( CBLAS_HAS_ZGEMM3M )
endif()

if ( CBLAS_CGEMM3M_FOUND )
  set( CBLAS_HAS_CGEMM3M ON )
  mark_as_advanced( CBLAS_HAS_CGEMM3M )
endif()

# check that CBLAS has been found
# -------------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CBLAS DEFAULT_MSG
  CBLAS_LIBRARIES
  CBLAS_WORKS)

# Add imported target
if (CBLAS_FOUND)
  morse_create_imported_target(CBLAS)
endif()
