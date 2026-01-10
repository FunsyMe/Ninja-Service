@echo off

echo ^> Ninja Service v%~1 ^<
echo.

echo [Служба]
echo   1. Добавить в автозапуск
echo   2. Убрать из автозапуска
echo   3. Статус службы
echo   4. Диагностика
echo.

echo [Настройки]
echo   5. Режим ipset       (%~2)
echo   6. Фильтр игр        (%~3)
echo.

echo [Обновления]
echo   7. Обновить ipset
echo   8. Обновить hosts
echo   9. Автопоиск конфига
echo   10. Обновить тему

echo.
set /p menu_choice=--^> Ваш выбор (1-10): 