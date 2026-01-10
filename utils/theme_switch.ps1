$host.UI.RawUI.WindowTitle = "Theme Switch"

# Check Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ОШИБКА] Запустите от имени администратора" -ForegroundColor Red
    Write-Host "Нажмите любую кнопку для выхода..."
    [void][System.Console]::ReadKey($true)

    Start-Process $ninjaService -Verb RunAs
    exit
} else {
    Write-Host "[OK] Обнаружены права администратора" -ForegroundColor Green
}

$rootDir = Split-Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"
$themeFile = Join-Path $rootDir "bin\ninja_theme.txt"

# Set Theme
function Set-Theme {
    param (
        [string]$Theme
    )

    Set-Content $themeFile $Theme
    Write-Host "[ОК] Тема успешно установлена" -ForegroundColor Green
}

# User Input
Write-Host "[ВВОД] Введите номер темы (цифра)" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. default_theme"
Write-Host "2. neon_theme"
Write-Host "3. terminal_theme"
Write-Host "4. block_theme"
Write-Host "5. minimalist_theme"
Write-Host "6. round_theme"

Write-Host ""
Write-Host "[ВВОД] Ваш выбор [1-6]: " -ForegroundColor Yellow -NoNewline
$themeNumber = Read-Host

switch ($themeNumber) {
    "1" { Set-Theme -Theme "default_theme" }
    "2" { Set-Theme -Theme "neon_theme" }
    "3" { Set-Theme -Theme "terminal_theme" }
    "4" { Set-Theme -Theme "block_theme" }
    "5" { Set-Theme -Theme "minimalist_theme" }
    "6" { Set-Theme -Theme "round_theme" }

    default {
        Write-Host "[ОШИБКА] Невеный выбор" -ForegroundColor Red
        Write-Host "Нажмите любую кнопку для выхода..."

        [void][System.Console]::ReadKey($true)

        Start-Process $ninjaService -Verb RunAs
        exit
    }
}

Write-Host "Нажмите любую кнопку для выхода..."
[void][System.Console]::ReadKey($true)

Start-Process $ninjaService -Verb RunAs
exit