@echo off
title Underground - Teste de Eventos Megalomaníacos
echo ===================================================
echo   UNDERGROUND: TESTE DE EVENTOS MEGALOMANIACOS
echo   Iniciando servidor local e abrindo navegador...
echo ===================================================

cd /d "%~dp0"

netstat -ano | findstr :8888 >nul
if %errorlevel% neq 0 (
    start /min "UnderGameServer" python -m http.server 8888 --bind 127.0.0.1
    timeout /t 1 /nobreak >nul
)

start http://127.0.0.1:8888/index.html
echo.
echo Jogo aberto em http://127.0.0.1:8888/index.html !
echo Use os botoes no rodape da tela ou as teclas 1 a 6 para testar cada evento!
echo Pressione qualquer tecla para fechar o launcher.
pause >nul
