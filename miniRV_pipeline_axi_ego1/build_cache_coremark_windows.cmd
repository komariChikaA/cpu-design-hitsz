@echo off
setlocal
cd /d "%~dp0"

where vivado.exe >nul 2>nul
if errorlevel 1 (
    echo Vivado was not found in PATH.
    echo Open miniRV.xpr in Vivado 2023.2 and run:
    echo   source rebuild_ego1.tcl
    exit /b 1
)

if not exist "outputs\vivado" mkdir "outputs\vivado"

vivado.exe -mode batch ^
    -source "%~dp0build_cache_coremark_windows.tcl" ^
    -log "%~dp0outputs\vivado\windows_build.log" ^
    -journal "%~dp0outputs\vivado\windows_build.jou"

if errorlevel 1 (
    echo.
    echo Vivado build failed. Check outputs\vivado\windows_build.log.
    exit /b 1
)

echo.
echo Build completed.
echo Bitstream: outputs\vivado\miniRV_pipeline_axi_ego1.bit
exit /b 0
