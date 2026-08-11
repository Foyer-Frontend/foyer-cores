# Helpers used by per-core CMake fragments under cores/<name>.cmake.
#
# A core recipe fetches a libretro core's source tree, compiles its C/C++
# sources into a STATIC library named `core_<name>`, and exposes the include
# directories the libretro frontend needs to call into it.
#
# Each per-core file is responsible for the core-specific source list,
# defines, and any quirks. This file just collects the common boilerplate.

# foyer_core_static_library(
#     NAME           <core_name>
#     SOURCES        <files...>
#     INCLUDE_DIRS   <dirs...>
#     COMPILE_DEFS   <-Dfoo=1...>
#     COMPILE_OPTS   <-Wfoo...>
# )
#
# Produces an INTERFACE-public static lib named `core_<NAME>`.
function(foyer_core_static_library)
    cmake_parse_arguments(C
        ""
        "NAME"
        "SOURCES;INCLUDE_DIRS;COMPILE_DEFS;COMPILE_OPTS"
        ${ARGN})

    if (NOT C_NAME)
        message(FATAL_ERROR "foyer_core_static_library: NAME required")
    endif()
    if (NOT C_SOURCES)
        message(FATAL_ERROR "foyer_core_static_library(${C_NAME}): SOURCES required")
    endif()

    # Filter to existing files so an upstream rename/removal doesn't hard-fail
    # configure. Warn per missing file; fail only when nothing remains.
    set(_filtered "")
    foreach(_src IN LISTS C_SOURCES)
        if (EXISTS "${_src}")
            list(APPEND _filtered "${_src}")
        else()
            message(WARNING "foyer_core_static_library(${C_NAME}): skipping missing ${_src}")
        endif()
    endforeach()
    if (NOT _filtered)
        message(FATAL_ERROR "foyer_core_static_library(${C_NAME}): no sources exist after filtering")
    endif()

    set(_target core_${C_NAME})
    add_library(${_target} STATIC ${_filtered})

    target_include_directories(${_target} PUBLIC ${C_INCLUDE_DIRS})

    if (C_COMPILE_DEFS)
        target_compile_definitions(${_target} PRIVATE ${C_COMPILE_DEFS})
    endif()

    # Cores are "trust me" C99 — silence warnings that aren't actionable.
    target_compile_options(${_target} PRIVATE
        -w
        ${C_COMPILE_OPTS}
    )

    set_target_properties(${_target} PROPERTIES
        C_STANDARD            99
        C_STANDARD_REQUIRED   ON
        POSITION_INDEPENDENT_CODE ON
    )

    set(FOYER_CORE_TARGET ${_target} PARENT_SCOPE)
endfunction()

# Helper for recipes that call add_library directly (nestopia, snes9x, etc.).
# Filters SOURCES to existing files with a warning, same semantics as above.
function(foyer_filter_existing_sources out_var)
    set(_filtered "")
    foreach(_src IN LISTS ARGN)
        if (EXISTS "${_src}")
            list(APPEND _filtered "${_src}")
        else()
            message(WARNING "foyer_filter_existing_sources: skipping missing ${_src}")
        endif()
    endforeach()
    set(${out_var} "${_filtered}" PARENT_SCOPE)
endfunction()
