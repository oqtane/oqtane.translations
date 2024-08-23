@echo off
setlocal enabledelayedexpansion

rem Set your desired output culture (e.g., en-US)
set "Culture=nl-NL"

rem Specify the root folder containing your .resources files
set "RootFolder=C:\Users\leigh\AppData\Local\Temp\OqtaneResources\Oqtane.Client\Resources"

:: 1. Set up the Visual Studio 2022 Developer Command Prompt environment
echo Setting up Visual Studio 2022 environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Unable to set up Visual Studio 2022 Developer Command Prompt environment. >> "%LOG_FILE%"
    echo Please ensure Visual Studio 2022 is installed correctly. >> "%LOG_FILE%"
    goto :error
)

call :treeProcess
goto :eof

:treeProcess
rem Process each .resources file in this directory
for %%f in ("%RootFolder%\*.resources") do (
    echo Processing file: %%~nxf
    al.exe /out:"%RootFolder%\MySatelliteAssembly.!Culture!.dll" /embed:"%%f" /culture:"%Culture%"
)

rem Recurse into subdirectories
for /D %%d in ("%RootFolder%\*") do (
    cd "%%d"
    call :treeProcess
    cd ..
)
exit /b
