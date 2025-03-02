@REM ----------------------------------------------------------------------------
@REM Maven wrapper script for Windows
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' to reduce noise in the log

@echo off
@setlocal

set MAVEN_VERSION=3.9.6
set MAVEN_URL=https://dlcdn.apache.org/maven/maven-3/%MAVEN_VERSION%/binaries/apache-maven-%MAVEN_VERSION%-bin.zip
set MAVEN_DIR=%USERPROFILE%\.m2\wrapper\dists\apache-maven-%MAVEN_VERSION%
set MAVEN_EXE=%MAVEN_DIR%\apache-maven-%MAVEN_VERSION%\bin\mvn.cmd

@REM Find the project root directory
set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.

@REM Create Maven directory if it doesn't exist
if not exist "%MAVEN_DIR%" mkdir "%MAVEN_DIR%"

@REM Download Maven if it doesn't exist
if not exist "%MAVEN_EXE%" (
    echo Downloading Maven %MAVEN_VERSION%...
    
    @REM Create a temporary file for the download
    set TEMP_FILE=%TEMP%\maven-download-%RANDOM%.zip
    
    @REM Download Maven
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%MAVEN_URL%', '%TEMP_FILE%')"
    
    @REM Extract Maven
    powershell -Command "Expand-Archive -Path '%TEMP_FILE%' -DestinationPath '%MAVEN_DIR%' -Force"
    del "%TEMP_FILE%"
    
    echo Maven %MAVEN_VERSION% has been installed to %MAVEN_DIR%
)

@REM Execute Maven with the given arguments
"%MAVEN_EXE%" %*

@endlocal 