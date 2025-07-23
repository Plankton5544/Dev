cmake_minimum_required(VERSION 3.16)
project(CouchWars)
set(CMAKE_CXX_STANDARD 17)

# Try the old-style find instead
find_package(PkgConfig REQUIRED)
pkg_check_modules(SFML REQUIRED sfml-graphics sfml-window sfml-system)

add_executable(CouchWars main.cpp)
target_link_libraries(CouchWars ${SFML_LIBRARIES})
target_include_directories(CouchWars PRIVATE ${SFML_INCLUDE_DIRS})
