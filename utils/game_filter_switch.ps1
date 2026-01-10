$host.UI.RawUI.WindowTitle = "GameFilter Switch"

# Check Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ОШИБКА] Запустите от имени администратора" -ForegroundColor Red
    Write-Host "Нажмите любую клавишу для выхода..."
    [void][System.Console]::ReadKey($true)

    Start-Process $ninjaService -Verb RunAs
    exit 1
} else {
    Write-Host "[OK] Обнаружены права администратора" -ForegroundColor Green
}

$rootDir = Split-Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"
$gameFilterFile = Join-Path $rootDir "bin\game_filter.enabled"

# Switch Game Filter
if (Test-Path $gameFilterFile) {
    Remove-Item $gameFilterFile -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] GameFilter выключен" -ForegroundColor Green
    Write-Host ""
} else {
    New-Item $gameFilterFile -ItemType File > $null
    Write-Host "[OK] GameFilter включен" -ForegroundColor Green
    Write-Host ""
}

Write-Host "[ИНФО] Перезапустите Zapret в ручную, для применения изменений" -ForegroundColor Cyan
Write-Host "Нажмите любую клавишу для выхода..."
[void][System.Console]::ReadKey($true)

Start-Process $ninjaService -Verb RunAs
exit 1