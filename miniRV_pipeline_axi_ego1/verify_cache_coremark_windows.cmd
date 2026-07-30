@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify_cache_coremark_windows.ps1"
if errorlevel 1 (
    echo.
    echo Verification failed.
    exit /b 1
)

echo.
echo Verification completed successfully.
exit /b 0
