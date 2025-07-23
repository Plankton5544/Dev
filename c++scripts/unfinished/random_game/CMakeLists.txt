#cmake_minimum_required(VERSION 3.16)
#project(Couch_Wars)
#set(CMAKE_CXX_STANDARD 17)
#find_package(sfml REQUIRED COMPONENTS graphics window system)
#add_executable(Couch_Wars src/main.cpp)
#target_link_libraries(Couch_wars sfml-graphics sfml-window sfml-system)


cmake_minimum_required(VERSION 3.16)
project(CouchWars)
set(CMAKE_CXX_STANDARD 17)

# Try the old-style find instead
find_package(PkgConfig REQUIRED)
pkg_check_modules(SFML REQUIRED sfml-graphics sfml-window sfml-system)

add_executable(CouchWars main.cpp)
target_link_libraries(CouchWars ${SFML_LIBRARIES})
target_include_directories(CouchWars PRIVATE ${SFML_INCLUDE_DIRS})
