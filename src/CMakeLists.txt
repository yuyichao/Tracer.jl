#

set(Tracer_SRCS
  Tracer.jl
  decompile.jl)

cmake_utils_install_files("${julia_path}/Tracer/src"
  FILES: ${Tracer_SRCS})
