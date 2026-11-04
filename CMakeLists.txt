#
# Модуль «Славянские праздники и события»
# CMake-определение для системы модулей AzerothCore.
#

AC_ADD_SCRIPT("slavic-holidays-events")

CU_SET_PATH("CMAKE_MOD_SLAVIC_HOLIDAYS_DIR" "${CMAKE_CURRENT_LIST_DIR}")

CollectSourceFiles(
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  SLAVIC_SOURCES
)

CollectIncludeDirectories(
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  SLAVIC_INCLUDES
)

target_include_directories(modules
  INTERFACE
    ${SLAVIC_INCLUDES})
