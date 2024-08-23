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

:: Check for resgen and al tools
where resgen >nul 2>&1 && where al >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: resgen or al tool not found in PATH. >> "%LOG_FILE%"
    echo Please ensure .NET SDK is installed and both tools are available in PATH. >> "%LOG_FILE%"
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

    rem Remove .resx from the output filename
    set "OUTPUT_NAME=!PREFIX!!RELPATH!%%~nF.resources"
    resgen "%%F" "!TARGET_DIR!\!OUTPUT_NAME!" >>"%LOG_FILE%" 2>&1
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

:: 4. Concatenate .resources files into single files for Client and Server
echo Concatenating .resources files...
echo Concatenating .resources files... >> "%LOG_FILE%"

set "CLIENT_RESOURCES=%OUTPUT_DIR%\Oqtane.Client.resources"
set "SERVER_RESOURCES=%OUTPUT_DIR%\Oqtane.Server.resources"

if exist "%CLIENT_RESOURCES%" del "%CLIENT_RESOURCES%"
if exist "%SERVER_RESOURCES%" del "%SERVER_RESOURCES%"

:: Concatenate client resources
echo Concatenating client resources... >> "%LOG_FILE%"
(for %%F in ("%TEMP_CLIENT_DIR%\*.resources") do (
    type "%%F"
)) > "%CLIENT_RESOURCES%"
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to concatenate client resources >> "%LOG_FILE%"
    echo Error: Failed to concatenate client resources
    goto :error
)
echo Client resources concatenated successfully >> "%LOG_FILE%"

:: Concatenate server resources
echo Concatenating server resources... >> "%LOG_FILE%"
(for %%F in ("%TEMP_SERVER_DIR%\*.resources") do (
    type "%%F"
)) > "%SERVER_RESOURCES%"
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to concatenate server resources >> "%LOG_FILE%"
    echo Error: Failed to concatenate server resources
    goto :error
)
echo Server resources concatenated successfully >> "%LOG_FILE%"

if exist "%CLIENT_RESOURCES%" (
    echo Concatenated client resources file: %CLIENT_RESOURCES% >> "%LOG_FILE%"
    echo Concatenated client resources file: %CLIENT_RESOURCES%
) else (
    echo Warning: Client resources file was not created >> "%LOG_FILE%"
    echo Warning: Client resources file was not created
)

if exist "%SERVER_RESOURCES%" (
    echo Concatenated server resources file: %SERVER_RESOURCES% >> "%LOG_FILE%"
    echo Concatenated server resources file: %SERVER_RESOURCES%
) else (
    echo Warning: Server resources file was not created >> "%LOG_FILE%"
    echo Warning: Server resources file was not created
)

:: 5. Create satellite assemblies using al.exe
echo Creating satellite assemblies...
echo Creating satellite assemblies... >> "%LOG_FILE%"

set "Culture=nl-NL"
set "Version=5.1.2.0"
set "CLIENT_DLL=%OUTPUT_DIR%\Oqtane.Client.resources.dll"
set "SERVER_DLL=%OUTPUT_DIR%\Oqtane.Server.resources.dll"

:: Debug information
echo Debug: Current directory >> "%LOG_FILE%"
cd >> "%LOG_FILE%"
echo Debug: AL.exe version >> "%LOG_FILE%"
al.exe /? >> "%LOG_FILE%" 2>&1
echo Debug: Client resources file >> "%LOG_FILE%"
dir "%CLIENT_RESOURCES%" >> "%LOG_FILE%"
echo Debug: Server resources file >> "%LOG_FILE%"
dir "%SERVER_RESOURCES%" >> "%LOG_FILE%"

:: Create client satellite assembly
echo Creating client satellite assembly... >> "%LOG_FILE%"
echo AL.exe command for client: >> "%LOG_FILE%"
echo al.exe /out:"%CLIENT_DLL%" /embed:"%CLIENT_RESOURCES%" /culture:"%Culture%" /version:%Version% /target:library /verbose >> "%LOG_FILE%"

al.exe /out:"%CLIENT_DLL%" /embed:"%CLIENT_RESOURCES%" /culture:"%Culture%" /version:%Version% /target:library /verbose >> "%LOG_FILE%" 2>&1
echo AL.exe exit code: %ERRORLEVEL% >> "%LOG_FILE%"

:: Create server satellite assembly
echo Creating server satellite assembly... >> "%LOG_FILE%"
echo AL.exe command for server: >> "%LOG_FILE%"
echo al.exe /out:"%SERVER_DLL%" /embed:"%SERVER_RESOURCES%" /culture:"%Culture%" /version:%Version% /target:library /verbose >> "%LOG_FILE%"

al.exe /out:"%SERVER_DLL%" /embed:"%SERVER_RESOURCES%" /culture:"%Culture%" /version:%Version% /target:library /verbose >> "%LOG_FILE%" 2>&1
echo AL.exe exit code: %ERRORLEVEL% >> "%LOG_FILE%"

if exist "%CLIENT_DLL%" (
    echo Created client satellite assembly: %CLIENT_DLL% >> "%LOG_FILE%"
    echo Created client satellite assembly: %CLIENT_DLL%
) else (
    echo Warning: Client satellite assembly was not created >> "%LOG_FILE%"
    echo Warning: Client satellite assembly was not created
)

if exist "%SERVER_DLL%" (
    echo Created server satellite assembly: %SERVER_DLL% >> "%LOG_FILE%"
    echo Created server satellite assembly: %SERVER_DLL%
) else (
    echo Warning: Server satellite assembly was not created >> "%LOG_FILE%"
    echo Warning: Server satellite assembly was not created
)


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
