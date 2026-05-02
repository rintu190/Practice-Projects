cmake_minimum_required(VERSION 3.16)
project(kernelBypassDpkd)

set(CMAKE_CXX_STANDARD 17)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DPDK REQUIRED libdpdk)

add_executable(kernelBypassDpkd kernelBypassDpkd.cpp)

target_include_directories(kernelBypassDpkd PRIVATE ${DPDK_INCLUDE_DIRS})
target_compile_options(kernelBypassDpkd PRIVATE ${DPDK_CFLAGS_OTHER})
target_link_libraries(kernelBypassDpkd PRIVATE ${DPDK_LIBRARIES})