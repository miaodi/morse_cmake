cmake_minimum_required(VERSION 2.8)
project(TEST_MORSE_CMAKE_MODULES_FIND Fortran C CXX)

# location of Find package modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../")

# main variable: control the list of libraries to find thanks to find_package
# pay attention that package names must be given with capital letters
set(PACKAGES_TO_FIND "" CACHE STRING "List of packages to find, ex: BLAS;STARPU;PASTIX")

# if the list is empty: simple test with hwloc
if (NOT PACKAGES_TO_FIND)
  list(APPEND PACKAGES_TO_FIND "HWLOC")
endif()

foreach(_library ${PACKAGES_TO_FIND})

  find_package(${_library})
  if (${_library}_FOUND)
    if (${_library}_LIBRARIES)
      message(STATUS "${_library}_LIBRARIES found: ${${_library}_LIBRARIES}")
    else()
      message(ERROR "${_library}_LIBRARIES not found: ${${_library}_LIBRARIES}")
    endif()
    if (${_library}_LIBRARY_DIRS)
      message(STATUS "${_library}_LIBRARY_DIRS found: ${${_library}_LIBRARY_DIRS}")
    else()
      message(WARNING "${_library}_LIBRARY_DIRS not found: ${${_library}_LIBRARY_DIRS}")
    endif()
    if (${_library}_INCLUDE_DIRS)
      message(STATUS "${_library}_INCLUDE_DIRS found: ${${_library}_INCLUDE_DIRS}")
    else()
      message(WARNING "${_library}_INCLUDE_DIRS not found: ${${_library}_INCLUDE_DIRS}")
    endif()
  else()
    message(FATAL_ERROR "${_library} NOT FOUND !!")
  endif()

endforeach()

###
### END CMakeLists.txt
###