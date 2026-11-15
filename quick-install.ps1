# FrameForge - Instalador Rápido
# Execute este comando no PowerShell NORMAL (não precisa ser admin):
# irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1 | iex

$ErrorActionPreference = "Stop"

# Banner
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║           🎬  FRAMEFORGE - QUICK INSTALLER  🎬              ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ║              Instalador Rápido v2.1                          ║" -ForegroundColor Magenta
Write-Host "  ║                                                              ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Nya~! Vou te guiar na instalação! (=^･ω･^=)" -ForegroundColor Cyan
Write-Host ""

# Verificar se está rodando como admin
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
    
    # Oferecer abrir automaticamente
    Write-Host "  💡 ATALHO: Quer que eu tente abrir o PowerShell Admin para você?" -ForegroundColor Yellow
    $response = Read-Host "     Digite S para Sim, N para Não"
    
    if ($response -eq 'S' -or $response -eq 's') {
        Write-Host ""
        Write-Host "  🚀 Abrindo PowerShell como Administrador..." -ForegroundColor Cyan
        Write-Host "     (Cole o comando novamente lá!)" -ForegroundColor Yellow
        Write-Host ""
        
        # Salvar o comando em arquivo temporário
        $tempScript = "$env:TEMP\frameforge-install-temp.ps1"
        $installCommand = "irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1 | iex"
        
        # Criar script que mostra o comando e espera
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
        
        # Abrir novo PowerShell como admin
        Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-File", $tempScript
        
        Write-Host "  ✅ Nova janela aberta! Cole o comando lá." -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "  Pressione Enter para sair..." -ForegroundColor Gray
    Read-Host
    exit 1
}

# Se chegou aqui, está rodando como admin!
Write-Host "  ✅ PowerShell rodando como Administrador!" -ForegroundColor Green
Write-Host ""

# Configurações
$RepoUrl = "https://github.com/Paulothedeveloper/WindowsVideoOptimizer"
$InstallPath = "$env:LOCALAPPDATA\FrameForge"
$DesktopShortcut = "$env:USERPROFILE\Desktop\FrameForge.lnk"

# Verificar Git
Write-Host "  [1/6] Verificando Git..." -ForegroundColor Cyan
try {
    $gitVersion = git --version 2>$null
    Write-Host "  ✅ Git encontrado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Git não encontrado. Instalando..." -ForegroundColor Yellow
    
    # Baixar e instalar Git
    $gitInstaller = "$env:TEMP\Git-Setup.exe"
    Write-Host "     Baixando Git..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile $gitInstaller
    
    Write-Host "     Instalando Git (aguarde)..." -ForegroundColor Gray
    Start-Process -FilePath $gitInstaller -Args "/VERYSILENT /NORESTART" -Wait
    
    # Atualizar PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "  ✅ Git instalado!" -ForegroundColor Green
}

# Verificar Node.js
Write-Host ""
Write-Host "  [2/6] Verificando Node.js..." -ForegroundColor Cyan
try {
    $nodeVersion = node --version 2>$null
    Write-Host "  ✅ Node.js encontrado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Node.js não encontrado. Instalando..." -ForegroundColor Yellow
    
    # Baixar e instalar Node.js
    $nodeInstaller = "$env:TEMP\node-setup.msi"
    Write-Host "     Baixando Node.js..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile $nodeInstaller
    
    Write-Host "     Instalando Node.js (aguarde)..." -ForegroundColor Gray
    Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -Wait
    
    # Atualizar PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "  ✅ Node.js instalado!" -ForegroundColor Green
}

# Clonar repositório
Write-Host ""
Write-Host "  [3/6] Clonando repositório FrameForge..." -ForegroundColor Cyan

if (Test-Path $InstallPath) {
    Write-Host "     Removendo instalação anterior..." -ForegroundColor Gray
    Remove-Item -Path $InstallPath -Recurse -Force
}

git clone $RepoUrl $InstallPath 2>&1 | Out-Null
Write-Host "  ✅ Repositório clonado!" -ForegroundColor Green

# Instalar dependências
Write-Host ""
Write-Host "  [4/6] Instalando dependências npm..." -ForegroundColor Cyan
Set-Location $InstallPath
npm install --silent 2>&1 | Out-Null
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

# Criar ponto de restauração
Write-Host ""
Write-Host "  [6/6] Criando ponto de restauração do sistema..." -ForegroundColor Cyan
try {
    Checkpoint-Computer -Description "FrameForge - Antes da instalação" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "  ✅ Ponto de restauração criado!" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Não foi possível criar ponto de restauração (não é crítico)" -ForegroundColor Yellow
}

# Conclusão
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

# Perguntar se quer executar agora
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
