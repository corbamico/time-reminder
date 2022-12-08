@echo off

set appname=reminder

if exist %1.obj del %appname%.obj
if exist %1.exe del %appname%.exe

\masm64\bin64\rc.exe res\rsrc.rc

\masm64\bin64\ml64.exe /c /nologo %appname%.asm

\masm64\bin64\link.exe /SUBSYSTEM:WINDOWS /MACHINE:X64 /LARGEADDRESSAWARE %appname%.obj res\rsrc.res

dir %appname%.*

pause
