@echo off

echo [NinjaService v%~1]
echo ────────────────
echo 1  install Zapret
echo 2  remove Zapret
echo 3  status
echo 4  diagnostics
echo 5  ipset      : %~2
echo 6  gamefilter : %~3
echo 7  update ipset
echo 8  update hosts
echo 9  auto config
echo 10 change theme
echo ────────────────
set /p menu_choice=^> 