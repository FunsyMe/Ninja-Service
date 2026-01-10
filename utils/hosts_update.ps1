$host.UI.RawUI.WindowTitle = "Discord Host"

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

# Download File
$hostsDir = "$env:SystemRoot\System32\drivers\etc\"
$rootDir = Split-Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"
$hostsFile = Join-Path $hostsDir "hosts"
$backupFile = Join-Path $hostsDir "hosts.backup"

$hostsUrl = "https://raw.githubusercontent.com/FunsyMe/Ninja-Service/main/.service/list-hosts"
$hostText = Invoke-WebRequest -Uri $hostsUrl -UseBasicParsing | Select-Object -ExpandProperty Content

# Write File
if (!(Test-Path $backupFile)) {
    Rename-Item $hostsFile "hosts.backup"
} else {
    Remove-Item $backupFile
    Rename-Item $hostsFile "hosts.backup"
}
New-Item $hostsFile > $null
Clear-Content -Path $hostsFile
    
try {
    Add-Content -Path $hostsFile -Value $hostText
}
catch {
    Write-Host "[ОШИБКА] Файл host не может быть открыт. Закройте это окно, и попытайтесь снова" -ForegroundColor Red
    Write-Host "Нажмите любую кнопку для выхода..."
    [void][System.Console]::ReadKey($true)

    Start-Process $ninjaService -Verb RunAs
    exit
}

Write-Host "[ОК] Сделан бэк-ап файла hosts" -ForegroundColor Green
Write-Host "[ОК] Файл host успешно изменен" -ForegroundColor Green
Write-Host "Нажмите любую кнопку для выхода..."
[void][System.Console]::ReadKey($true)

Start-Process $ninjaService -Verb RunAs
exit