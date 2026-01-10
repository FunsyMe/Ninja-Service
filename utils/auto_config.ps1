$host.UI.RawUI.WindowTitle = "Авто Поиск"

# Dir Variables
$rootDir = Split-Path $PSScriptRoot -Parent
$ninjaService = Join-Path $rootDir "ninja_service.bat"
$utilsDir = Join-Path $rootDir "utils"
$preConfigsDir = Join-Path $rootDir "pre-configs"

# Check Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ОШИБКА] Запустите от имени администратора" -ForegroundColor Red
} else {
    Write-Host "[OK] Обнаружены права администратора" -ForegroundColor Green
}

# Check curl
if (-not (Get-Command "curl.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "[ОШИБКА] Не найден curl.exe" -ForegroundColor Red
} else {
    Write-Host "[OK] Найден curl.exe" -ForegroundColor Green
}

# Target Sites
$targets = @(
    @{ Name = "Discord"; Url = "https://discord.com"; Ping = "discord.com" }
    @{ Name = "YouTube"; Url = "https://www.youtube.com"; Ping = "youtube.com" }
    @{ Name = "Google";  Url = "https://www.google.com";  Ping = "google.com" }
    @{ Name = "Cloudflare DNS"; Url = $null; Ping = "1.1.1.1" }
)

# Tatget Configs
$batFiles = Get-ChildItem $preConfigsDir -Filter "*.bat" |
            Sort-Object Name

if (-not $batFiles) {
    Write-Host "[ОШИБКА] Ненайдены general*.bat файлы" -ForegroundColor Red
    Write-Host "Нажмите любую клавишу для выхода..." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($true)
    
    Start-Process $ninjaService -Verb RunAs
    exit 1
}

# Stop Zapret
function Stop-Zapret {
    Get-Process winws -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host ""
Write-Host "[ИНФО] Прохождение теста может занять время. Пожалуйста, подождите" -ForegroundColor Cyan
Write-Host "[ИНФО] Идет Авто-Поиск пре-конфига Zapret" -ForegroundColor Cyan
Write-Host ""

$configNum = 1
foreach ($file in $batFiles) {
    Write-Host "Идет проверка конфига $($file.Name) " -ForegroundColor DarkCyan -NoNewline
    Write-Host "[$configNum/$($batFiles.Count)]" -ForegroundColor Yellow

    Stop-Zapret
    Write-Host " > Запуск конфига..." -ForegroundColor DarkGray

    $proc = Start-Process cmd.exe `
        -ArgumentList "/c `"$($file.FullName)`"" `
        -WorkingDirectory $rootDir `
        -WindowStyle Minimized `
        -PassThru

    Start-Sleep -Milliseconds 800
    Write-Host " > Запуск теста..." -ForegroundColor DarkGray
    Write-Host ""

    $configOutput = @()
    $httpResult = 0

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, 12)
    $runspacePool.Open()

    $scriptBlock = {
        param($t)

        $segments = @()
        $segments += @{ Text = " $($t.Name.PadRight(20))"; Color = "White"; HttpOk = 0 }

        if ($t.Url) {
            try {
                $code = & curl.exe -I -s -m 3 -o NUL -w "%{http_code}" $t.Url
                if ($LASTEXITCODE -eq 0) {
                    $segments += @{ Text = "HTTP:ОК   "; Color = "Green"; HttpOk = 1 }
                } else {
                    $segments += @{ Text = "HTTP:ERROR"; Color = "Red"; HttpOk = 0 }
                }
            } catch {
                $segments += @{ Text = "HTTP:ERROR"; Color = "Red"; HttpOk = 0 }
            }
        } else {
            $segments += @{ Text = "HTTP:n/a  "; Color = "DarkGray"; HttpOk = 0 }
        }

        $segments += @{ Text = " | Ping: "; Color = "DarkGray"; HttpOk = 0 }

        try {
            $ping = Test-Connection $t.Ping -Count 2 -ErrorAction Stop |
                Measure-Object ResponseTime -Average |
                Select-Object -ExpandProperty Average
            $segments += @{ Text = ("{0:N0} ms" -f $ping); Color = "Cyan"; HttpOk = 0 }
        } catch {
            $segments += @{ Text = "Timeout"; Color = "Yellow"; HttpOk = 0 }
        }

        return $segments
    }

    $runspaces = @()
    foreach ($t in $targets) {
        $ps = [powershell]::Create()
        [void]$ps.AddScript($scriptBlock)
        [void]$ps.AddArgument($t)
        $ps.RunspacePool = $runspacePool

        $runspaces += [PSCustomObject]@{
            PS = $ps
            Handle = $ps.BeginInvoke()
        }
    }

    foreach ($rs in $runspaces) {
        $configOutput += ,$rs.PS.EndInvoke($rs.Handle)
        $rs.PS.Dispose()
    }

    $runspacePool.Close()
    $runspacePool.Dispose()

    Stop-Zapret
    if (-not $proc.HasExited) {
        Stop-Process $proc.Id -Force -ErrorAction SilentlyContinue
    }

    foreach ($line in $configOutput) {
        foreach ($seg in $line) {
            Write-Host $seg.Text -ForegroundColor $seg.Color -NoNewline
        }
        Write-Host ""
    }

    foreach ($line in $configOutput) {
        foreach ($seg in $line) {
            $httpResult += $seg.HttpOk
        }
    }

    if ($httpResult -eq 3) {
        Write-Host ""
        Write-Host " > Кажется, Вам " -ForegroundColor DarkGray -NoNewline
        Write-Host "подходит " -ForegroundColor Green -NoNewline
        Write-Host "конфиг $($file.Name)" -ForegroundColor DarkGray
        Write-Host ""

        if ($configNum -ne $batFiles.Count) {
            $continue = Read-Host "Вы желаете продолжить тест? (Y/N)"
                    
            if ($continue.ToLower() -eq "n") {
                Start-Process $ninjaService -Verb RunAs
                exit 1
            }
        }
    } elseif ($httpResult -ge 2) {
        Write-Host ""
        Write-Host " > Кажется, Вам " -ForegroundColor DarkGray -NoNewline
        Write-Host "возможно подходит " -ForegroundColor Yellow -NoNewline
        Write-Host "конфиг $($file.Name)" -ForegroundColor DarkGray
        Write-Host ""

    } else {
        Write-Host ""
        Write-Host " > Кажется, Вам " -ForegroundColor DarkGray -NoNewline
        Write-Host "не подходит " -ForegroundColor Red -NoNewline
        Write-Host "конфиг $($file.Name)" -ForegroundColor DarkGray
        Write-Host ""
    }

    $configNum += 1
}