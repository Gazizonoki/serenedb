# Invoked at build time: cmake -P SereneIcuDarwinMacho.cmake -DOUT=... -DIN=...
# Converts bundled GNU/ELF icudt75l_dat.S into Mach-O assembly for Darwin.

if(NOT DEFINED OUT OR NOT DEFINED IN)
    message(FATAL_ERROR "SereneIcuDarwinMacho.cmake: OUT and IN must be set (-DOUT= -DIN=)")
endif()

cmake_path(GET OUT PARENT_PATH _serene_icu_out_dir)
file(MAKE_DIRECTORY "${_serene_icu_out_dir}")

# Full script must be a single -c argument; Ninja/CMake split multi-arg sh -c incorrectly.
set(_serene_icu_sh_script
    "printf '%s\\n' '.globl _icudt75_dat' '.section __DATA,__const' '.p2align 4' '_icudt75_dat:' > \"${OUT}\" && awk 'NR>12{if(/^\\.size /)exit;print}' \"${IN}\" >> \"${OUT}\""
)

execute_process(
    COMMAND /bin/sh -c "${_serene_icu_sh_script}"
    RESULT_VARIABLE _serene_icu_rc
)

if(NOT _serene_icu_rc EQUAL 0)
    message(FATAL_ERROR "SereneIcuDarwinMacho.cmake: shell failed (${_serene_icu_rc})")
endif()
