@echo off
:: Windows Video Optimizer v2.0 - Professional Edition
:: By Neko-chan (=^･ω･^=)

title Windows Video Optimizer v2.0 - Launcher
color 0E

echo.
echo  ================================================================
echo    WINDOWS VIDEO OPTIMIZER v2.0 - PROFESSIONAL EDITION
echo    Interface Moderna Web + Backend Node.js
echo  ================================================================
echo.
echo  Nya~! (=^･ω･^=)
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

:: Verificar Node.js
where node >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  [ERRO] Node.js nao encontrado!
    echo.
    echo  [*] Instale Node.js de: https://nodejs.org
    echo.
    pause
    exit /b 1
)

echo  [OK] Node.js encontrado!
echo.

:: Instalar dependências se necessário
if not exist node_modules (
    echo  [*] Instalando dependencias pela primeira vez...
    call npm install
    echo.
)

echo  [*] Iniciando servidor...
echo.
echo  ============================================
echo   Interface Web: http://localhost:3000
echo   Aguarde o navegador abrir automaticamente!
echo  ============================================
echo.

:: Iniciar servidor
start /B node server.js

:: Aguardar 2 segundos e abrir navegador
timeout /t 2 /nobreak >nul
start http://localhost:3000

echo.
echo  [OK] Servidor iniciado! A interface foi aberta no navegador.
echo.
echo  [*] Mantenha esta janela ABERTA enquanto usa o otimizador!
echo  [*] Pressione Ctrl+C para parar o servidor
echo.

:: Manter janela aberta
pause >nul
