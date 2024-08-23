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
where resgen >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: resgen tool not found in PATH. >> "%LOG_FILE%"
    echo Please ensure .NET SDK is installed and resgen is available in PATH. >> "%LOG_FILE%"
    goto :error
)

where al >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: al tool not found in PATH. >> "%LOG_FILE%"
    echo Please ensure .NET SDK is installed and al is available in PATH. >> "%LOG_FILE%"
    goto :error
)

:: 2. Create output directories
set "OUTPUT_DIR=%CD%\CompiledResource"
set "INTERMEDIATE_DIR=%TEMP%\OqtaneResources"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%" 2>nul
if exist "%INTERMEDIATE_DIR%" rmdir /s /q "%INTERMEDIATE_DIR%"
mkdir "%INTERMEDIATE_DIR%" 2>nul

:: 3. Search for and compile .resx files
echo Searching for and compiling .resx files...
echo Searching for and compiling .resx files... >> "%LOG_FILE%"

set "FOUND_RESX=0"
for /r "%CD%" %%F in (*.resx) do (
    set /a FOUND_RESX+=1
    set "RELPATH=%%~dpF"
    set "RELPATH=!RELPATH:%CD%\=!"
    set "FILENAME=%%~nF"
    
    echo Compiling: %%F >> "%LOG_FILE%"
    echo Compiling: %%F
    
    if not exist "%INTERMEDIATE_DIR%\!RELPATH!" mkdir "%INTERMEDIATE_DIR%\!RELPATH!" 2>nul
    
    resgen "%%F" "%INTERMEDIATE_DIR%\!RELPATH!!FILENAME!.resources" >>"%LOG_FILE%" 2>&1
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

:: 4. Create resource-only assemblies
echo Creating resource-only assemblies...
echo Creating resource-only assemblies... >> "%LOG_FILE%"

for %%D in (Client Server) do (
    setlocal enabledelayedexpansion
    set "RESOURCE_COUNT=0"
    set "RESPONSE_FILE=%TEMP%\al_response_%%D.txt"
    
    echo Processing Oqtane.%%D... >> "%LOG_FILE%"
    echo Processing Oqtane.%%D...
    
    echo /t:lib > "%RESPONSE_FILE%"
    echo /culture:nl-NL >> "%RESPONSE_FILE%"
    echo /out:"%OUTPUT_DIR%\Oqtane.%%D.resources.dll" >> "%RESPONSE_FILE%"
    echo /v:1.0.0.0 >> "%RESPONSE_FILE%"

    echo Looking for .resources files in: %INTERMEDIATE_DIR%\Oqtane.%%D >> "%LOG_FILE%"
    for /r "%INTERMEDIATE_DIR%\Oqtane.%%D" %%F in (*.resources) do (
        set /a RESOURCE_COUNT+=1
        echo /embed:"%%F" >> "%RESPONSE_FILE%"
        echo Found: %%F >> "%LOG_FILE%"
    )

    echo Total .resources files found for Oqtane.%%D: !RESOURCE_COUNT! >> "%LOG_FILE%"
    echo Total .resources files found for Oqtane.%%D: !RESOURCE_COUNT!

    if !RESOURCE_COUNT! equ 0 (
        echo Error: No .resources files found for Oqtane.%%D >> "%LOG_FILE%"
        echo Error: No .resources files found for Oqtane.%%D
        goto :error
    )

    echo Executing Assembly Linker for Oqtane.%%D... >> "%LOG_FILE%"
    echo Executing Assembly Linker for Oqtane.%%D...

    echo Assembly Linker command for Oqtane.%%D: >> "%LOG_FILE%"
    echo al @"%RESPONSE_FILE%" >> "%LOG_FILE%"

    al @"%RESPONSE_FILE%" >> "%LOG_FILE%" 2>&1

    if !ERRORLEVEL! neq 0 (
        echo Error: Failed to create Oqtane.%%D.resources.dll. Error code: !ERRORLEVEL! >> "%LOG_FILE%"
        echo Error: Failed to create Oqtane.%%D.resources.dll. Error code: !ERRORLEVEL!
        echo Assembly Linker output: >> "%LOG_FILE%"
        type "%RESPONSE_FILE%" >> "%LOG_FILE%"
        goto :error
    )

    echo Assembly Linker for Oqtane.%%D completed successfully. >> "%LOG_FILE%"
    echo Assembly Linker for Oqtane.%%D completed successfully.

    del "%RESPONSE_FILE%"
    endlocal
)

echo All resource assemblies created successfully. >> "%LOG_FILE%"
echo All resource assemblies created successfully.
echo Resource assemblies are located in: %OUTPUT_DIR% >> "%LOG_FILE%"
echo Resource assemblies are located in: %OUTPUT_DIR%

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
