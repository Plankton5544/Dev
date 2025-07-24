
cmake_minimum_required(VERSION 3.10)
project(learning_opengl)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(OpenGL_GL_PREFERENCE GLVND)

# GLAD setup
set(GLAD_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(GLAD_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/glad.c")

# Find packages
find_package(OpenGL REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(glm REQUIRED)

# Find GLFW
pkg_check_modules(GLFW3 REQUIRED glfw3)

# Create executable
add_executable(learningGL main.cpp ${GLAD_SOURCES})

# Include directories
target_include_directories(learningGL PRIVATE
    ${GLAD_INCLUDE_DIR}
    ${GLFW3_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(learningGL PRIVATE
    ${OPENGL_LIBRARIES}
    ${GLFW3_LIBRARIES}
    glm::glm
)

# Compiler flags
target_compile_options(learningGL PRIVATE ${GLFW3_CFLAGS_OTHER})
