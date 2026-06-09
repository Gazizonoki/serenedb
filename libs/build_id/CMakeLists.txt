add_library(serene_build_id STATIC src/build_id.cpp)

target_include_directories(serene_build_id PUBLIC include)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # PUBLIC: dependents (tests, version reporting) see the same ABI as this TU.
  target_compile_definitions(serene_build_id PUBLIC SERENEDB_HAVE_ELF_BUILD_ID=1)
  target_link_options(
      serene_build_id
      PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/BuildId.ld -Wl,--build-id=sha1
  )
endif()
