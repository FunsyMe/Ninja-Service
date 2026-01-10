$host.UI.RawUI.WindowTitle = "Ipset Update"

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

# Write File
$rootDir = Split-Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"

$hostsFile = "$rootDir\lists\ipset-all.txt"
$hostsUrl = "https://raw.githubusercontent.com/FunsyMe/Ninja-Service/main/.service/list-ipset"
$hostText = Invoke-WebRequest -Uri $hostsUrl -UseBasicParsing | Select-Object -ExpandProperty Content

try {
    Clear-Content -Path $hostsFile
    Add-Content -Path $hostsFile -Value $hostText
}
catch {
    Write-Host "[ОШИБКА] Файл ipset-all не может быть открыт. Закройте это окно, и попытайтесь снова" -ForegroundColor Red
    Write-Host "Нажмите любую кнопку для выхода..."

    [void][System.Console]::ReadKey($true)
    exit
}

Write-Host "[ОК] Файл ipset-all успешно изменен" -ForegroundColor Green
Write-Host "Нажмите любую кнопку для выхода..."
[void][System.Console]::ReadKey($true)

Start-Process $ninjaService -Verb RunAs
exit