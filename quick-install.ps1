# FrameForge - Instalador Rápido
# Execute este comando no PowerShell como Administrador:
# irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1 | iex

$ErrorActionPreference = "Stop"

# ============================================================================
# HELPER: Invoke-NativeCommand
# ----------------------------------------------------------------------------
# ROOT CAUSE que este helper resolve (confirmado por reprodução em 2026-11-15,
# ver systematic-debugging): com $ErrorActionPreference = "Stop", qualquer
# linha que um comando nativo (git, npm, node...) escreve em STDERR e tratada
# pelo PowerShell como excecao terminante (NativeCommandError) MESMO QUE o
# comando tenha sucesso (exit code 0). git, em particular, escreve suas
# mensagens de progresso normais ("Cloning into ...") em stderr por design.
# Isso derrubava o script inteiro em TODA instalacao, mesmo sem nada errado.
# Fix: abaixar para "Continue" so durante a chamada nativa, capturar a saida
# real, e decidir sucesso/falha pelo $LASTEXITCODE (verdade objetiva do
# processo), nao pela presenca de texto em stderr.
# Reproduzido e validado com 3 casos antes de aplicar: git --version (ok),
# git clone de repo real (ok, exit 0), git clone de repo inexistente
# (corretamente reportado como falha, exit 128).
# ============================================================================
function Invoke-NativeCommand {
    param([Parameter(Mandatory=$true)][string]$Command)
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = Invoke-Expression "$Command 2>&1" | Out-String
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPref
    }
    return [PSCustomObject]@{
        Output   = $output.Trim()
        ExitCode = $exitCode
        Success  = ($exitCode -eq 0)
    }
}

# PROTECAO: Re-executar sem profile se detectar que esta rodando com profile
# Isso evita conflitos com profiles personalizados dos usuarios
if ($PROFILE -and (Test-Path $PROFILE) -and -not $env:FRAMEFORGE_NO_PROFILE) {
    Write-Host ""
    Write-Host "  🔧 Detectado PowerShell profile personalizado..." -ForegroundColor Yellow
    Write-Host "     Re-executando sem profile para evitar conflitos..." -ForegroundColor Gray
    Write-Host ""

    $tempScript = "$env:TEMP\frameforge-install-safe.ps1"
    $currentScript = $MyInvocation.MyCommand.ScriptBlock.ToString()
    $safeScript = "`$env:FRAMEFORGE_NO_PROFILE = '1'" + "`n" + $currentScript
    $safeScript | Out-File -FilePath $tempScript -Encoding UTF8 -Force

    $params = @{
        FilePath = "powershell.exe"
        ArgumentList = @(
            "-NoProfile",
            "-NoExit",
            "-ExecutionPolicy", "Bypass",
            "-File", $tempScript
        )
        Verb = "RunAs"
    }

    try {
        Start-Process @params
        exit 0
    } catch {
        Write-Host "  ⚠️  Erro ao re-executar. Continuando com profile..." -ForegroundColor Yellow
    }
}

# Banner
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║           🎬  FRAMEFORGE - QUICK INSTALLER  🎬              ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║              Instalador Rápido v2.2                          ║" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Nya~! Vou te guiar na instalação! (=^･ω･^=)" -ForegroundColor Cyan
Write-Host ""

# Verificar se esta rodando como admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ⚠️  ATENÇÃO: Este PowerShell NÃO está rodando como Administrador!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Para instalar o FrameForge, você precisa de permissões de admin." -ForegroundColor White
    Write-Host ""
    Write-Host "  📋 COMO ABRIR POWERSHELL COMO ADMINISTRADOR:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     1. Pressione a tecla Windows (⊞)" -ForegroundColor White
    Write-Host "     2. Digite: PowerShell" -ForegroundColor White
    Write-Host "     3. Clique com o BOTÃO DIREITO em 'Windows PowerShell'" -ForegroundColor White
    Write-Host "     4. Escolha 'Executar como Administrador'" -ForegroundColor White
    Write-Host "     5. Clique 'Sim' no aviso de segurança" -ForegroundColor White
    Write-Host ""
    Write-Host "  Depois, cole este comando novamente:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1 | iex" -ForegroundColor Green
    Write-Host ""

    Write-Host "  💡 ATALHO: Quer que eu tente abrir o PowerShell Admin para você?" -ForegroundColor Yellow
    $response = Read-Host "     Digite S para Sim, N para Não"

    if ($response -eq 'S' -or $response -eq 's') {
        Write-Host ""
        Write-Host "  🚀 Abrindo PowerShell como Administrador..." -ForegroundColor Cyan
        Write-Host "     (Cole o comando novamente lá!)" -ForegroundColor Yellow
        Write-Host ""

        $tempScript = "$env:TEMP\frameforge-install-temp.ps1"
        $installCommand = "irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1 | iex"

        @"
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║           🎬  FRAMEFORGE - INSTALADOR  🎬                   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  ✅ PowerShell aberto como Administrador!" -ForegroundColor Green
Write-Host ""
Write-Host "  📋 Cole este comando para instalar:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  $installCommand" -ForegroundColor Green
Write-Host ""
Write-Host "  (Aperte Enter para fechar esta janela)" -ForegroundColor Yellow
Read-Host
"@ | Out-File -FilePath $tempScript -Encoding UTF8

        Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-File", $tempScript

        Write-Host "  ✅ Nova janela aberta! Cole o comando lá." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "  Pressione Enter para sair..." -ForegroundColor Gray
    Read-Host
    exit 1
}

Write-Host "  ✅ PowerShell rodando como Administrador!" -ForegroundColor Green
Write-Host ""

# Configuracoes
$RepoUrl = "https://github.com/Paulothedeveloper/WindowsVideoOptimizer"
$InstallPath = "$env:LOCALAPPDATA\FrameForge"
$DesktopShortcut = "$env:USERPROFILE\Desktop\FrameForge.lnk"

# Verificar Git
Write-Host "  [1/6] Verificando Git..." -ForegroundColor Cyan
$gitCheck = Invoke-NativeCommand "git --version"
if ($gitCheck.Success) {
    Write-Host "  ✅ Git encontrado: $($gitCheck.Output)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Git não encontrado. Instalando..." -ForegroundColor Yellow

    $gitInstaller = "$env:TEMP\Git-Setup.exe"
    Write-Host "     Baixando Git..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile $gitInstaller

    Write-Host "     Instalando Git (aguarde)..." -ForegroundColor Gray
    Start-Process -FilePath $gitInstaller -Args "/VERYSILENT /NORESTART" -Wait

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    $gitRecheck = Invoke-NativeCommand "git --version"
    if (-not $gitRecheck.Success) {
        throw "Git foi instalado mas ainda não está acessível. Feche e reabra o PowerShell como Admin, depois rode o instalador novamente."
    }
    Write-Host "  ✅ Git instalado: $($gitRecheck.Output)" -ForegroundColor Green
}

# Verificar Node.js
Write-Host ""
Write-Host "  [2/6] Verificando Node.js..." -ForegroundColor Cyan
$nodeCheck = Invoke-NativeCommand "node --version"
if ($nodeCheck.Success) {
    Write-Host "  ✅ Node.js encontrado: $($nodeCheck.Output)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Node.js não encontrado. Instalando..." -ForegroundColor Yellow

    $nodeInstaller = "$env:TEMP\node-setup.msi"
    Write-Host "     Baixando Node.js..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile $nodeInstaller

    Write-Host "     Instalando Node.js (aguarde)..." -ForegroundColor Gray
    Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    $nodeRecheck = Invoke-NativeCommand "node --version"
    if (-not $nodeRecheck.Success) {
        throw "Node.js foi instalado mas ainda não está acessível. Feche e reabra o PowerShell como Admin, depois rode o instalador novamente."
    }
    Write-Host "  ✅ Node.js instalado: $($nodeRecheck.Output)" -ForegroundColor Green
}

# Clonar repositorio
Write-Host ""
Write-Host "  [3/6] Clonando repositório FrameForge..." -ForegroundColor Cyan

if (Test-Path $InstallPath) {
    Write-Host "     Removendo instalação anterior..." -ForegroundColor Gray
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction Stop
}

Write-Host "     De: $RepoUrl" -ForegroundColor Gray
Write-Host "     Para: $InstallPath" -ForegroundColor Gray

$cloneResult = Invoke-NativeCommand "git clone `"$RepoUrl`" `"$InstallPath`""
if (-not $cloneResult.Success) {
    throw "Git clone falhou (exit code $($cloneResult.ExitCode)). Saída real do git:`n$($cloneResult.Output)"
}

Write-Host "  ✅ Repositório clonado!" -ForegroundColor Green

# Instalar dependencias
Write-Host ""
Write-Host "  [4/6] Instalando dependências npm..." -ForegroundColor Cyan
Set-Location $InstallPath

$npmResult = Invoke-NativeCommand "npm install --silent"
if (-not $npmResult.Success) {
    throw "npm install falhou (exit code $($npmResult.ExitCode)). Saída real do npm:`n$($npmResult.Output)"
}

Write-Host "  ✅ Dependências instaladas!" -ForegroundColor Green

# Criar atalho
Write-Host ""
Write-Host "  [5/6] Criando atalho no Desktop..." -ForegroundColor Cyan

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
$Shortcut.TargetPath = "$InstallPath\🚀 EXECUTAR AQUI.bat"
$Shortcut.WorkingDirectory = $InstallPath
$Shortcut.IconLocation = "$InstallPath\favicon.ico"
$Shortcut.Description = "FrameForge - Professional Windows Optimizer"
$Shortcut.Save()

Write-Host "  ✅ Atalho criado: $DesktopShortcut" -ForegroundColor Green

# Criar ponto de restauracao
Write-Host ""
Write-Host "  [6/6] Criando ponto de restauração do sistema..." -ForegroundColor Cyan
try {
    Checkpoint-Computer -Description "FrameForge - Antes da instalação" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "  ✅ Ponto de restauração criado!" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Não foi possível criar ponto de restauração (não é crítico)" -ForegroundColor Yellow
    Write-Host "     Motivo: $($_.Exception.Message)" -ForegroundColor Gray
}

# Conclusao
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ║              ✅  INSTALAÇÃO CONCLUÍDA!  ✅                  ║" -ForegroundColor Green
Write-Host "  ║                                                              ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  📁 Instalado em: $InstallPath" -ForegroundColor Cyan
Write-Host "  🖥️  Atalho criado no Desktop" -ForegroundColor Cyan
Write-Host ""
Write-Host "  🚀 COMO USAR:" -ForegroundColor Yellow
Write-Host "     1. Clique duas vezes no atalho 'FrameForge' no Desktop" -ForegroundColor White
Write-Host "     2. Escolha 'Executar como Administrador'" -ForegroundColor White
Write-Host "     3. Aguarde o navegador abrir automaticamente" -ForegroundColor White
Write-Host "     4. Selecione as otimizações e clique em 'Otimizar Agora'" -ForegroundColor White
Write-Host ""
Write-Host "  Nya~! Instalação completa! (=^･ω･^=)ฅ" -ForegroundColor Magenta
Write-Host ""

[Console]::Beep(800, 200)
Start-Sleep -Milliseconds 100
[Console]::Beep(1000, 200)

$execute = Read-Host "  Deseja executar o FrameForge agora? (S/N)"

if ($execute -eq 'S' -or $execute -eq 's') {
    Write-Host ""
    Write-Host "  🚀 Iniciando FrameForge..." -ForegroundColor Cyan
    Write-Host ""

    Set-Location $InstallPath
    Start-Process -FilePath "$InstallPath\🚀 EXECUTAR AQUI.bat" -Verb RunAs

    Write-Host "  ✅ FrameForge iniciado! Aguarde o navegador abrir..." -ForegroundColor Green
    Write-Host ""
}

Write-Host "  Pressione Enter para sair..." -ForegroundColor Gray
Read-Host

if (Test-Path "$env:TEMP\frameforge-install-safe.ps1") {
    Remove-Item "$env:TEMP\frameforge-install-safe.ps1" -Force -ErrorAction SilentlyContinue
}
