# Copyright (c) 2017 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

IF(NOT ${WITH_LIBMCT})
  return()
ENDIF(NOT ${WITH_LIBMCT})

IF(WIN32 OR APPLE)
    MESSAGE(WARNING
        "Windows or Mac is not supported with LIBMCT in Paddle yet."
        "Force WITH_LIBMCT=OFF")
    SET(WITH_LIBMCT OFF CACHE STRING "Disable LIBMCT package in Windows and MacOS" FORCE)
    return()
ENDIF()

INCLUDE(ExternalProject)

SET(LIBMCT_PROJECT       "extern_libmct")
IF((NOT DEFINED LIBMCT_VER) OR (NOT DEFINED LIBMCT_URL))
  MESSAGE(STATUS "use pre defined download url")
  SET(LIBMCT_VER "libmct" CACHE STRING "" FORCE) #todo libmct version
  SET(LIBMCT_URL "http://bjyz-heqiaozhi-dev-new.epc.baidu.com:8000/${LIBMCT_VER}.tar.gz" CACHE STRING "" FORCE) #todo libmct url
ENDIF()
MESSAGE(STATUS "LIBMCT_VER: ${LIBMCT_VER}, LIBMCT_URL: ${LIBMCT_URL}")
SET(LIBMCT_SOURCE_DIR    "${THIRD_PARTY_PATH}/libmct")
SET(LIBMCT_DOWNLOAD_DIR  "${LIBMCT_SOURCE_DIR}/src/${LIBMCT_PROJECT}")
SET(LIBMCT_DST_DIR       "libmct")
SET(LIBMCT_INSTALL_ROOT  "${THIRD_PARTY_PATH}/install")
SET(LIBMCT_INSTALL_DIR   ${LIBMCT_INSTALL_ROOT}/${LIBMCT_DST_DIR})
SET(LIBMCT_ROOT          ${LIBMCT_INSTALL_DIR})
SET(LIBMCT_INC_DIR       ${LIBMCT_ROOT}/include)
SET(LIBMCT_LIB_DIR       ${LIBMCT_ROOT}/lib)
SET(LIBMCT_LIB           ${LIBMCT_LIB_DIR}/libps.so)
SET(LIBMCT_IOMP_LIB      ${LIBMCT_LIB_DIR}/libiomp5.so) #todo what is this
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}" "${LIBMCT_ROOT}/lib")

INCLUDE_DIRECTORIES(${LIBMCT_INC_DIR})

FILE(WRITE ${LIBMCT_DOWNLOAD_DIR}/CMakeLists.txt
  "PROJECT(LIBMCT)\n"
  "cmake_minimum_required(VERSION 3.0)\n"
  "install(DIRECTORY ${LIBMCT_VER}/include ${LIBMCT_VER}/lib \n"
  "        DESTINATION ${LIBMCT_DST_DIR})\n")

ExternalProject_Add(
    ${LIBMCT_PROJECT}
    ${EXTERNAL_PROJECT_LOG_ARGS}
    PREFIX                ${LIBMCT_SOURCE_DIR}
    DOWNLOAD_DIR          ${LIBMCT_DOWNLOAD_DIR}
    DOWNLOAD_COMMAND      wget --no-check-certificate ${LIBMCT_URL} -c -q -O ${LIBMCT_VER}.tar.gz
                          && tar zxvf ${LIBMCT_VER}.tar.gz
    DOWNLOAD_NO_PROGRESS  1
    UPDATE_COMMAND        ""
    CMAKE_ARGS            -DCMAKE_INSTALL_PREFIX=${LIBMCT_INSTALL_ROOT}
    CMAKE_CACHE_ARGS      -DCMAKE_INSTALL_PREFIX:PATH=${LIBMCT_INSTALL_ROOT}
)

ADD_LIBRARY(libmct SHARED IMPORTED GLOBAL)
SET_PROPERTY(TARGET libmct PROPERTY IMPORTED_LOCATION ${LIBMCT_LIB})
ADD_DEPENDENCIES(libmct ${LIBMCT_PROJECT})
LIST(APPEND external_project_dependencies libmct)

IF(WITH_C_API)
  INSTALL(FILES ${LIBMCT_LIB} ${LIBMCT_IOMP_LIB} DESTINATION lib)
ENDIF()