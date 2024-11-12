cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(boom_filter)

target_compile_definitions(app PRIVATE TARGET_HOST=1)

file(GLOB SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/../common/*.c")

target_include_directories(app PRIVATE ../common)
target_sources(app PRIVATE ${SRC_FILES} src/bloom-filter.c src/tinybloom.c src/tinybloom.h src/main.c)