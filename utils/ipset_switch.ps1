$host.UI.RawUI.WindowTitle = "Ipset Switch"

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
$listFile = Join-Path $rootDir "lists\ipset-all.txt"
$backupFile = "$listFile.backup"
$ipsetStatus = "null"

# Check file
$lineCount = 0
try {
    Write-Host "[ОК] Файл ipset-all найден" -ForegroundColor Green
    Write-Host ""

    $lineCount = (Get-Content $listFile -ErrorAction SilentlyContinue | Measure-Object).Count
} catch {
    Write-Host "[ОШИБКА] Файл ipset-all не найден" -ForegroundColor Red
    Write-Host ""
}

# Set Ipset Status
if ($lineCount -eq 0) {
    $ipsetStatus = "any"
} else {
    $found = Select-String -Path $listFile -Pattern "^203\.0\.113\.113/32$" -Quiet

    if ($found) {
        $ipsetStatus = "none"
    } else {
        $ipsetStatus = "loaded"
    }
}

# Witch Ipset
switch ($ipsetStatus) {
    "loaded" {
        if (!(Test-Path $backupFile)) {
            Rename-Item $listFile "ipset-all.txt.backup"
        } else {
            Remove-Item $backupFile  -Force -ErrorAction SilentlyContinue
            Rename-Item $listFile "ipset-all.txt.backup"
        }

        Set-Content $listFile @"
203.0.113.113/32
103.140.28.0/23
128.116.0.0/17
128.116.0.0/24
128.116.1.0/24
128.116.5.0/24
128.116.11.0/24
128.116.13.0/24
128.116.21.0/24
128.116.22.0/24
128.116.31.0/24
128.116.32.0/24
128.116.33.0/24
128.116.35.0/24
128.116.44.0/24
128.116.45.0/24
128.116.46.0/24
128.116.48.0/24
128.116.50.0/24
128.116.51.0/24
128.116.53.0/24
128.116.54.0/24
128.116.55.0/24
128.116.56.0/24
128.116.57.0/24
128.116.63.0/24
128.116.64.0/24
128.116.67.0/24
128.116.74.0/24
128.116.80.0/24
128.116.81.0/24
128.116.84.0/24
128.116.86.0/24
128.116.87.0/24
128.116.88.0/24
128.116.95.0/24
128.116.97.0/24
128.116.99.0/24
128.116.102.0/24
128.116.104.0/24
128.116.105.0/24
128.116.115.0/24
128.116.116.0/24
128.116.117.0/24
128.116.119.0/24
128.116.120.0/24
128.116.123.0/24
128.116.127.0/24
141.193.3.0/24
205.201.62.0/24
"@
        Write-Host "[ОК] Ipset изменен на none" -ForegroundColor Green
        Write-Host "Нажмите любую клавишу для выхода..."
        [void][System.Console]::ReadKey($true)

        Start-Process $ninjaService -Verb RunAs
        exit 1
    }
    "none" {
        Set-Content $listFile -Value $null

        Write-Host "[ОК] Ipset изменен на any" -ForegroundColor Green
        Write-Host "Нажмите любую клавишу для выхода..."
        [void][System.Console]::ReadKey($true)

        Start-Process $ninjaService -Verb RunAs
        exit 1
    }
    "any" {
        if (Test-Path $backupFile) {
            Remove-Item $listFile -Force -ErrorAction SilentlyContinue
            Rename-Item $backupFile "ipset-all.txt"

            Write-Host "[ОК] Ipset изменен на loaded" -ForegroundColor Green
        } else {
            Write-Host "[ОШИБКА]: Файл бэкапа не найден. Обновите лист ipset из Ninja Service, а затем повтроите попытку" -ForegroundColor Red
        }

        Write-Host "Нажмите любую клавишу для выхода..."
        [void][System.Console]::ReadKey($true)

        Start-Process $ninjaService -Verb RunAs
        exit 1
    }
}