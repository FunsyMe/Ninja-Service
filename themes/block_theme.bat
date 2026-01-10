@echo off

if "%~2"=="none" (
    set "ipsetString=│ [5] Режим ipset  │ none                   │"
) else if "%~2"=="any" (
    set "ipsetString=│ [5] Режим ipset  │ any                    │"
) else (
    set "ipsetString=│ [5] Режим ipset  │ loaded                 │"
)

if "%~3"=="включен" (
    set "gameFilterString=│ [6] Фильтр игр   │ включен                │"
) else (
    set "gameFilterString=│ [5] Режим ipset  │ выключен               │"
)


echo ┌───────────────────────────────────────────┐
echo │             Ninja Service %~1             │
echo ├──────────────────┬────────────────────────┤
echo │ Опция            │ Текущее значение       │
echo ├──────────────────┴────────────────────────┤
echo │ [1] Добавить в автозапуск                 │
echo │ [2] Убрать из автозапуска                 │
echo │ [3] Проверить статус                      │
echo │ [4] Запустить диагностику                 │
echo ├──────────────────┬────────────────────────┤
echo %ipsetString%
echo %gameFilterString%
echo ├──────────────────┴────────────────────────┤
echo │ [7] Обновить ipset-листы                  │
echo │ [8] Обновить hosts-листы                  │
echo │ [9] Найти конфигурацию автоматически      │
echo │ [10] Обновить тему                        │
echo └───────────────────────────────────────────┘
set /p menu_choice=→ Ваш выбор: 