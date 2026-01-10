@echo off

echo ========= Ninja Service v%~1 =========
echo.

echo [1] Установить Zapret в Авто-Запуск 
echo [2] Удалить Zapret из Авто-Запуска  
echo [3] Проверить Статус Zapret         
echo [4] Запустить Диагностику Zapret    
echo [5] Изменить ipset [%~2]
echo [6] Изменить GameFilter [%~3]
echo [7] Обновить лист ipset             
echo [8] Обновить лист hosts             
echo [9] Запустить Авто-Поиск кофнига 
echo [10] Изменить тему   

echo.
set /p menu_choice=[?] Введите выбор [1-10]: 