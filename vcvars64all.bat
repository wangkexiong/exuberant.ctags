@REM
@REM https://www.appveyor.com/docs/build-environment/#pre-installed-software
@REM appveyor installed VS2008/VS2010/VS2012 EXPRESS version,
@REM
@REM For VS2008, vcvarsall script does NOT accept amd64 type. We do SET path/include/lib manually.
@REM For VS2010, since WINSDK7.1 use vc10 as compiler, We do USE SDK script for settings.
@REM For VS2012, no amd64 compiler but x86_64 cross compiler provided. Use this for 64 bits compilation.
@REM
@REM From VS2013, appveyor provides the community version. They do support amd64 compiler.
@REM

IF "%VSVER%"=="9"  GOTO VC9x64
IF "%VSVER%"=="10" GOTO SDK71x64
IF "%VSVER%"=="11" GOTO VC11x64

GOTO COMMUNITY

:VC9x64
  ECHO Manually Setting vc9 amd64 compiler and Using WinSDK7.0 ...

  SET "PATH=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN\amd64;%PATH%"
  SET "PATH=C:\Program Files\Microsoft SDKs\Windows\v7.0\bin\x64;%PATH%"

  SET "INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE;%INCLUDE%"
  SET "INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\INCLUDE;%INCLUDE%"
  SET "INCLUDE=C:\Program Files\Microsoft SDKs\Windows\v7.0\include;%INCLUDE%"

  SET "LIB=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB\amd64;%LIB%"
  SET "LIB=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB\amd64;%LIB%"
  SET "LIB=C:\Program Files\Microsoft SDKs\Windows\v7.0\lib\x64;%LIB%"
  GOTO :EOF

:SDK71x64
  ECHO "Try using WINSDK7.1 together with vc10 x64 compilers ..."
  CALL "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /Release /x64
  GOTO :EOF

:VC11x64
  ECHO "Try using WINKit8.0 together with vc11 x86_64 compilers ..."

  CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" x86_amd64
  GOTO :EOF

:COMMUNITY
  IF "%VSCOMNTOOLS%"=="" (
    ECHO "VisualStudio %VSVER% is not installed..."
    EXIT /B 2000
  ) ELSE (
    ECHO "Try using VisualStudio Community VERSION ..."
    CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" amd64
    GOTO :EOF
  )

