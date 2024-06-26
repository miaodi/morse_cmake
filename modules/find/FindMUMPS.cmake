###
#
# @copyright (c) 2013-2020 Inria. All rights reserved.
#
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
# - Find MUMPS include dirs and libraries
# Use this module by invoking find_package with the form:
#  find_package(MUMPS
#               [REQUIRED] # Fail with error if mumps is not found
#               [COMPONENTS <comp1> <comp2> ...] # dependencies
#              )
#
#  MUMPS depends on the following libraries:
#   - Threads
#   - BLAS
#
#  COMPONENTS are optional libraries MUMPS could be linked with,
#  Use it to drive detection of a specific compilation chain
#  COMPONENTS can be some of the following:
#   - MPI: to activate detection of the parallel MPI version (default)
#        it looks for Threads, BLAS, MPI and ScaLAPACK libraries
#   - SEQ: to activate detection of sequential version (exclude MPI version)
#        it looks for Threads and BLAS libraries
#   - SCOTCH: to activate detection of MUMPS linked with SCOTCH
#   - PTSCOTCH: to activate detection of MUMPS linked with PTSCOTCH
#   - METIS: to activate detection of MUMPS linked with METIS
#   - PARMETIS: to activate detection of MUMPS linked with PARMETIS
#   - OPENMP: to activate detection of MUMPS linked with OPENMP
#
# This module finds headers and mumps library.
# Results are reported in variables:
#  MUMPS_FOUND             - True if headers and requested libraries were found
#  MUMPS_CFLAGS_OTHER      - mumps compiler flags without headers paths
#  MUMPS_LDFLAGS_OTHER     - mumps linker flags without libraries
#  MUMPS_INCLUDE_DIRS      - mumps include directories
#  MUMPS_LIBRARY_DIRS      - mumps link directories
#  MUMPS_LIBRARIES         - mumps libraries to be linked (absolute path)
#
# Set MUMPS_STATIC to 1 to force using static libraries if exist.
#
# This module defines the following :prop_tgt:`IMPORTED` target:
#
# ``MORSE::MUMPS``
#   The headers and libraries to use for MUMPS, if found.
#
# The user can give specific paths where to find the libraries adding cmake
# options at configure (ex: cmake path/to/project -DMUMPS_DIR=path/to/mumps):
#  MUMPS_DIR              - Where to find the base directory of mumps
# The module can also look for the following environment variables if paths
# are not given as cmake variable: MUMPS_DIR
#=============================================================================

# Common macros to use in finds
include(FindMorseInit)

# Set variables from environment if needed
# ----------------------------------------
morse_find_package_get_envdir(MUMPS)

# Set the version to find
set(MUMPS_LOOK_FOR_MPI ON)
set(MUMPS_LOOK_FOR_SEQ OFF)
set(MUMPS_LOOK_FOR_SCOTCH OFF)
set(MUMPS_LOOK_FOR_PTSCOTCH OFF)
set(MUMPS_LOOK_FOR_METIS OFF)
set(MUMPS_LOOK_FOR_PARMETIS OFF)
set(MUMPS_LOOK_FOR_OPENMP OFF)

if( MUMPS_FIND_COMPONENTS )
  foreach( component ${MUMPS_FIND_COMPONENTS} )
    if (${component} STREQUAL "SEQ")
      # means we look for the sequential version of MUMPS (without MPI)
      set(MUMPS_LOOK_FOR_SEQ ON)
      set(MUMPS_LOOK_FOR_MPI OFF)
    endif()
    if (${component} STREQUAL "MPI")
      # means we look for the MPI version of MUMPS (default)
      set(MUMPS_LOOK_FOR_MPI ON)
      set(MUMPS_LOOK_FOR_SEQ OFF)
    endif()
    if (${component} STREQUAL "SCOTCH")
      set(MUMPS_LOOK_FOR_SCOTCH ON)
    endif()
    if (${component} STREQUAL "PTSCOTCH")
      set(MUMPS_LOOK_FOR_PTSCOTCH ON)
    endif()
    if (${component} STREQUAL "METIS")
      set(MUMPS_LOOK_FOR_METIS ON)
    endif()
    if (${component} STREQUAL "PARMETIS")
      set(MUMPS_LOOK_FOR_PARMETIS ON)
    endif()
    if (${component} STREQUAL "OPENMP")
      set(MUMPS_LOOK_FOR_OPENMP ON)
    endif()
  endforeach()
endif()

if (NOT MUMPS_FIND_QUIETLY)
  if (MUMPS_LOOK_FOR_SEQ)
    message(STATUS "Looking for MUMPS - sequential version (without MPI)")
  else()
    message(STATUS "Looking for MUMPS - MPI version -"
      " if you want to force detection of a sequential "
      "version use find_package(MUMPS [REQUIRED] COMPONENTS SEQ [...])")
  endif()
endif()

if (NOT MUMPS_FIND_QUIETLY)
  message(STATUS "Looking for MUMPS - PkgConfig not used")
endif()

# Required dependencies
# ---------------------

if (NOT MUMPS_FIND_QUIETLY)
  message(STATUS "Looking for MUMPS - Try to detect pthread")
endif()
if (MUMPS_FIND_REQUIRED)
  find_package(Threads REQUIRED)
else()
  find_package(Threads)
endif()
if( THREADS_FOUND AND NOT THREADS_PREFER_PTHREAD_FLAG )
  libraries_absolute_path(CMAKE_THREAD_LIBS_INIT "")
endif ()
set(MUMPS_EXTRA_LIBRARIES "")
if( THREADS_FOUND AND NOT THREADS_PREFER_PTHREAD_FLAG )
  list(APPEND MUMPS_EXTRA_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
endif ()

# MUMPS depends on BLAS
#----------------------
if (NOT MUMPS_FIND_QUIETLY)
  message(STATUS "Looking for MUMPS - Try to detect BLAS")
endif()
if (MUMPS_FIND_REQUIRED)
  find_package(BLAS REQUIRED)
else()
  find_package(BLAS)
endif()

# Optional dependencies
# ---------------------

# MUMPS may depend on MPI
#------------------------
if (MUMPS_LOOK_FOR_MPI)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect MPI")
  endif()
  # allows to use an external mpi compilation by setting compilers with
  # -DMPI_C_COMPILER=path/to/mpicc -DMPI_Fortran_COMPILER=path/to/mpif90
  # at cmake configure
  if(NOT MPI_C_COMPILER)
    set(MPI_C_COMPILER mpicc)
  endif()
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_MPI)
    find_package(MPI REQUIRED)
  else()
    find_package(MPI)
  endif()
  if (MPI_FOUND)
    mark_as_advanced(MPI_LIBRARY)
    mark_as_advanced(MPI_EXTRA_LIBRARY)
  endif()
endif (MUMPS_LOOK_FOR_MPI)

# MUMPS may depend on ScaLAPACK (if MPI version)
#-----------------------------------------------
if (MUMPS_LOOK_FOR_MPI)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect SCALAPACK")
  endif()
  # SCALAPACK is a required dependency if MPI is used
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_MPI)
    find_package(SCALAPACK REQUIRED)
  else()
    find_package(SCALAPACK)
  endif()
endif (MUMPS_LOOK_FOR_MPI)

# MUMPS may depends on SCOTCH
#----------------------------
if (MUMPS_LOOK_FOR_SCOTCH)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect SCOTCH with esmumps")
  endif()
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_SCOTCH)
    find_package(SCOTCH REQUIRED COMPONENTS ESMUMPS)
  else()
    find_package(SCOTCH COMPONENTS ESMUMPS)
  endif()
endif()

# MUMPS may depends on PTSCOTCH
#------------------------------
if (MUMPS_LOOK_FOR_PTSCOTCH)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect PTSCOTCH with esmumps")
  endif()
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_PTSCOTCH)
    find_package(PTSCOTCH REQUIRED COMPONENTS ESMUMPS)
  else()
    find_package(PTSCOTCH COMPONENTS ESMUMPS)
  endif()
endif()

# MUMPS may depends on METIS
#---------------------------
if (MUMPS_LOOK_FOR_METIS)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect METIS")
  endif()
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_METIS)
    find_package(METIS REQUIRED)
  else()
    find_package(METIS)
  endif()
endif()

# MUMPS may depends on PARMETIS
#------------------------------
if (MUMPS_LOOK_FOR_PARMETIS)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect PARMETIS")
  endif()
  if (MUMPS_FIND_REQUIRED AND MUMPS_FIND_REQUIRED_PARMETIS)
    find_package(PARMETIS REQUIRED)
  else()
    find_package(PARMETIS)
  endif()
endif()

# MUMPS may depends on OPENMP
#------------------------------
if (MUMPS_LOOK_FOR_OPENMP)
  if (NOT MUMPS_FIND_QUIETLY)
    message(STATUS "Looking for MUMPS - Try to detect OPENMP")
  endif()
  if (MUMPS_FIND_REQUIRED)
    find_package(OpenMP REQUIRED)
  else()
    find_package(OpenMP)
  endif()
endif()

# Looking for MUMPS
# -----------------

# Looking for include
# -------------------
morse_find_path( MUMPS
  HEADERS "smumps_c.h;dmumps_c.h;cmumps_c.h;zmumps_c.h"
  SUFFIXES "include"
  OPTIONAL )

# If found, add path to cmake variable
# ------------------------------------
# detect which precisions are available
set(MUMPS_PREC_S OFF)
set(MUMPS_PREC_D OFF)
set(MUMPS_PREC_C OFF)
set(MUMPS_PREC_Z OFF)
if (MUMPS_smumps_c.h_DIRS)
  set(MUMPS_PREC_S ON)
endif()
if (MUMPS_dmumps_c.h_DIRS)
  set(MUMPS_PREC_D ON)
endif()
if (MUMPS_cmumps_c.h_DIRS)
  set(MUMPS_PREC_C ON)
endif()
if (MUMPS_zmumps_c.h_DIRS)
  set(MUMPS_PREC_Z ON)
endif()

# Looking for lib
# ---------------

# create list of libs to find
set(MUMPS_libs_to_find)
if(MUMPS_PREC_S)
  list(APPEND MUMPS_libs_to_find "smumps")
endif()
if(MUMPS_PREC_D)
  list(APPEND MUMPS_libs_to_find "dmumps")
endif()
if(MUMPS_PREC_C)
  list(APPEND MUMPS_libs_to_find "cmumps")
endif()
if(MUMPS_PREC_Z)
  list(APPEND MUMPS_libs_to_find "zmumps")
endif()
list(APPEND MUMPS_libs_to_find "mumps_common;pord")
if (MUMPS_LOOK_FOR_SEQ)
  list(APPEND MUMPS_libs_to_find "mpiseq")
endif()
# Look for libraries as optional and then check each one of them independently
# ----------------------------------------------------------------------------
morse_find_library(MUMPS
  LIBRARIES ${MUMPS_libs_to_find}
  SUFFIXES lib lib32 lib64
  OPTIONAL)

# Update precision discovery
# --------------------------
if (NOT MUMPS_smumps_LIBRARY)
  set(MUMPS_PREC_S OFF)
endif()
if (NOT MUMPS_dmumps_LIBRARY)
  set(MUMPS_PREC_D OFF)
endif()
if (NOT MUMPS_cmumps_LIBRARY)
  set(MUMPS_PREC_C OFF)
endif()
if (NOT MUMPS_zmumps_LIBRARY)
  set(MUMPS_PREC_Z OFF)
endif()

# check that one precision arithmetic at least has been discovered
if ((NOT MUMPS_PREC_S) AND (NOT MUMPS_PREC_D) AND (NOT MUMPS_PREC_C) AND (NOT MUMPS_PREC_S))
  if (MUMPS_FIND_REQUIRED)
    message(FATAL_ERROR "Looking for mumps -- "
      "no lib[sdcz]mumps.a have been found in ${MUMPS_DIR}/lib when required")
  else()
    if(NOT MUMPS_FIND_QUIETLY)
      message(STATUS "Looking for mumps -- no lib[sdcz]mumps.a have been found")
    endif()
  endif()
endif()

# other MUMPS libraries
if (NOT MUMPS_mumps_common_LIBRARY)
  if (MUMPS_FIND_REQUIRED)
    message(FATAL_ERROR "Looking for mumps -- "
      "libmumps_common.a not found in ${MUMPS_DIR}/lib when required")
  else()
    if(NOT MUMPS_FIND_QUIETLY)
      message(STATUS "Looking for mumps -- libmumps_common.a not found")
    endif()
  endif()
endif()
if (MUMPS_mpiseq_LIBRARY)
  if (MUMPS_LOOK_FOR_SEQ)
    get_filename_component(mpiseq_lib_path ${MUMPS_mpiseq_LIBRARY} PATH)
    list(APPEND MUMPS_INCLUDE_DIRS "${mpiseq_lib_path}")
  endif()
else ()
  if (MUMPS_FIND_REQUIRED AND MUMPS_LOOK_FOR_SEQ)
    message(FATAL_ERROR "Looking for mumps -- "
      "libmpiseq.a not found in ${MUMPS_DIR}/libseq when required")
  else()
    if(NOT MUMPS_FIND_QUIETLY)
      message(STATUS "Looking for mumps -- libmpiseq.a not found")
    endif()
  endif()
endif()
if (NOT MUMPS_pord_LIBRARY)
  if (MUMPS_FIND_REQUIRED)
    message(FATAL_ERROR "Looking for mumps -- "
      "libpord.a not found in ${MUMPS_DIR}/lib when required")
  else()
    if(NOT MUMPS_FIND_QUIETLY)
      message(STATUS "Looking for mumps -- libpord.a not found")
    endif()
  endif()
endif()
list(REMOVE_DUPLICATES MUMPS_INCLUDE_DIRS)

# check a function to validate the find
if(MUMPS_LIBRARIES)

  # check if static or dynamic lib
  morse_check_static_or_dynamic(MUMPS MUMPS_LIBRARIES)
  if(MUMPS_STATIC)
    set(STATIC "_STATIC")
  endif()

  set(REQUIRED_INCDIRS)
  set(REQUIRED_LIBDIRS)
  set(REQUIRED_LIBS)
  set(REQUIRED_FLAGS)
  set(REQUIRED_LDFLAGS)

  # MUMPS
  if (MUMPS_INCLUDE_DIRS)
    set(REQUIRED_INCDIRS "${MUMPS_INCLUDE_DIRS}")
  endif()
  if (MUMPS_CFLAGS_OTHER)
    set(REQUIRED_FLAGS "${MUMPS_CFLAGS_OTHER}")
  endif()
  if (MUMPS_LDFLAGS_OTHER)
    set(REQUIRED_LDFLAGS "${MUMPS_LDFLAGS_OTHER}")
  endif()
  if (MUMPS_LIBRARY_DIRS)
    set(REQUIRED_LIBDIRS "${MUMPS_LIBRARY_DIRS}")
  endif()
  set(REQUIRED_LIBS "${MUMPS_LIBRARIES}")
  # SCALAPACK
  if (MUMPS_LOOK_FOR_MPI)
    if (SCALAPACK_FOUND)
      if (SCALAPACK_INCLUDE_DIRS)
        list(APPEND REQUIRED_INCDIRS "${SCALAPACK_INCLUDE_DIRS}")
      endif()
      if (SCALAPACK_CFLAGS_OTHER)
        list(APPEND REQUIRED_FLAGS "${SCALAPACK_CFLAGS_OTHER}")
      endif()
      if (SCALAPACK_LDFLAGS_OTHER)
        list(APPEND REQUIRED_LDFLAGS "${SCALAPACK_LDFLAGS_OTHER}")
      endif()
      if(SCALAPACK_LIBRARY_DIRS)
        list(APPEND REQUIRED_LIBDIRS "${SCALAPACK_LIBRARY_DIRS}")
      endif()
      if (SCALAPACK_LIBRARIES)
        list(APPEND REQUIRED_LIBS "${SCALAPACK_LIBRARIES}")
      endif()
    endif(SCALAPACK_FOUND)
  else()
    if (LAPACK_FOUND)  
      if (LAPACK_INCLUDE_DIRS)
        list(APPEND REQUIRED_INCDIRS "${LAPACK_INCLUDE_DIRS}")
      endif()
      if (LAPACK_CFLAGS_OTHER)
        list(APPEND REQUIRED_FLAGS "${LAPACK_CFLAGS_OTHER}")
      endif()
      if (LAPACK_LDFLAGS_OTHER)
        list(APPEND REQUIRED_LDFLAGS "${LAPACK_LDFLAGS_OTHER}")
      endif()
      if(LAPACK_LIBRARY_DIRS)
        list(APPEND REQUIRED_LIBDIRS "${LAPACK_LIBRARY_DIRS}")
      endif()
      if (LAPACK_LIBRARIES)
        list(APPEND REQUIRED_LIBS "${LAPACK_LIBRARIES}")
      endif()
    endif(LAPACK_FOUND)
  endif(MUMPS_LOOK_FOR_MPI)
  # MPI
  if (MUMPS_LOOK_FOR_MPI AND MPI_FOUND)
    if (MPI_C_INCLUDE_PATH)
      list(APPEND REQUIRED_INCDIRS "${MPI_C_INCLUDE_PATH}")
    endif()
    list(APPEND REQUIRED_LIBS "${MPI_Fortran_LIBRARIES}")
  endif()
  # SCOTCH
  if (MUMPS_LOOK_FOR_SCOTCH AND SCOTCH_FOUND)
    if (SCOTCH_INCLUDE_DIRS)
      list(APPEND REQUIRED_INCDIRS "${SCOTCH_INCLUDE_DIRS}")
    endif()
    foreach(libdir ${SCOTCH_LIBRARY_DIRS})
      if (libdir)
        list(APPEND REQUIRED_LIBDIRS "${libdir}")
      endif()
    endforeach()
    list(APPEND REQUIRED_LIBS "${SCOTCH_LIBRARIES}")
  endif()
  # PTSCOTCH
  if (MUMPS_LOOK_FOR_PTSCOTCH AND PTSCOTCH_FOUND)
    if (PTSCOTCH_INCLUDE_DIRS)
      list(APPEND REQUIRED_INCDIRS "${PTSCOTCH_INCLUDE_DIRS}")
    endif()
    foreach(libdir ${PTSCOTCH_LIBRARY_DIRS})
      if (libdir)
        list(APPEND REQUIRED_LIBDIRS "${libdir}")
      endif()
    endforeach()
    list(APPEND REQUIRED_LIBS "${PTSCOTCH_LIBRARIES}")
  endif()
  # METIS
  if (MUMPS_LOOK_FOR_METIS AND METIS_FOUND)
    if (METIS_INCLUDE_DIRS)
      list(APPEND REQUIRED_INCDIRS "${METIS_INCLUDE_DIRS}")
    endif()
    foreach(libdir ${METIS_LIBRARY_DIRS})
      if (libdir)
        list(APPEND REQUIRED_LIBDIRS "${libdir}")
      endif()
    endforeach()
    list(APPEND REQUIRED_LIBS "${METIS_LIBRARIES}")
  endif()
  # PARMETIS
  if (MUMPS_LOOK_FOR_PARMETIS AND PARMETIS_FOUND)
    if (PARMETIS_INCLUDE_DIRS)
      list(APPEND REQUIRED_INCDIRS "${PARMETIS_INCLUDE_DIRS}")
    endif()
    if (PARMETIS_CFLAGS_OTHER)
      list(APPEND REQUIRED_FLAGS "${PARMETIS_CFLAGS_OTHER}")
    endif()
    if (PARMETIS_LDFLAGS_OTHER)
      list(APPEND REQUIRED_LDFLAGS "${PARMETIS_LDFLAGS_OTHER}")
    endif()
    if(PARMETIS_LIBRARY_DIRS)
      list(APPEND REQUIRED_LIBDIRS "${PARMETIS_LIBRARY_DIRS}")
    endif()
    if (PARMETIS_LIBRARIES)
      list(APPEND REQUIRED_LIBS "${PARMETIS_LIBRARIES}")
    endif()
  endif()
  # OpenMP
  if(MUMPS_LOOK_FOR_OPENMP AND OPENMP_FOUND)
    list(APPEND REQUIRED_LDFLAGS "${OpenMP_C_FLAGS}")
  endif()
  # Fortran
  if (CMAKE_C_COMPILER_ID MATCHES "GNU")
    find_library(
      FORTRAN_gfortran_LIBRARY
      NAMES gfortran)
    mark_as_advanced(FORTRAN_gfortran_LIBRARY)
    if (FORTRAN_gfortran_LIBRARY)
      list(APPEND REQUIRED_LIBS "${FORTRAN_gfortran_LIBRARY}")
    endif()
  elseif (CMAKE_C_COMPILER_ID MATCHES "Intel")
    find_library(
      FORTRAN_ifcore_LIBRARY
      NAMES ifcore)
    mark_as_advanced(FORTRAN_ifcore_LIBRARY)
    if (FORTRAN_ifcore_LIBRARY)
      list(APPEND REQUIRED_LIBS "${FORTRAN_ifcore_LIBRARY}")
    endif()
  endif()
  # EXTRA LIBS such that pthread, m, rt
  list(APPEND REQUIRED_LIBS ${MUMPS_EXTRA_LIBRARIES})
  if (THREADS_PREFER_PTHREAD_FLAG)
    list(APPEND REQUIRED_FLAGS "${CMAKE_THREAD_LIBS_INIT}")
    list(APPEND REQUIRED_LDFLAGS "${CMAKE_THREAD_LIBS_INIT}")
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
  set(CMAKE_REQUIRED_FLAGS "${REQUIRED_LDFLAGS}")
  set(CMAKE_REQUIRED_LIBRARIES "${REQUIRED_LIBS}")
  string(REGEX REPLACE "^ -" "-" CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES}")

  # test link
  include(CheckFortranFunctionExists)
  unset(MUMPS_PREC_S_WORKS CACHE)
  check_fortran_function_exists(smumps MUMPS_PREC_S_WORKS)
  mark_as_advanced(MUMPS_PREC_S_WORKS)
  unset(MUMPS_PREC_D_WORKS CACHE)
  check_fortran_function_exists(dmumps MUMPS_PREC_D_WORKS)
  mark_as_advanced(MUMPS_PREC_D_WORKS)
  unset(MUMPS_PREC_C_WORKS CACHE)
  check_fortran_function_exists(cmumps MUMPS_PREC_C_WORKS)
  mark_as_advanced(MUMPS_PREC_C_WORKS)
  unset(MUMPS_PREC_Z_WORKS CACHE)
  check_fortran_function_exists(zmumps MUMPS_PREC_Z_WORKS)
  mark_as_advanced(MUMPS_PREC_Z_WORKS)

  set(MUMPS_WORKS FALSE)
  if(MUMPS_PREC_S_WORKS OR MUMPS_PREC_D_WORKS OR MUMPS_PREC_C_WORKS OR MUMPS_PREC_Z_WORKS)
    set(MUMPS_WORKS TRUE)
  endif()

  if(MUMPS_WORKS)
    set(MUMPS_LIBRARY_DIRS "${REQUIRED_LIBDIRS}")
    set(MUMPS_INCLUDE_DIRS "${REQUIRED_INCDIRS}")
    set(MUMPS_CFLAGS_OTHER "${REQUIRED_FLAGS}")
    set(MUMPS_LDFLAGS_OTHER "${REQUIRED_LDFLAGS}")
    if (MUMPS_STATIC OR BLA_STATIC OR SCOTCH_STATIC OR PTSCOTCH_STATIC OR METIS_STATIC OR PARMETIS_STATIC)
      # save link with dependencies
      set(MUMPS_LIBRARIES "${REQUIRED_LIBS}")
    endif()
  else()
    if(NOT MUMPS_FIND_QUIETLY)
      message(STATUS "Looking for MUMPS : test of [sdcz]mumps() fails")
      message(STATUS "CMAKE_REQUIRED_LIBRARIES: ${CMAKE_REQUIRED_LIBRARIES}")
      message(STATUS "CMAKE_REQUIRED_INCLUDES: ${CMAKE_REQUIRED_INCLUDES}")
      message(STATUS "Check in CMakeFiles/CMakeError.log to figure out why it fails")
      message(STATUS "Maybe MUMPS is linked with specific libraries. "
        "Have you tried with COMPONENTS (MPI/SEQ, SCOTCH, PTSCOTCH, METIS, PARMETIS)? "
        "See the explanation in FindMUMPS.cmake.")
    endif()
  endif()

  set(CMAKE_REQUIRED_INCLUDES)
  set(CMAKE_REQUIRED_FLAGS)
  set(CMAKE_REQUIRED_LIBRARIES)

  list(GET MUMPS_LIBRARIES 0 first_lib)
  get_filename_component(first_lib_path "${first_lib}" DIRECTORY)
  if (NOT MUMPS_LIBRARY_DIRS)
    set(MUMPS_LIBRARY_DIRS "${first_lib_path}")
  endif()
  if (${first_lib_path} MATCHES "/lib(32|64)?$")
    string(REGEX REPLACE "/lib(32|64)?$" "" not_cached_dir "${first_lib_path}")
    set(MUMPS_PREFIX "${not_cached_dir}" CACHE PATH "Installation directory of MUMPS library" FORCE)
  else()
    set(MUMPS_PREFIX "${first_lib_path}" CACHE PATH "Installation directory of MUMPS library" FORCE)
  endif()
  mark_as_advanced(MUMPS_DIR)
  mark_as_advanced(MUMPS_PREFIX)

endif(MUMPS_LIBRARIES)

# check that MUMPS has been found
# -------------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MUMPS DEFAULT_MSG
  MUMPS_LIBRARIES
  MUMPS_WORKS)

# Add imported target
if (MUMPS_FOUND)
  morse_create_imported_target(MUMPS)
endif()
