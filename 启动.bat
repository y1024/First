@echo off
setlocal enabledelayedexpansion
chcp 437 >nul
title First - Launcher
cd /d "%~dp0"

set "CHOICE_FILE=.launch_choice"

:: ══════════════════════════════════════════
::  Read saved choice and launch directly
:: ══════════════════════════════════════════
if exist "%CHOICE_FILE%" (
    set /p SAVED=<"%CHOICE_FILE%"
    if "!SAVED!"=="uv" goto :RUN_UV
    if "!SAVED!"=="system" goto :RUN_SYSTEM
)

:: ══════════════════════════════════════════
::  First run: ask user to choose environment
:: ══════════════════════════════════════════
echo.
echo  ============================================
echo   First ^| Launch Configuration
echo  ============================================
echo.
echo   Please choose how to run First:
echo.
echo   [1] uv virtual environment  (Recommended)
echo       Isolated dependencies, won't affect system Python
echo.
echo   [2] System Python
echo       Use system-installed Python directly
echo.
set /p CHOICE="  Enter choice (1/2): "

if "%CHOICE%"=="1" goto :SETUP_UV
if "%CHOICE%"=="2" goto :SETUP_SYSTEM
echo  Invalid choice. Exiting.
pause
exit /b 1

:: ══════════════════════════════════════════
::  Branch: uv virtual environment
:: ══════════════════════════════════════════
:SETUP_UV
where uv >nul 2>nul
if errorlevel 1 (
    echo.
    echo  [WARNING] uv not found on this system.
    echo.
    set /p INSTALLUV="  Install uv now? (pip install uv) [Y/N]: "
    if /i "!INSTALLUV!"=="Y" (
        echo  Installing uv...
        pip install uv
        if errorlevel 1 (
            echo  [ERROR] uv installation failed. Please run manually: pip install uv
            pause
            exit /b 1
        )
    ) else (
        echo  Cancelled.
        pause
        exit /b 0
    )
)

:RUN_UV
echo.
echo  Syncing uv virtual environment...
echo.
uv sync -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 (
    echo.
    echo  [ERROR] uv sync failed. Check network or pyproject.toml.
    pause
    exit /b 1
)
echo uv>"%CHOICE_FILE%"
start "" ".venv\Scripts\pythonw.exe" gui.py
exit /b 0

:: ══════════════════════════════════════════
::  Branch: System Python
:: ══════════════════════════════════════════
:SETUP_SYSTEM
where python >nul 2>nul
if errorlevel 1 (
    echo.
    echo  [ERROR] python not found. Please install Python 3.9+ first.
    pause
    exit /b 1
)

echo.
echo  Checking dependencies...
python -c "import frida, websockets, google.protobuf, PySide6, Crypto" >nul 2>nul
if errorlevel 1 (
    echo  Some dependencies are missing.
    echo.
    set /p INSTALLDEPS="  Install dependencies now? (pip install -r requirements.txt) [Y/N]: "
    if /i "!INSTALLDEPS!"=="Y" (
        echo  Installing dependencies...
        pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
        if errorlevel 1 (
            echo  [ERROR] Installation failed. Try manually: pip install -r requirements.txt
            pause
            exit /b 1
        )
    ) else (
        echo  Cancelled.
        pause
        exit /b 0
    )
)

:RUN_SYSTEM
echo system>"%CHOICE_FILE%"
start "" pythonw gui.py
exit /b 0
