@echo off
:: Batch file for building ctags on AppVeyor

if %compiler%==msvc goto msvc
if %compiler%==mingw goto mingw
exit 1

:msvc
:: Using VC12
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86
set "INCLUDE=%INCLUDE%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

:: Build libiconv (MSVC port)
git clone -q --branch=master https://github.com/koron/libiconv.git C:\projects\libiconv
cd C:\projects\libiconv\msvc10
nmake NODEBUG=1 NOMSVCRT=1

:: Setup libiconv
cd C:\projects
mkdir iconv\include
mkdir iconv\lib
copy libiconv\msvc10\iconv.h   iconv\include
copy libiconv\msvc10\iconv.lib iconv\lib
copy libiconv\msvc10\iconv.dll ctags

:: Build ctags with msbuild, iconv disabled
cd C:\projects\ctags\win32
@echo on
msbuild ctags_vs2013.sln /logger:"C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll" /p:Configuration=Release
C:\cygwin\bin\file Release\ctags.exe
:: Check if it works
Release\ctags --version

:: Build ctags with nmake, iconv enabled
cd C:\projects\ctags
nmake -f mk_mvc.mak WITH_ICONV=yes ICONV_DIR=C:\projects\iconv
:: Check if it works
ctags --version

@echo off
goto :eof


:mingw
:: Using MinGW
path C:\MinGW\bin;C:\MinGW\msys\1.0\bin;%path%
@echo on
:: sh -c "autoreconf -vfi"
:: sh ./configure
:: make
:: ctags --version
:: make check

:: autoreconf doesn't seem to work on AppVeyor. Use mk_mingw.mak instead.
make -f mk_mingw.mak
ctags --version

@echo off
goto :eof
