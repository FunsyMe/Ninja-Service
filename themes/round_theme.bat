@echo off

if "%~2"=="none" (
    set "ipsetString=[5] IPSET        : none     │"
) else if "%~2"=="any" (
    set "ipsetString=[5] IPSET        : any      │"
) else if "%~2"=="loaded" (
    set "ipsetString=[5] IPSET        : loaded   │"
)

if "%~3"=="включен" (
    set "gameFilterString=[6] GAMEFILTER   : включен  │"
) else (
    set "gameFilterString=[6] GAMEFILTER   : выключен │"
)

echo ─── NINJA SERVICE v%~1 ──────╮
echo  [1] Boot Zapret             │
echo  [2] Remove Zapret           │
echo  [3] Zapret Status           │
echo  [4] Zapret Diagnostics      │
echo  %ipsetString%
echo  %gameFilterString%
echo  [7] Sync IPSET              │
echo  [8] Sync HOSTS              │
echo  [9] Auto Config Scan        │
echo  [10] Sync Theme             │
echo ─────────────────────────────╯

echo.
set /p menu_choice=Ваш выбор: 