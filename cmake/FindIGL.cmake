# - Try to find igl lib
#
# Usage:
#   find_package(IGL)
#
# Once done this will define
#
#  IGL_FOUND - system has eigen lib with correct version
#  IGL_INCLUDE_DIR - the eigen include directory

if (IGL_INCLUDE_DIR)

  # in cache already

else (IGL_INCLUDE_DIR)

  find_path(IGL_INCLUDE_DIR NAMES
      igl/igl_inline.h
      PATHS
      ${CMAKE_INSTALL_PREFIX}/include
      ${CMAKE_SOURCE_DIR}/../libigl/include
      PATH_SUFFIXES igl
    )

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(IGL DEFAULT_MSG IGL_INCLUDE_DIR)

  mark_as_advanced(IGL_INCLUDE_DIR)

endif(IGL_INCLUDE_DIR)
