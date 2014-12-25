#

enable_testing()

add_test(test-decompile
  env "JULIA_LOAD_PATH=${PROJECT_SOURCE_DIR}/src" julia
  "${CMAKE_CURRENT_SOURCE_DIR}/test-decompile.jl")
