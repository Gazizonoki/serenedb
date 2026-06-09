# SereneDB — ICU common data on Darwin
#
# The ICU submodule ships icudt75l_dat.S as GNU/ELF assembly. Apple's assembler
# expects Mach-O sections and _icudt75_dat for C linkage to icudt75_dat.
#
# This file lives under cmake/ (not third_party/icu) so it survives
# `git submodule update --force` when AUTO_UPDATE_MODULES is enabled.

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    return()
endif()

if(NOT TARGET _icudata)
    return()
endif()

set(_serene_icu_gnu_asm "${CMAKE_SOURCE_DIR}/third_party/icu/icudata/icudt75l_dat.S")
set(_serene_icu_macho_asm "${CMAKE_BINARY_DIR}/third_party/icu/icudt75l_dat_macho.S")

# add_custom_command(OUTPUT) must not be registered twice in one build tree.
if(NOT TARGET serenedb_icudata_macho_gen)
    # Run via `cmake -P`: add_custom_command's `/bin/sh -c "..."` is split into several
    # Ninja tokens so `-c` only sees `printf`, and sh tries to execute the output path.
    add_custom_command(
        OUTPUT "${_serene_icu_macho_asm}"
        COMMAND
            "${CMAKE_COMMAND}"
            "-DOUT=${_serene_icu_macho_asm}"
            "-DIN=${_serene_icu_gnu_asm}"
            -P
            "${CMAKE_SOURCE_DIR}/cmake/SereneIcuDarwinMacho.cmake"
        DEPENDS "${_serene_icu_gnu_asm}"
        COMMENT "SereneDB: ICU icudata GNU asm -> Mach-O (Darwin)"
    )
    add_custom_target(serenedb_icudata_macho_gen DEPENDS "${_serene_icu_macho_asm}")
endif()

add_dependencies(_icudata serenedb_icudata_macho_gen)

get_target_property(_serene_icu_data_sources _icudata SOURCES)
if(_serene_icu_data_sources MATCHES "\\$<")
    return()
endif()

set(_serene_icu_new_sources "")
foreach(_serene_s IN LISTS _serene_icu_data_sources)
    if(_serene_s STREQUAL "${_serene_icu_gnu_asm}")
        continue()
    endif()
    if(_serene_s MATCHES "^icudata/icudt75l_dat\\.S$")
        continue()
    endif()
    list(APPEND _serene_icu_new_sources "${_serene_s}")
endforeach()

list(FIND _serene_icu_new_sources "${_serene_icu_macho_asm}" _serene_icu_macho_idx)
if(_serene_icu_macho_idx LESS 0)
    list(APPEND _serene_icu_new_sources "${_serene_icu_macho_asm}")
endif()

set_property(TARGET _icudata PROPERTY SOURCES ${_serene_icu_new_sources})
