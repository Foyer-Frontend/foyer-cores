# bin2c.cmake — convert a binary file to a C source containing
# `unsigned char <name>[] = { ... }` plus `unsigned int <name>_length`.
#
# Invoked from add_custom_command via:
#   cmake -DINPUT=foo.bin -DOUTPUT=foo.c -DNAME=foo -P bin2c.cmake
#
# Avoids depending on `xxd -n` which isn't available on every devkitPro
# container image (the -n flag was added in vim 8.0).

if(NOT INPUT OR NOT OUTPUT OR NOT NAME)
    message(FATAL_ERROR "bin2c.cmake: INPUT, OUTPUT, and NAME must be set.")
endif()

file(READ "${INPUT}" hex HEX)
string(LENGTH "${hex}" hex_len)
math(EXPR byte_count "${hex_len} / 2")

set(content "/* Generated from ${INPUT} by bin2c.cmake — do not edit. */\n\n")
string(APPEND content "const unsigned char ${NAME}[] = {")

set(idx 0)
set(col 0)
while(idx LESS hex_len)
    string(SUBSTRING "${hex}" ${idx} 2 byte)
    if(col EQUAL 0)
        string(APPEND content "\n   ")
    endif()
    string(APPEND content " 0x${byte},")
    math(EXPR idx "${idx} + 2")
    math(EXPR col "${col} + 1")
    if(col EQUAL 12)
        set(col 0)
    endif()
endwhile()

string(APPEND content "\n};\n\n")
string(APPEND content "const unsigned int ${NAME}_length = ${byte_count};\n")

file(WRITE "${OUTPUT}" "${content}")
