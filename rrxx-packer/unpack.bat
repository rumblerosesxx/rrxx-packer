@echo off
set PowerShellScriptPath=%~dp0resources\unpack.ps1
set FilePath=%1

if "%FilePath%"=="" (
    echo Drag and drop a file onto this batch file.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File %PowerShellScriptPath% -file %FilePath%
pause

