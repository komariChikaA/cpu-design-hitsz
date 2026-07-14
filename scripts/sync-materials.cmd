@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-materials.ps1" %*
exit /b %errorlevel%
