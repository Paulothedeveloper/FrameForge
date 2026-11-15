#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Video Optimizer - Instalador Automático
.DESCRIPTION
    Instala automaticamente o Windows Video Optimizer com todas as dependências
.NOTES
    Versão: 2.0.0
    Autor: Paulothedeveloper
#>

$ErrorActionPreference = "Stop"

# Cores
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green @args }
function Write-Error { Write-ColorOutput Red @args }
function Write-Info { Write-ColorOutput Cyan @args }
function Write-Warning { Write-ColorOutput Yellow @args }

# Banner
Clear-Host
Write-Host ""
Write-ColorOutput Magenta "  ╔══════════════════════════════════════════════════════════════╗"
Write-ColorOutput Magenta "  ║                                                              ║"
Write-ColorOutput Cyan    "  ║           WINDOWS VIDEO OPTIMIZER - INSTALLER               ║"
Write-ColorOutput Magenta "  ║                                                              ║"
Write-ColorOutput Magenta "  ║              Instalador Automático v2.0                      ║"
Write-ColorOutput Magenta "  ║                                                              ║"
Write-ColorOutput Magenta "  ╚══════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Info "  Vou instalar tudo automaticamente!"
Write-Host ""

# Configurações
$RepoUrl = "https://github.com/Paulothedeveloper/WindowsVideoOptimizer"
$InstallPath = "$env:LOCALAPPDATA\WindowsVideoOptimizer"
$DesktopShortcut = "$env:USERPROFILE\Desktop\Windows Video Optimizer.lnk"

# Verificar permissões de administrador
Write-Info "[1/7] Verificando permissões de administrador..."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "ERRO: Execute este script como Administrador!"
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Success "   ✓ Permissões verificadas!"
Write-Host ""

# Verificar Git
Write-Info "[2/7] Verificando Git..."
try {
    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Success "   ✓ Git encontrado: $gitVersion"
    }
} catch {
    Write-Warning "   ⚠ Git não encontrado. Instalando via winget..."
    try {
        winget install --id Git.Git -e --source winget --silent --accept-package-agreements --accept-source-agreements
        # Atualizar PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Success "   ✓ Git instalado com sucesso!"
    } catch {
        Write-Error "   ✗ Falha ao instalar Git automaticamente."
        Write-Warning "   Baixe manualmente de: https://git-scm.com/download/win"
        Write-Host ""
        Write-Host "Pressione qualquer tecla para sair..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
Write-Host ""

# Verificar Node.js
Write-Info "[3/7] Verificando Node.js..."
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($versionNumber -ge 14) {
            Write-Success "   ✓ Node.js encontrado: $nodeVersion"
        } else {
            throw "Versão antiga"
        }
    } else {
        throw "Não encontrado"
    }
} catch {
    Write-Warning "   ⚠ Node.js 14+ não encontrado. Instalando via winget..."
    try {
        winget install --id OpenJS.NodeJS.LTS -e --source winget --silent --accept-package-agreements --accept-source-agreements
        # Atualizar PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $nodeVersion = node --version
        Write-Success "   ✓ Node.js instalado: $nodeVersion"
    } catch {
        Write-Error "   ✗ Falha ao instalar Node.js automaticamente."
        Write-Warning "   Baixe manualmente de: https://nodejs.org"
        Write-Host ""
        Write-Host "Pressione qualquer tecla para sair..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
Write-Host ""

# Baixar repositório
Write-Info "[4/7] Baixando Windows Video Optimizer..."
if (Test-Path $InstallPath) {
    Write-Warning "   ⚠ Diretório já existe. Removendo instalação anterior..."
    Remove-Item -Path $InstallPath -Recurse -Force
}

try {
    git clone $RepoUrl $InstallPath --quiet
    Write-Success "   ✓ Repositório clonado com sucesso!"
} catch {
    Write-Error "   ✗ Falha ao clonar repositório."
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host ""

# Instalar dependências npm
Write-Info "[5/7] Instalando dependências npm..."
Push-Location $InstallPath
try {
    npm install --silent --no-progress 2>&1 | Out-Null
    Write-Success "   ✓ Dependências instaladas!"
} catch {
    Write-Error "   ✗ Falha ao instalar dependências npm."
    Pop-Location
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Pop-Location
Write-Host ""

# Criar atalho no desktop
Write-Info "[6/7] Criando atalho no desktop..."
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
    $Shortcut.TargetPath = "$InstallPath\EXECUTAR AQUI.bat"
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.Description = "Windows Video Optimizer v2.0"
    $Shortcut.IconLocation = "imageres.dll,1"
    $Shortcut.Save()
    Write-Success "   ✓ Atalho criado no desktop!"
} catch {
    Write-Warning "   ⚠ Não foi possível criar atalho no desktop."
}
Write-Host ""

# Criar ponto de restauração
Write-Info "[7/7] Criando ponto de restauração do sistema..."
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Antes de instalar Windows Video Optimizer" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Success "   ✓ Ponto de restauração criado!"
} catch {
    Write-Warning "   ⚠ Não foi possível criar ponto de restauração."
}
Write-Host ""

# Finalização
Write-Host ""
Write-ColorOutput Green "  ╔══════════════════════════════════════════════════════════════╗"
Write-ColorOutput Green "  ║                                                              ║"
Write-ColorOutput Green "  ║              ✅  INSTALAÇÃO CONCLUÍDA!  ✅                   ║"
Write-ColorOutput Green "  ║                                                              ║"
Write-ColorOutput Green "  ╚══════════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Success "  Instalado em: $InstallPath"
Write-Success "  Atalho criado: $DesktopShortcut"
Write-Host ""
Write-Info "  Como usar:"
Write-Info "    1. Use o atalho no Desktop"
Write-Info "    2. Ou execute: cd '$InstallPath' e rode o launcher"
Write-Host ""

# Perguntar se deseja executar agora
Write-Host ""
$execute = Read-Host "Deseja EXECUTAR o otimizador agora? (S/N)"
if ($execute -eq 'S' -or $execute -eq 's') {
    Write-Host ""
    Write-Info "Iniciando Windows Video Optimizer..."
    Start-Sleep -Seconds 2
    
    # Executar o launcher
    Start-Process -FilePath "$InstallPath\EXECUTAR AQUI.bat" -Verb RunAs
    
    Write-Success "Launcher iniciado!"
} else {
    Write-Info "OK! Use o atalho no Desktop quando quiser."
}

Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
