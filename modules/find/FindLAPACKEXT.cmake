###
#
# @copyright (c) 2012-2020 Inria. All rights reserved.
# @copyright (c) 2012-2014 Bordeaux INP, CNRS (LaBRI UMR 5800), Inria, Univ. Bordeaux. All rights reserved.
#
# Copyright 2021 Florent Pruvost
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
# - Extension of FindLAPACK in order to provide both sequential and multi-threaded libraries when possible (e.g. Intel MKL)
#
# Result variables:
#
# - ``LAPACKEXT_FOUND`` if LAPACK is found
# - ``LAPACK_SEQ_LINKER_FLAGS`` sequential version of LAPACK_LINKER_FLAGS
# - ``LAPACK_MT_LINKER_FLAGS`` multi-threaded version of LAPACK_LINKER_FLAGS
# - ``LAPACK_SEQ_LIBRARIES`` sequential version of LAPACK_LIBRARIES
# - ``LAPACK_MT_LIBRARIES`` multi-threaded version of LAPACK_LIBRARIES
#
# This module defines the following :prop_tgt:`IMPORTED` target:
#
# ``LAPACK::LAPACK_SEQ``
#   The libraries of sequential LAPACK, if found.
#
# ``LAPACK::LAPACK_MT``
#   The libraries of multi-threaded LAPACK, if found.
#
#=============================================================================

if(NOT LAPACKEXT_FIND_QUIETLY)
  message(STATUS "FindLAPACKEXT: Try to find LAPACK")
endif()

# LAPACKEXT first search LAPACK available
if(LAPACKEXT_FIND_REQUIRED)
  find_package(LAPACK QUIET REQUIRED)
else()
  find_package(LAPACK QUIET)
endif()

if (LAPACK_FOUND)

  if(LAPACK_LIBRARIES MATCHES "libmkl")

    if(NOT LAPACKEXT_FIND_QUIETLY)
      message(STATUS "FindLAPACKEXT: LAPACK_LIBRARIES matches mkl")
    endif()
    set(BLA_VENDOR "Intel10_64lp_seq")
    unset(LAPACK_FOUND)
    unset(LAPACK_LINKER_FLAGS)
    unset(LAPACK_LIBRARIES)
    find_package(LAPACK QUIET)
    if (LAPACK_FOUND)
      set(LAPACK_SEQ_FOUND ${LAPACK_FOUND})
      if(NOT TARGET LAPACK::LAPACK_SEQ)
        add_library(LAPACK::LAPACK_SEQ INTERFACE IMPORTED)
      endif()
      if (LAPACK_LINKER_FLAGS)
        set(LAPACK_SEQ_LINKER_FLAGS ${LAPACK_LINKER_FLAGS})
        set_target_properties(LAPACK::LAPACK_SEQ PROPERTIES
          INTERFACE_LINK_OPTIONS "${LAPACK_LINKER_FLAGS}"
        )
      endif()
      if (LAPACK_LIBRARIES)
        if(NOT LAPACKEXT_FIND_QUIETLY)
        message(STATUS "FindLAPACKEXT: Found LAPACK ${BLA_VENDOR}")
          message(STATUS "FindLAPACKEXT: Store following libraries in LAPACK_SEQ_LIBRARIES and target LAPACK::LAPACK_SEQ ${LAPACK_LIBRARIES}")
        endif()
        set(LAPACK_SEQ_LIBRARIES ${LAPACK_LIBRARIES})
        set_target_properties(LAPACK::LAPACK_SEQ PROPERTIES
          INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
        )
      endif()
    endif()

    set(BLA_VENDOR "Intel10_64lp")
    unset(LAPACK_FOUND)
    unset(LAPACK_LINKER_FLAGS)
    unset(LAPACK_LIBRARIES)
    find_package(LAPACK QUIET)
    if (LAPACK_FOUND)
      set(LAPACK_MT_FOUND ${LAPACK_FOUND})
      if(NOT TARGET LAPACK::LAPACK_MT)
        add_library(LAPACK::LAPACK_MT INTERFACE IMPORTED)
      endif()
      if (LAPACK_LINKER_FLAGS)
        set(LAPACK_MT_LINKER_FLAGS ${LAPACK_LINKER_FLAGS})
        set_target_properties(LAPACK::LAPACK_MT PROPERTIES
          INTERFACE_LINK_OPTIONS "${LAPACK_LINKER_FLAGS}"
        )
      endif()
      if (LAPACK_LIBRARIES)
        if(NOT LAPACKEXT_FIND_QUIETLY)
        message(STATUS "FindLAPACKEXT: Found LAPACK ${BLA_VENDOR}")
          message(STATUS "FindLAPACKEXT: Store following libraries in LAPACK_MT_LIBRARIES and target LAPACK::LAPACK_MT ${LAPACK_LIBRARIES}")
        endif()
        set(LAPACK_MT_LIBRARIES ${LAPACK_LIBRARIES})
        set_target_properties(LAPACK::LAPACK_MT PROPERTIES
          INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
        )
      endif()
    endif()

  else(LAPACK_LIBRARIES MATCHES "libmkl")

    set(LAPACK_SEQ_FOUND ${LAPACK_FOUND})
    if(NOT TARGET LAPACK::LAPACK_SEQ)
      add_library(LAPACK::LAPACK_SEQ INTERFACE IMPORTED)
    endif()
    if (LAPACK_LINKER_FLAGS)
      set(LAPACK_SEQ_LINKER_FLAGS ${LAPACK_LINKER_FLAGS})
      set_target_properties(LAPACK::LAPACK_SEQ PROPERTIES
        INTERFACE_LINK_OPTIONS "${LAPACK_LINKER_FLAGS}"
      )
    endif()
    if (LAPACK_LIBRARIES)
      if(NOT LAPACKEXT_FIND_QUIETLY)
        message(STATUS "FindLAPACKEXT: Found LAPACK ${BLA_VENDOR}")
        message(STATUS "FindLAPACKEXT: Store following libraries in LAPACK_SEQ_LIBRARIES and target LAPACK::LAPACK_SEQ ${LAPACK_LIBRARIES}")
      endif()
      set(LAPACK_SEQ_LIBRARIES ${LAPACK_LIBRARIES})
      set_target_properties(LAPACK::LAPACK_SEQ PROPERTIES
        INTERFACE_LINK_LIBRARIES "${LAPACK_LIBRARIES}"
      )
    endif()

  endif(LAPACK_LIBRARIES MATCHES "libmkl")

else(LAPACK_FOUND)
  if(NOT LAPACKEXT_FIND_QUIETLY)
    message(STATUS "FindLAPACKEXT: LAPACK not found or LAPACK_LIBRARIES does not match mkl")
  endif()
endif(LAPACK_FOUND)

# check that LAPACKEXT has been found
# -----------------------------------
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LAPACKEXT DEFAULT_MSG
  LAPACK_SEQ_LIBRARIES)
