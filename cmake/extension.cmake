macro(sdk_generate_library)
  get_filename_component(library_name ${CMAKE_CURRENT_LIST_DIR} NAME)
  message(STATUS "[register library : ${library_name}], path:${CMAKE_CURRENT_LIST_DIR}")

  set(CURRENT_STATIC_LIBRARY ${library_name})
  add_library(${library_name} STATIC)
  set_property(GLOBAL APPEND PROPERTY SDK_LIBS ${library_name})
  target_link_libraries(${library_name} PUBLIC sdk_intf_lib)
endmacro()

function(sdk_library_add_sources)
  foreach(arg ${ARGV})
    if(IS_DIRECTORY ${arg})
    message(FATAL_ERROR "sdk_library_add_sources() was called on a directory")
    endif()

    if(IS_ABSOLUTE ${arg})
    set(path ${arg})
    else()
    set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_sources(${CURRENT_STATIC_LIBRARY} PRIVATE ${path})
  endforeach()
endfunction()

function(sdk_library_add_sources_ifdef feature)
  if(${${feature}})
  sdk_library_add_sources(${ARGN})
  endif()
endfunction()

function(sdk_add_include_directories)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_include_directories(sdk_intf_lib INTERFACE ${path})
  endforeach()
endfunction()

function(sdk_add_include_directories_ifdef feature)
  if(${${feature}})
  sdk_add_include_directories(${ARGN})
  endif()
endfunction()

function(sdk_add_compile_definitions)
  target_compile_definitions(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_compile_definitions_ifdef feature)
  if(${${feature}})
  sdk_add_compile_definitions(${ARGN})
  endif()
endfunction()

function(sdk_add_compile_options)
  target_compile_options(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_compile_options_ifdef feature)
  if(${${feature}})
  sdk_add_compile_options(${ARGN})
  endif()
endfunction()

function(sdk_add_link_libraries)
  target_link_libraries(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_link_libraries_ifdef feature)
  if(${${feature}})
  sdk_add_link_libraries(${ARGN})
  endif()
endfunction()

function(sdk_add_subdirectory_ifdef feature dir)
  if(${${feature}})
    add_subdirectory(${dir})
  endif()
endfunction()


macro(project name)

  _project(${name} ASM C CXX)

  set(HEX_FILE ${__build_dir}/${name}.hex)
  set(BIN_FILE ${__build_dir}/${name}.bin)
  set(MAP_FILE ${__build_dir}/${name}.map)
  set(ASM_FILE ${__build_dir}/${name}.asm)

  add_executable(${name}.elf ${SDK_BASE}/misc/empty_file.c)
  target_link_libraries(${name}.elf sdk_intf_lib app)
  # set_target_properties(${name}.elf PROPERTIES LINK_FLAGS "-T${LINKER_SCRIPT} -Wl,-Map=${MAP_FILE}")
  # set_target_properties(${name}.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})

  set_target_properties(${name}.elf PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${__build_dir}")

  get_property(SDK_LIBS_PROPERTY GLOBAL PROPERTY SDK_LIBS)

  target_link_libraries(${name}.elf ${SDK_LIBS_PROPERTY})

  add_custom_command(TARGET ${name}.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${name}.elf> ${BIN_FILE}
  COMMAND ${CMAKE_OBJDUMP} -d -S $<TARGET_FILE:${name}.elf> >${ASM_FILE}
  # COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${mainname}.elf> ${HEX_FILE}
  COMMAND ${SIZE} $<TARGET_FILE:${name}.elf>
  COMMENT "Generate ${BIN_FILE}\r\n")

endmacro()