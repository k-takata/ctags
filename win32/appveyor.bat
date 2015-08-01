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
msbuild ctags_vs2013.sln /logger:"C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll" /p:Configuration=Release
:: Check if it works
Release\ctags --version
:: Build ctags with nmake, iconv enabled
cd C:\projects\ctags
nmake -f mk_mvc.mak WITH_ICONV=yes ICONV_DIR=C:\projects\iconv
:: Check if it works
ctags --version
goto :eof

:mingw
path C:\MinGW\bin;C:\MinGW\msys\1.0\bin;%path%
:: sh -c "autoreconf -vfi"
sh ./configure
make
ctags --version
goto :eof
