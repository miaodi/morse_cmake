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
# - Find TMG include dirs and libraries
# Use this module by invoking find_package with the form:
#  find_package(TMG
#               [REQUIRED]             # Fail with error if tmg is not found
#              )
#
# This module finds headers and tmg library.
# Results are reported in variables:
#  TMG_FOUND             - True if headers and requested libraries were found
#  TMG_PREFIX            - installation path of the lib found
#  TMG_CFLAGS_OTHER      - tmglib compiler flags without headers paths
#  TMG_LDFLAGS_OTHER     - tmglib linker flags without libraries
#  TMG_INCLUDE_DIRS      - tmglib include directories
#  TMG_LIBRARY_DIRS      - tmglib link directories
#  TMG_LIBRARIES         - tmglib libraries to be linked (absolute path)
#
# Set TMG_STATIC to 1 to force using static libraries if exist.
# Set TMG_MT to 1 to force using multi-threaded blas/lapack libraries if exist (Intel MKL).
#
# This module defines the following :prop_tgt:`IMPORTED` target:
#
# ``MORSE::TMG``
#   The headers and libraries to use for TMG, if found.
#
# The user can give specific paths where to find the libraries adding cmake
# options at configure (ex: cmake path/to/project -DTMG=path/to/tmg):
#  TMG_DIR              - Where to find the base directory of tmg
#  TMG_INCDIR           - Where to find the header files
#  TMG_LIBDIR           - Where to find the library files
# The module can also look for the following environment variables if paths
# are not given as cmake variable: TMG_DIR, TMG_INCDIR, TMG_LIBDIR

#=============================================================================

# Common macros to use in finds
include(FindMorseInit)

# Set variables from environment if needed
# ----------------------------------------
morse_find_package_get_envdir(TMG)

# used to test a TMG function after
get_property(_LANGUAGES_ GLOBAL PROPERTY ENABLED_LANGUAGES)
if (NOT _LANGUAGES_ MATCHES Fortran)
  include(CheckFunctionExists)
else (NOT _LANGUAGES_ MATCHES Fortran)
  include(CheckFortranFunctionExists)
endif (NOT _LANGUAGES_ MATCHES Fortran)

# TMG depends on LAPACK anyway, try to find it
if(TMG_FIND_REQUIRED)
  find_package(LAPACKEXT QUIET REQUIRED)
else()
  find_package(LAPACKEXT QUIET)
endif()

# TMG depends on LAPACK
if (LAPACK_FOUND)

  # check if a tmg function exists in the LAPACK lib
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
  include(CheckFunctionExists)
  include(CheckFortranFunctionExists)
  unset(TMG_WORKS CACHE)
  if (NOT _LANGUAGES_ MATCHES Fortran)
    check_function_exists(dlarnv TMG_WORKS)
  else (NOT _LANGUAGES_ MATCHES Fortran)
    check_fortran_function_exists(dlarnv TMG_WORKS)
  endif (NOT _LANGUAGES_ MATCHES Fortran)
  if (TMG_WORKS)
    unset(TMG_WORKS CACHE)
    if (NOT _LANGUAGES_ MATCHES Fortran)
      check_function_exists(dlagsy TMG_WORKS)
    else (NOT _LANGUAGES_ MATCHES Fortran)
      check_fortran_function_exists(dlagsy TMG_WORKS)
    endif (NOT _LANGUAGES_ MATCHES Fortran)
    mark_as_advanced(TMG_WORKS)
  endif()

  if(TMG_WORKS)

    if(NOT TMG_FIND_QUIETLY)
      message(STATUS "Looking for tmg: test with lapack succeeds")
    endif()
    # test succeeds: TMG is in LAPACK
    set(TMG_LIBRARIES "${LAPACK_LIBRARIES}")

  else()

    if(NOT TMG_FIND_QUIETLY)
      message(STATUS "Looking for tmg : test with lapack fails")
      message(STATUS "Looking for tmg : try to find it elsewhere")
    endif()
    # test fails: try to find TMG lib exterior to LAPACK

    # No include, let's set the the include_dir
    set(TMG_INCLUDE_DIRS "")

    # Looking for lib tmg
    # -------------------
    morse_find_library(TMG
      LIBRARIES tmglib tmg
      SUFFIXES  lib lib32 lib64
      OPTIONAL )

    # If found, add path to cmake variable
    # ------------------------------------
    if ((NOT TMG_tmglib_LIBRARY) AND (NOT TMG_tmg_LIBRARY))
      set(TMG_LIBRARIES    "TMG_LIBRARIES-NOTFOUND")
      set(TMG_LIBRARY_DIRS "TMG_LIBRARY_DIRS-NOTFOUND")
      if(NOT TMG_FIND_QUIETLY)
        message(STATUS "Looking for tmg -- lib tmg not found")
      endif()
    endif ()

  endif(TMG_WORKS)

  # check a function to validate the find
  if(TMG_LIBRARIES)

    # check if static or dynamic lib
    morse_check_static_or_dynamic(TMG TMG_LIBRARIES)
    if(TMG_STATIC)
      set(STATIC "_STATIC")
    endif()

    set(REQUIRED_INCDIRS)
    set(REQUIRED_LIBDIRS)
    set(REQUIRED_LIBS)
    set(REQUIRED_FLAGS)
    set(REQUIRED_LDFLAGS)

    # TMG
    if (TMG_INCLUDE_DIRS)
      set(REQUIRED_INCDIRS "${TMG_INCLUDE_DIRS}")
    endif()
    if (TMG_CFLAGS_OTHER)
      list(APPEND REQUIRED_FLAGS "${TMG_CFLAGS_OTHER}")
    endif()
    if (TMG_LDFLAGS_OTHER)
      list(APPEND REQUIRED_LDFLAGS "${TMG_LDFLAGS_OTHER}")
    endif()
    if (TMG_LIBRARY_DIRS)
      set(REQUIRED_LIBDIRS "${TMG_LIBRARY_DIRS}")
    endif()
    set(REQUIRED_LIBS "${TMG_LIBRARIES}")
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
    unset(TMG_WORKS CACHE)
    include(CheckFunctionExists)
    include(CheckFortranFunctionExists)
    if (NOT _LANGUAGES_ MATCHES Fortran)
      check_function_exists(dlarnv TMG_WORKS)
    else (NOT _LANGUAGES_ MATCHES Fortran)
      check_fortran_function_exists(dlarnv TMG_WORKS)
    endif (NOT _LANGUAGES_ MATCHES Fortran)
    if (TMG_WORKS)
      unset(TMG_WORKS CACHE)
      if (NOT _LANGUAGES_ MATCHES Fortran)
        check_function_exists(dlagsy TMG_WORKS)
      else (NOT _LANGUAGES_ MATCHES Fortran)
        check_fortran_function_exists(dlagsy TMG_WORKS)
      endif (NOT _LANGUAGES_ MATCHES Fortran)
      mark_as_advanced(TMG_WORKS)
    endif()

    if(TMG_WORKS)
      set(TMG_LIBRARY_DIRS "${REQUIRED_LIBDIRS}")
      set(TMG_INCLUDE_DIRS "${REQUIRED_INCDIRS}")
      set(TMG_CFLAGS_OTHER "${REQUIRED_FLAGS}")
      set(TMG_LDFLAGS_OTHER "${REQUIRED_LDFLAGS}")
      if (TMG_STATIC OR BLA_STATIC)
        # save link with dependencies
        set(TMG_LIBRARIES "${REQUIRED_LIBS}")
      endif()
    else()
      if(NOT TMG_FIND_QUIETLY)
        message(STATUS "Looking for tmg: test of dlarnv and dlagsy with tmg and lapack libraries fails")
        message(STATUS "CMAKE_REQUIRED_LIBRARIES: ${CMAKE_REQUIRED_LIBRARIES}")
        message(STATUS "CMAKE_REQUIRED_INCLUDES: ${CMAKE_REQUIRED_INCLUDES}")
        message(STATUS "CMAKE_REQUIRED_FLAGS: ${CMAKE_REQUIRED_FLAGS}")
        message(STATUS "Check in CMakeFiles/CMakeError.log to figure out why it fails")
      endif()
    endif()
    set(CMAKE_REQUIRED_INCLUDES)
    set(CMAKE_REQUIRED_FLAGS)
    set(CMAKE_REQUIRED_LIBRARIES)

    list(GET TMG_LIBRARIES 0 first_lib)
    get_filename_component(first_lib_path "${first_lib}" DIRECTORY)
    if (NOT TMG_LIBRARY_DIRS)
      set(TMG_LIBRARY_DIRS "${first_lib_path}")
    endif()
    if (${first_lib_path} MATCHES "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)")
      string(REGEX REPLACE "(/lib(32|64)?$)|(/lib/intel64$|/lib/ia32$)" "" not_cached_dir "${first_lib_path}")
      set(TMG_PREFIX "${not_cached_dir}" CACHE PATH "Installation directory of TMG library" FORCE)
    else()
      set(TMG_PREFIX "${first_lib_path}" CACHE PATH "Installation directory of TMG library" FORCE)
    endif()
    mark_as_advanced(TMG_DIR)
    mark_as_advanced(TMG_PREFIX)

  endif(TMG_LIBRARIES)

else()

  if(NOT TMG_FIND_QUIETLY)
    message(STATUS "TMG requires LAPACK but LAPACK has not been found."
      "Please look for LAPACK first.")
  endif()

endif()

if(TMG_MT)
  if (TMG_LIBRARIES MATCHES "libmkl" AND LAPACK_MT_LIBRARIES)
    set(TMG_LIBRARIES "${LAPACK_MT_LIBRARIES}")
  else()
    set(TMG_LIBRARIES "LAPACKE_LIBRARIES-NOTFOUND")
  endif()
else()
  if (TMG_LIBRARIES MATCHES "libmkl" AND LAPACK_SEQ_LIBRARIES)
    set(TMG_LIBRARIES "${LAPACK_SEQ_LIBRARIES}")
  endif()
endif()

# check that TMG has been found
# -------------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TMG DEFAULT_MSG
  TMG_LIBRARIES
  TMG_WORKS)

# Add imported target
if (TMG_FOUND)
  morse_create_imported_target(TMG)
endif()
