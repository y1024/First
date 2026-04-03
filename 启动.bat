@echo off
setlocal enabledelayedexpansion
title Launcher

:: Skip dependency check if already installed before
if exist ".deps_installed" goto :launch

:: Check if requirements.txt exists
if not exist "requirements.txt" (
    echo.
    echo  [WARNING] requirements.txt not found!
    echo.
    set /p "choice=  Skip dependency install and launch directly? [Y/N]: "
    echo.
    if /i "!choice!"=="Y" goto :launch
    echo  Cancelled.
    timeout /t 2 >nul
    exit /b 1
)

:: requirements.txt found, ask to install
echo.
echo  [OK] requirements.txt found.
echo.
set /p "install=  Install dependencies? [Y/N]: "
echo.
if /i "!install!"=="Y" (
    echo  Installing via Tsinghua mirror, please wait...
    echo.
    pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
    if errorlevel 1 (
        echo.
        echo  [ERROR] Installation failed! Check your network or pip config.
        pause
        exit /b 1
    )
    echo.
    echo  [OK] Done! Will skip this step on next launch.
    echo. > .deps_installed
    echo.
) else (
    echo. > .deps_installed
)

:: Launch gui.py without command window
:launch
start "" pythonw gui.py
exit /b 0
