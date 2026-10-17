@echo off
rem EventMonitor screenshot uploader installer (Windows, no dependencies)
rem Asks for the upload URL, installs to %APPDATA%\EventMonitor and registers
rem a startup entry so it runs hidden on every boot. Run once, that's it.

setlocal
echo ============================================
echo  EventMonitor screenshot uploader - install
echo ============================================
echo.

set /p URL="Upload URL (default: http://maurotue.ddns.net:3100/upload): "
if "%URL%"=="" set URL=http://maurotue.ddns.net:3100/upload

set "DEST=%APPDATA%\EventMonitor"
if not exist "%DEST%" mkdir "%DEST%"
copy /y "%~dp0eventmonitor_uploader.ps1" "%DEST%\" >nul
echo %URL%> "%DEST%\config.txt"

rem consent gate: the in-game popup must have answered Yes (F8 to change)
echo Lembrete: o upload so acontece se o popup do mod no jogo estiver em "yes" (F8 reabre).
echo Reminder: uploads only happen if the in-game popup answered Yes (F8 reopens it).

rem startup entry (user-level, no admin needed)
set "START=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\eventmonitor_uploader.bat"
> "%START%" echo @echo off
>> "%START%" echo start "" /min powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%DEST%\eventmonitor_uploader.ps1"

echo.
echo Instalado em %DEST% e registrado na inicializacao.
choice /m "Iniciar agora"
if errorlevel 2 goto :eof
start "" /min powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%DEST%\eventmonitor_uploader.ps1"
echo Rodando. Feche esta janela.
