project(Tracer.jl NONE)

## Setup
cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(JuliaMacros)
include(CMakePathMacros)
# include(CMakeCMacros)

julia_site_path(julia_path)

# cmake_c_add_flags(CMAKE_C_FLAGS -Wall -Wextra -std=gnu99 -fopenmp)
# cmake_c_add_flags(CMAKE_CXX_FLAGS -Wall -Wextra
#   -Wno-deprecated-register -std=c++14 -fopenmp)
# cmake_c_add_flags(CMAKE_SHARED_LINKER_FLAGS -Wl,--as-needed -Wl,--no-undefined)
# cmake_c_add_flags(CMAKE_MODULE_LINKER_FLAGS -Wl,--as-needed -Wl,--no-undefined)

add_subdirectory(src)
add_subdirectory(test)
