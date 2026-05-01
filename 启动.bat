@echo off
setlocal enabledelayedexpansion
title Launcher

where uv >nul 2>nul
if errorlevel 1 (
    echo.
    echo  [ERROR] uv not found. Install uv first:
    echo  pip install uv
    echo.
    exit /b 1
)

echo.
echo  Syncing project environment with uv...
echo.
uv sync -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 (
    echo.
    echo  [ERROR] uv sync failed! Check your network or uv config.
    pause
    exit /b 1
)

start "" ".venv\Scripts\pythonw.exe" gui.py
exit /b 0
