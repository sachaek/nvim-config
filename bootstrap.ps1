<#
.SYNOPSIS
  Bootstrap Neovim Python IDE — установка конфига на новой машине.
.DESCRIPTION
  Устанавливает Neovim, Python-зависимости и копирует конфигурацию.
  Запускать из корня репозитория (где лежит папка nvim/).
#>

$ErrorActionPreference = "Stop"

# ---------- helpers ----------
function Status($text) {
  Write-Host ">>> $text" -ForegroundColor Cyan
}

function Ensure-Admin {
  $isAdmin = ([Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()`
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Write-Host "! Нужны права администратора для установки Neovim." -ForegroundColor Yellow
    Write-Host "  Перезапустите PowerShell от имени администратора." -ForegroundColor Yellow
    exit 1
  }
}

# ---------- 1. Chocolatey + Neovim ----------
function Install-Neovim {
  $nvimPaths = @(
    "$env:ProgramFiles\neovim\bin\nvim.exe",
    "${env:ProgramFiles(x86)}\neovim\bin\nvim.exe",
    "$env:LOCALAPPDATA\neovim\bin\nvim.exe",
    "C:\tools\neovim\nvim-win64\bin\nvim.exe"
  )
  $found = $false
  foreach ($p in $nvimPaths) { if (Test-Path $p) { $found = $true; break } }

  if (-not (Get-Command nvim -ErrorAction SilentlyContinue) -and -not $found) {
    Status "Устанавливаю Neovim через Chocolatey..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
      Status "Сначала устанавливаю Chocolatey..."
      Set-ExecutionPolicy Bypass -Scope Process -Force
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    choco install neovim -y --acceptlicense
  } else {
    Status "Neovim уже установлен."
  }
}

# ---------- 2. PATH ----------
function Update-PATH {
  $nvimBin = "C:\tools\neovim\nvim-win64\bin"
  $pythonScripts = "$env:USERPROFILE\AppData\Roaming\Python\Python314\Scripts"

  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $changed = $false

  if ($userPath -notlike "*$nvimBin*") {
    $userPath = "$userPath;$nvimBin"
    $changed = $true
  }
  if ($userPath -notlike "*$pythonScripts*") {
    $userPath = "$userPath;$pythonScripts"
    $changed = $true
  }
  if ($changed) {
    [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
    Status "PATH обновлён."
  }
  # Обновить в текущей сессии
  $env:Path = $userPath
}

# ---------- 3. Python-пакеты ----------
function Install-PythonPackages {
  if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "! Python не найден. Установите Python с python.org и запустите скрипт снова." -ForegroundColor Yellow
    exit 1
  }
  Status "Устанавливаю Python-пакеты (pynvim, ruff, debugpy)..."
  python -m pip install pynvim ruff debugpy -q
}

# ---------- 4. Конфиг Neovim ----------
function Deploy-Config {
  $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
  $srcConfig = Join-Path $scriptDir "nvim"
  $dstConfig = "$env:LOCALAPPDATA\nvim"

  if (-not (Test-Path $srcConfig)) {
    Write-Host "! Папка 'nvim' не найдена в текущей директории." -ForegroundColor Red
    Write-Host "  Убедитесь, что bootstrap.ps1 лежит рядом с папкой nvim/." -ForegroundColor Red
    exit 1
  }

  # Бекап существующего конфига
  if (Test-Path $dstConfig) {
    $backup = "$dstConfig.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Status "Делаю бекап существующего конфига: $backup"
    Move-Item $dstConfig $backup -Force
  }

  Status "Копирую конфиг -> $dstConfig"
  Copy-Item $srcConfig $dstConfig -Recurse
}

# ---------- 5. Триггер установки плагинов ----------
function Install-Plugins {
  Status "Запускаю Neovim для установки плагинов (первый запуск)..."
  Write-Host "  Это может занять 1-2 минуты. Neovim закроется сам." -ForegroundColor Gray

  # Проверка что nvim доступен
  if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    # Пробуем найти вручную
    $candidates = @(
      "C:\tools\neovim\nvim-win64\bin\nvim.exe",
      "$env:ProgramFiles\neovim\bin\nvim.exe",
      "${env:ProgramFiles(x86)}\neovim\bin\nvim.exe"
    )
    $nvimPath = $null
    foreach ($c in $candidates) { if (Test-Path $c) { $nvimPath = $c; break } }
    if (-not $nvimPath) {
      Write-Host "! Neovim не найден после установки. Добавьте в PATH вручную." -ForegroundColor Yellow
      return
    }
    & $nvimPath --headless "+Lazy! sync" +qa
  } else {
    nvim --headless "+Lazy! sync" +qa
  }
  Status "Плагины установлены."
}

# ---------- MAIN ----------
Write-Host @"

╔══════════════════════════════════════════════════╗
║   NEOVIM PYTHON IDE — BOOTSTRAP                 ║
╚══════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# Ensure-Admin
Install-Neovim
Update-PATH
Install-PythonPackages
Deploy-Config
Install-Plugins

Write-Host @"

╔══════════════════════════════════════════════════╗
║   ГОТОВО!                                       ║
║                                                  ║
║   Откройте терминал и запустите:  nvim           ║
║   Проверка:  nvim +checkhealth                   ║
╚══════════════════════════════════════════════════╝
"@ -ForegroundColor Green
