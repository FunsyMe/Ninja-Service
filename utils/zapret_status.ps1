$host.UI.RawUI.WindowTitle = "Zapret Status"

# Test Service
function Test-Service {
    param (
        [string]$ServiceName
    )
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($service) {
        $status = $service.Status
        if ($status -eq "Running") {
            Write-Host "[ОК] `"$ServiceName`" успешно работает" -ForegroundColor Green
        } elseif ($status -eq "StopPending") {
            Write-Host "$ServiceName находится в состоянии ожидания, что может быть вызвано конфликтом с другим zapret. Запустите диагностику, чтобы попытаться устранить проблему" -ForegroundColor Red
        } else {
            Write-Host "[ОШИБКА] `"$ServiceName`" не работает" -ForegroundColor Red
        }
    } else {
        Write-Host "[ОШИБКА] Сервис `"$ServiceName`" не найден" -ForegroundColor Red
    }
}

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
    Write-Host ""
}

# Check Config
$regValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\zapret" -Name "zapret-discord-youtube" -ErrorAction SilentlyContinue

if ($regValue) {
    Write-Host "[ИНФО] Идет проверка bat-файла `"$($regValue.'zapret-discord-youtube')`"" -ForegroundColor Cyan
}

# Call Test
Test-Service -ServiceName "zapret"
Test-Service -ServiceName "WinDivert"

# Chech WinDevert64


$rootDir = Split-Path -Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"
$binPath = Join-Path -Path $rootDir -ChildPath "bin\"

if (-not (Test-Path -Path "$binPath\WinDivert64.sys")) {
    Write-Host "[ОШИБКА] WinDivert64.sys не найден" -ForegroundColor Red
}

# Check Zapret
$zapret = Get-Process -Name "winws" -ErrorAction SilentlyContinue
Write-Host ""

if ($zapret) {
    Write-Host "[ОК] Zapret успешно работает" -ForegroundColor Green
} else {
    Write-Host "[ОШИБКА] Zapret не работает" -ForegroundColor Red
}

Write-Host ""
Write-Host "Нажмите любую кнопку для выхода..."
[void][System.Console]::ReadKey($true)

Start-Process $ninjaService -Verb RunAs
exit