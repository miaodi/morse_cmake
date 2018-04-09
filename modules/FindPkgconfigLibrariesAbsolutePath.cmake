###
#
# @copyright (c) 2018 Inria. All rights reserved.
#
###
#
#  @file FindPkgconfigLibrariesAbsolutePath.cmake
#
#  @project MORSE
#  MORSE is a software package provided by:
#     Inria Bordeaux - Sud-Ouest,
#     Univ. of Tennessee,
#     King Abdullah Univesity of Science and Technology
#     Univ. of California Berkeley,
#     Univ. of Colorado Denver.
#
#  @version 1.0.0
#  @author Florent Pruvost
#  @date 06-04-2018
#
###

# Transform relative path into absolute path for libraries found with the 
# pkg_search_module cmake macro
# _prefix: the name of the CMake variable used when pkg_search_module was called
# e.g. for pkg_search_module(BLAS blas) _prefix would be BLAS
macro(FIND_PKGCONFIG_LIBRARIES_ABSOLUTE_PATH _prefix)
  if(WIN32)
    string(REPLACE ":" ";" _lib_env "$ENV{LIB}")
  elseif(APPLE)
    string(REPLACE ":" ";" _lib_env "$ENV{DYLD_LIBRARY_PATH}")
  else()
    string(REPLACE ":" ";" _lib_env "$ENV{LD_LIBRARY_PATH}")
  endif()
  list(APPEND _lib_env "${CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES}")
  list(APPEND _lib_env "${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")
  set(${_prefix}_LIBRARIES_COPY "${${_prefix}_LIBRARIES}")
  set(${_prefix}_LIBRARIES "")
  foreach(_library ${${_prefix}_LIBRARIES_COPY})
      get_filename_component(_library "${_library}" NAME_WE)
      find_library(_library_path NAMES ${_library}
          HINTS ${${_prefix}_LIBDIR} ${${_prefix}_LIBRARY_DIRS} ${_lib_env})
      if (_library_path)
          list(APPEND ${_prefix}_LIBRARIES ${_library_path})
      else()
          message(FATAL_ERROR "Dependency of ${_prefix} '${_library}' NOT FOUND")
      endif()
      unset(_library_path CACHE)
  endforeach()
  set(${_prefix}_STATIC_LIBRARIES_COPY "${${_prefix}_STATIC_LIBRARIES}")
  set(${_prefix}_STATIC_LIBRARIES "")
  foreach(_library ${${_prefix}_STATIC_LIBRARIES_COPY})
      get_filename_component(_library "${_library}" NAME_WE)
      find_library(_library_path NAMES ${_library}
          HINTS ${${_prefix}_STATIC_LIBDIR} ${${_prefix}_STATIC_LIBRARY_DIRS} ${_lib_env})
      if (_library_path)
          list(APPEND ${_prefix}_STATIC_LIBRARIES ${_library_path})
      else()
          message(FATAL_ERROR "Dependency of ${_prefix} '${_library}' NOT FOUND")
      endif()
      unset(_library_path CACHE)
  endforeach()
endmacro()

##
## @end file FindPkgconfigLibrariesAbsolutePath.cmake
##
