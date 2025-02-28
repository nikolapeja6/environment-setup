@echo off
:: Check for elevated permissions
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires elevated privileges. Please run as an administrator.
    pause
    exit /b
)

powershell -Command "Set-ExecutionPolicy Unrestricted -Force"

powershell -File "%~dp0SetupEnvironment.ps1"