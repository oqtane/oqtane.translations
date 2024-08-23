@echo off
setlocal enabledelayedexpansion

:: Log file setup
set "LOG_FILE=%CD%\compile_log.txt"
echo Compilation Log > "%LOG_FILE%"
echo Current Directory: %CD% >> "%LOG_FILE%"
echo Timestamp: %DATE% %TIME% >> "%LOG_FILE%"

:: 1. Set up the Visual Studio 2022 Developer Command Prompt environment
echo Setting up Visual Studio 2022 environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to set up Visual Studio 2022 Developer Command Prompt environment. >> "%LOG_FILE%"
    echo Please ensure Visual Studio 2022 is installed correctly. >> "%LOG_FILE%"
    goto :error
)

:: Check for resgen tool
where resgen >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: resgen tool not found in PATH. >> "%LOG_FILE%"
    echo Please ensure .NET SDK is installed and resgen is available in PATH. >> "%LOG_FILE%"
    goto :error
)

:: 2. Create output directories
set "OUTPUT_DIR=%CD%\CompiledResource"
set "TEMP_CLIENT_DIR=%TEMP%\OqtaneResources\Client"
set "TEMP_SERVER_DIR=%TEMP%\OqtaneResources\Server"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%" 2>nul
if exist "%TEMP_CLIENT_DIR%" rmdir /s /q "%TEMP_CLIENT_DIR%"
if exist "%TEMP_SERVER_DIR%" rmdir /s /q "%TEMP_SERVER_DIR%"
mkdir "%TEMP_CLIENT_DIR%" 2>nul
mkdir "%TEMP_SERVER_DIR%" 2>nul

:: 3. Search for and compile .resx files
echo Searching for and compiling .resx files...
echo Searching for and compiling .resx files... >> "%LOG_FILE%"

set "FOUND_RESX=0"
for /r "%CD%" %%F in (*.resx) do (
    set /a FOUND_RESX+=1
    set "RELPATH=%%~dpF"
    set "RELPATH=!RELPATH:%CD%\=!"

    rem Determine if the file is for Client or Server
    if "!RELPATH:Oqtane.Client\=!" neq "!RELPATH!" (
        set "TARGET_DIR=%TEMP_CLIENT_DIR%"
        set "RELPATH=!RELPATH:Oqtane.Client\=!"
        set "PREFIX=Oqtane_Resources_"
    ) else if "!RELPATH:Oqtane.Server\=!" neq "!RELPATH!" (
        set "TARGET_DIR=%TEMP_SERVER_DIR%"
        set "RELPATH=!RELPATH:Oqtane.Server\=!"
        set "PREFIX=Oqtane_Resources_"
    ) else (
        echo Skipping file outside of Client or Server directories: %%F >> "%LOG_FILE%"
        echo Skipping file outside of Client or Server directories: %%F
        continue
    )

    set "RELPATH=!RELPATH:\=_!"
    set "RELPATH=!RELPATH:Resources_=!"

    echo Compiling: %%F >> "%LOG_FILE%"
    echo Compiling: %%F

    rem Remove leading backslash if present in RELPATH
    if "!RELPATH:~0,1!"=="\" set "RELPATH=!RELPATH:~1!"

    resgen "%%F" "!TARGET_DIR!\!PREFIX!!RELPATH!%%~nxF.resources" >>"%LOG_FILE%" 2>&1
    if !ERRORLEVEL! neq 0 (
        echo Error: Failed to compile %%F >> "%LOG_FILE%"
        echo Error: Failed to compile %%F
        goto :error
    )
)

echo Total .resx files processed: !FOUND_RESX! >> "%LOG_FILE%"
echo Total .resx files processed: !FOUND_RESX!

if !FOUND_RESX! equ 0 (
    echo Error: No .resx files found. >> "%LOG_FILE%"
    echo Error: No .resx files found.
    goto :error
)

echo All .resx files compiled successfully. >> "%LOG_FILE%"
echo All .resx files compiled successfully.
echo Compiled client resource files are located in: %TEMP_CLIENT_DIR% >> "%LOG_FILE%"
echo Compiled client resource files are located in: %TEMP_CLIENT_DIR%
echo Compiled server resource files are located in: %TEMP_SERVER_DIR% >> "%LOG_FILE%"
echo Compiled server resource files are located in: %TEMP_SERVER_DIR%

goto :end

:error
echo.
echo An error occurred during the compilation process.
echo Please check the log file for more details: %LOG_FILE%

:end
echo.
echo Press any key to exit...
pause >nul
exit /b
