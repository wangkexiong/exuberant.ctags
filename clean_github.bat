@ECHO off

@REM
@REM Github Provides API for release deletion, but leaves tag untouched.
@REM And there is no API currently available for tag deletion remotely
@REM Use git command for that operation...
@REM

IF "%1"=="" (
  @ECHO "Need to tell which release to DELETE..."
  GOTO :EOF
)

IF "%GITHUB_TOKEN%"=="" (
  @ECHO "GITHUB_TOKEN NOT set... API will not work w/o this..."
  GOTO :EOF
)

SETLOCAL enabledelayedexpansion
  SET "OPERATE_RELEASE=%1"
  SET GITHUB_RELEASE=

  curl -s -H "Authorization: token %GITHUB_TOKEN%" https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases/tags/%OPERATE_RELEASE% > github_release.txt
  FOR /F "usebackq tokens=*" %%G IN (`FINDSTR /I /C:"API rate limit exceeded" github_release.txt`) DO (
    @ECHO "GITHUB API rate limit reached...... CLEAN Job skipped......"
    GOTO :EOF
  )

  FOR /F "usebackq delims=," %%G IN (`FINDSTR "\"html_url\":.*/releases/tag/.*" github_release.txt`) DO (
    FOR /F "usebackq" %%H IN (`ECHO %%G ^| FINDSTR /I "%OPERATE_RELEASE%"`) DO (
      GOTO :TAGFIND
    )
  )
  @ECHO "NO RELEASE Found..."
  GOTO :EOF

  :TAGFIND
  FOR /F "usebackq delims=," %%G IN (`FINDSTR "\"url\":.*/releases/[0-9]" github_release.txt`) DO (
    FOR /F "usebackq tokens=2 delims= " %%H IN ('%%G') DO (
      SET GITHUB_RELEASE=%%H
      GOTO :RELEASEFIND
    )
  )

  :RELEASEFIND
  IF NOT "%GITHUB_RELEASE%"=="" (
    @ECHO "DELETE %OPERATE_RELEASE%: %GITHUB_RELEASE%"
    curl -s -H "Authorization: token %GITHUB_TOKEN%" -X DELETE %GITHUB_RELEASE%

    ECHO "DELETE remote tags %OPERATE_RELEASE% ..."
    git config remote.origin.url https://%GITHUB_TOKEN%@github.com/%APPVEYOR_REPO_NAME%
    git push --delete origin "%OPERATE_RELEASE%"
    git config remote.origin.url https://github.com/%APPVEYOR_REPO_NAME%
  )
ENDLOCAL

