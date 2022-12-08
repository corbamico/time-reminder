set_source_files_properties(res/rsrc.rc PROPERTIES LANGUAGE RC)
add_executable(reminder reminder.asm res/rsrc.rc)

set_target_properties(reminder PROPERTIES LINKER_LANGUAGE ASM_MASM)
set_target_properties(reminder PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS /MACHINE:X64 /nologo /LARGEADDRESSAWARE")