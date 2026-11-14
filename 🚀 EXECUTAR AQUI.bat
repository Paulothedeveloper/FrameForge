@echo off
:: Windows Video Optimizer - Quick Launcher
:: By Neko-chan (=^･ω･^=)

title Windows Video Optimizer Launcher - Nya~!
color 0B

echo.
echo  ================================================================
echo    WINDOWS VIDEO OPTIMIZER - QUICK LAUNCHER
echo    Otimizador para CapCut, OBS Studio e Producao de Video
echo  ================================================================
echo.
echo  Nya~! (=^･ω･^=)
echo.
echo  [*] Verificando permissoes de Administrador...
echo.

:: Verificar se está rodando como admin
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  [ERRO] Este programa precisa de permissoes de ADMINISTRADOR!
    echo.
    echo  [*] Clique com o botao DIREITO no arquivo e escolha:
    echo      "Executar como Administrador"
    echo.
    pause
    exit /b 1
)

echo  [OK] Permissoes verificadas! Nya~!
echo.
echo  [*] Iniciando Windows Video Optimizer...
echo.
timeout /t 2 /nobreak >nul

:: Executar o script PowerShell
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsVideoOptimizer.ps1"

if %errorLevel% EQU 0 (
    echo.
    echo  [OK] Processo concluido com sucesso! Nya~!
) else (
    echo.
    echo  [ERRO] Algo deu errado. Codigo: %errorLevel%
)

echo.
pause
exit /b 0
