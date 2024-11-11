cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(mini_nn)

target_sources(app PRIVATE src/main.c src/nn.c src/weights.h src/images.h)