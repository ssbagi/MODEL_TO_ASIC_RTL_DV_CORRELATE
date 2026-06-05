cmake_minimum_required(VERSION 3.15)
project(directmap_cache_systemc LANGUAGES CXX)

find_package(SystemC REQUIRED)

add_executable(dcache_systemc
  SystemCMain.cpp
  DcacheSystemC.cpp
  TrafficGenerator.cpp
)

target_include_directories(dcache_systemc PRIVATE ${SYSTEMC_INCLUDE_DIRS})
target_link_libraries(dcache_systemc PRIVATE ${SYSTEMC_LIBRARIES})

set_target_properties(dcache_systemc PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED YES)
