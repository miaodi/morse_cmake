###
#
# @copyright (c) 2019 Inria. All rights reserved.
#
###
#
#  @file FindMorseCommon.cmake
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
#  @date 13-04-2018
#
###

# clean these variables before using them in CMAKE_REQUIRED_* variables in
# check_function_exists
macro(morse_finds_remove_duplicates)
  if (REQUIRED_DEFINITIONS)
    list(REMOVE_DUPLICATES REQUIRED_DEFINITIONS)
  endif()
  if (REQUIRED_INCDIRS)
    list(REMOVE_DUPLICATES REQUIRED_INCDIRS)
  endif()
  if (REQUIRED_FLAGS)
    list(REMOVE_DUPLICATES REQUIRED_FLAGS)
  endif()
  if (REQUIRED_LDFLAGS)
    list(REMOVE_DUPLICATES REQUIRED_LDFLAGS)
  endif()
  if (REQUIRED_LIBS)
    list(REVERSE REQUIRED_LIBS)
    list(REMOVE_DUPLICATES REQUIRED_LIBS)
    list(REVERSE REQUIRED_LIBS)
  endif()
endmacro()

# add imported target for non-cmake projects or projects which do not provide
# "PROJECT"Config.cmake file at installation
macro(morse_check_static_or_dynamic package libraries)
   list(GET ${libraries} 0 _first_lib)
   get_filename_component(_suffix ${_first_lib} EXT)
   #message(STATUS "package ${package}")
   #message(STATUS "libraries ${libraries} ${${libraries}}")
   #message(STATUS "_suffix ${_suffix} ${_first_lib}")
   if (NOT _suffix)
     unset (_lib_path CACHE)
     find_library(_lib_path ${_first_lib} HINTS ${${package}_LIBDIR} ${${package}_LIBRARY_DIRS} NO_DEFAULT_PATH)
     #message(STATUS "_first_lib ${_first_lib}")
     #message(STATUS "${${package}_LIBRARY_DIRS}")
     #message(STATUS "_lib_path ${_lib_path}")
     get_filename_component(_suffix ${_lib_path} EXT)
   endif()
   if (_suffix)
     if(${_suffix} MATCHES ".so$" OR ${_suffix} MATCHES ".dylib$" OR ${_suffix} MATCHES ".dll$")
       set(${package}_STATIC 0)
     elseif(${_suffix} MATCHES ".a$")
       set(${package}_STATIC 1)
     else()
       message(FATAL_ERROR "${package} library extension not in list .a, .so, .dylib, .dll")
     endif()
  else()
    message(FATAL_ERROR "${package} could not detect library extension")
  endif()
endmacro()

# add imported target for non-cmake projects or projects which do not provide
# "PROJECT"Config.cmake file at installation
macro(morse_create_imported_target name)

  if(NOT TARGET MORSE::${name})

    # initialize imported target
    add_library(MORSE::${name} INTERFACE IMPORTED)

    if (TARGET PkgConfig::${name})
      get_target_property(_INCLUDES  PkgConfig::${name} INTERFACE_INCLUDE_DIRECTORIES)
      get_target_property(_LIBDIRS   PkgConfig::${name} INTERFACE_LINK_DIRECTORIES)
      get_target_property(_LIBRARIES PkgConfig::${name} INTERFACE_LINK_LIBRARIES)
      get_target_property(_CFLAGS PkgConfig::${name} INTERFACE_COMPILE_OPTIONS)
      get_target_property(_LDFLAGS PkgConfig::${name} INTERFACE_LINK_OPTIONS)
      set_target_properties(MORSE::${name} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${_INCLUDES}")
      set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_DIRECTORIES "${_LIBDIRS}")
      set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_LIBRARIES "${_LIBRARIES}")
      set_target_properties(MORSE::${name} PROPERTIES INTERFACE_COMPILE_OPTIONS "${_CFLAGS}")
      set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_OPTIONS "${_LDFLAGS}")
    else ()
      if (${name}_INCLUDE_DIRS)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${${name}_INCLUDE_DIRS}")
      endif()
      if (${name}_LIBRARY_DIRS)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_DIRECTORIES "${${name}_LIBRARY_DIRS}")
      elseif (${name}_LIBDIR)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_DIRECTORIES "${${name}_LIBDIR}")
        set (${name}_LIBRARY_DIRS ${${name}_LIBDIR})
      endif()
      if (${name}_LIBRARIES)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_LIBRARIES "${${name}_LIBRARIES}")
      endif()
      if (${name}_CFLAGS_OTHER)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_COMPILE_OPTIONS "${${name}_CFLAGS_OTHER}")
      endif()
      if (${name}_LDFLAGS_OTHER)
        set_target_properties(MORSE::${name} PROPERTIES INTERFACE_LINK_OPTIONS "${${name}_LDFLAGS_OTHER}")
      endif()
    endif()

  endif (NOT TARGET MORSE::${name})

  set(debug_morse_create_imported_target "FALSE")
  if (debug_morse_create_imported_target)
    if (TARGET MORSE::${name})
      get_target_property(_INCLUDES MORSE::${name} INTERFACE_INCLUDE_DIRECTORIES)
      get_target_property(_DIRECTORIES MORSE::${name} INTERFACE_LINK_DIRECTORIES)
      get_target_property(_LIBRARIES MORSE::${name} INTERFACE_LINK_LIBRARIES)
      get_target_property(_CFLAGS MORSE::${name} INTERFACE_COMPILE_OPTIONS)
      get_target_property(_LDFLAGS MORSE::${name} INTERFACE_LINK_OPTIONS)
      message(STATUS "IMPORTED TARGET ${name}:
                      _INCLUDES ${_INCLUDES}
                      _DIRECTORIES ${_DIRECTORIES}
                      _LIBRARIES ${_LIBRARIES}
                      _CFLAGS ${_CFLAGS}
                      _LDFLAGS ${_LDFLAGS}")
    endif()
  endif()

endmacro()

# set required libraries for link test
macro(morse_set_required_test_lib_link name)
  set(CMAKE_REQUIRED_INCLUDES "${${name}${STATIC}_INCLUDE_DIRS}")
  if (${name}${STATIC}_CFLAGS_OTHER)
    set(REQUIRED_FLAGS_COPY "${${name}${STATIC}_CFLAGS_OTHER}")
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
  list(APPEND CMAKE_REQUIRED_LIBRARIES "${${name}${STATIC}_LDFLAGS_OTHER}")
  list(APPEND CMAKE_REQUIRED_LIBRARIES "${${name}${STATIC}_LIBRARIES}")
  string(REGEX REPLACE "^ -" "-" CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES}")
endmacro()

# Transform relative path into absolute path for libraries found with the
# pkg_search_module cmake macro
# _prefix: the name of the CMake variable used when pkg_search_module was called
# e.g. for pkg_search_module(BLAS blas) _prefix would be BLAS
macro(morse_find_pkgconfig_libraries_absolute_path _prefix)
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
  set(${_prefix}_LIBRARIES_COPY "${${_prefix}_LIBRARIES}")
  set(${_prefix}_LIBRARIES "")
  foreach(_library ${${_prefix}_LIBRARIES_COPY})
    if(EXISTS "${_library}")
      list(APPEND ${_prefix}_LIBRARIES ${_library})
    else()
      get_filename_component(_ext "${_library}" EXT)
      set(_lib_extensions ".a" ".so" ".dyld" ".dll")
      list(FIND _lib_extensions "${_ext}" _index)
      if (${_index} GREATER -1)
        get_filename_component(_library "${_library}" NAME_WE)
      endif()
      if (${_prefix}_STATIC)
        set (CMAKE_FIND_LIBRARY_SUFFIXES_COPY ${CMAKE_FIND_LIBRARY_SUFFIXES})
        set (CMAKE_FIND_LIBRARY_SUFFIXES ".a")
      endif()
      find_library(_library_path NAMES ${_library}
                                 HINTS ${${_prefix}_LIBDIR} ${${_prefix}_LIBRARY_DIRS} ${_lib_env}
                                 )
      if (_library_path)
          list(APPEND ${_prefix}_LIBRARIES ${_library_path})
      else()
          if (${_prefix}_STATIC)
            message(STATUS "${_prefix}_STATIC ${${_prefix}_STATIC}")
          endif()
          message(FATAL_ERROR "Dependency of ${_prefix} '${_library}' NOT FOUND with suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES} in ${${_prefix}_LIBDIR} ${${_prefix}_LIBRARY_DIRS}")
      endif()
      unset(_library_path CACHE)
      if (${_prefix}_STATIC)
        set (CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_COPY})
      endif()
    endif()
  endforeach()
  set (${_prefix}_LIBRARIES "${${_prefix}_LIBRARIES}" CACHE INTERNAL "" FORCE)
  ## static case
  #set(${_prefix}_STATIC_LIBRARIES_COPY "${${_prefix}_STATIC_LIBRARIES}")
  #set(${_prefix}_STATIC_LIBRARIES "")
  #foreach(_library ${${_prefix}_STATIC_LIBRARIES_COPY})
  #  if(EXISTS "${_library}")
  #    list(APPEND ${_prefix}_STATIC_LIBRARIES ${_library})
  #  else()
  #    get_filename_component(_ext "${_library}" EXT)
  #    set(_lib_extensions ".a" ".so" ".dyld" ".dll")
  #    list(FIND _lib_extensions "${_ext}" _index)
  #    if (${_index} GREATER -1)
  #      get_filename_component(_library "${_library}" NAME_WE)
  #    endif()
  #    # try static first
  #    set (default_find_library_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
  #    set (CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
  #    find_library(_library_path NAMES ${_library}
  #        HINTS ${${_prefix}_STATIC_LIBDIR} ${${_prefix}_STATIC_LIBRARY_DIRS} ${_lib_env})
  #    set (CMAKE_FIND_LIBRARY_SUFFIXES ${default_find_library_suffixes})
  #    # if not found try dynamic
  #    if (NOT _library_path)
  #      find_library(_library_path NAMES ${_library}
  #          HINTS ${${_prefix}_STATIC_LIBDIR} ${${_prefix}_STATIC_LIBRARY_DIRS} ${_lib_env})
  #    endif()
  #    if (_library_path)
  #        list(APPEND ${_prefix}_STATIC_LIBRARIES ${_library_path})
  #    else()
  #        message(FATAL_ERROR "Dependency of ${_prefix} '${_library}' NOT FOUND")
  #    endif()
  #    unset(_library_path CACHE)
  #  endif()
  #endforeach()
  #set (${_prefix}_STATIC_LIBRARIES "${${_prefix}_STATIC_LIBRARIES}" CACHE INTERNAL "" FORCE)
endmacro()

##
## @end file FindMorseCommon
##
