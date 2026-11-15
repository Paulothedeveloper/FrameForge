# FrameForge - Launcher do Instalador (NUNCA FECHA)
# Este script GARANTE que a janela nunca fecha, mesmo com erro

# Forçar que a janela fique aberta SEMPRE
$Host.UI.RawUI.WindowTitle = "FrameForge Installer"

# Banner inicial
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║           🎬  FRAMEFORGE - INSTALADOR  🎬                   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Nya~! Preparando instalação... (=^･ω･^=)" -ForegroundColor Cyan
Write-Host ""

# Verificar se está rodando como admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  ❌ ERRO: PowerShell NÃO está rodando como Administrador!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  📋 SOLUÇÃO:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "     1. Feche esta janela" -ForegroundColor White
    Write-Host "     2. Pressione Windows + X" -ForegroundColor White
    Write-Host "     3. Escolha 'Windows PowerShell (Admin)'" -ForegroundColor White
    Write-Host "     4. Cole este comando:" -ForegroundColor White
    Write-Host ""
    Write-Host "        irm https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/install-launcher.ps1 | iex" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Pressione Enter para sair..." -ForegroundColor Gray
    Read-Host
    exit 1
}

Write-Host "  ✅ PowerShell rodando como Administrador!" -ForegroundColor Green
Write-Host ""

# Baixar e executar instalador com proteções máximas
try {
    Write-Host "  📥 Baixando instalador..." -ForegroundColor Cyan
    
    $installerUrl = "https://raw.githubusercontent.com/Paulothedeveloper/WindowsVideoOptimizer/main/quick-install.ps1"
    $installerScript = Invoke-RestMethod -Uri $installerUrl -UseBasicParsing
    
    Write-Host "  ✅ Instalador baixado!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  🚀 Iniciando instalação..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    
    # Executar instalador NO MESMO PROCESSO (não abre nova janela)
    # Adicionar flag para não re-executar
    $env:FRAMEFORGE_NO_PROFILE = "1"
    
    # Executar como script block
    $scriptBlock = [ScriptBlock]::Create($installerScript)
    & $scriptBlock
    
} catch {
    Write-Host ""
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  ❌ ERRO DURANTE A INSTALAÇÃO!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  📝 Detalhes do erro:" -ForegroundColor Yellow
    Write-Host "     $($_.Exception.Message)" -ForegroundColor White
    Write-Host ""
    Write-Host "  📋 Informações para debug:" -ForegroundColor Yellow
    Write-Host "     Linha: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Gray
    Write-Host "     Arquivo: $($_.InvocationInfo.ScriptName)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  💡 SOLUÇÕES ALTERNATIVAS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     Opção 1 - Instalação Manual:" -ForegroundColor White
    Write-Host "     1. Baixe: https://github.com/Paulothedeveloper/WindowsVideoOptimizer/archive/refs/heads/main.zip" -ForegroundColor Gray
    Write-Host "     2. Extraia para C:\FrameForge" -ForegroundColor Gray
    Write-Host "     3. Instale Node.js: https://nodejs.org" -ForegroundColor Gray
    Write-Host "     4. Abra PowerShell Admin na pasta e rode: npm install" -ForegroundColor Gray
    Write-Host ""
    Write-Host "     Opção 2 - Tentar novamente com logging:" -ForegroundColor White
    Write-Host "     `$DebugPreference = 'Continue'; irm ...url... | iex" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  📧 Se o erro persistir, reporte em:" -ForegroundColor Yellow
    Write-Host "     https://github.com/Paulothedeveloper/WindowsVideoOptimizer/issues" -ForegroundColor Cyan
    Write-Host ""
}

# Sempre esperar no final
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""
Write-Host "  Pressione Enter para fechar esta janela..." -ForegroundColor Gray
Read-Host
