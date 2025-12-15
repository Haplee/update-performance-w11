@echo off
:: Comprobar si el script se está ejecutando como Administrador
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando privilegios de Administrador...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: --- Configuración de Colores ---
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
    set "ESC=%%b"
)
set "COLOR_RESET=%ESC%[0m"
set "COLOR_TITLE=%ESC%[96m"
set "COLOR_INFO=%ESC%[92m"
set "COLOR_QUESTION=%ESC%[93m"
set "COLOR_PAUSE=%ESC%[95m"

:: --- Inicio del Script de Optimización ---
cls
echo %COLOR_TITLE%===================================================%COLOR_RESET%
echo %COLOR_TITLE%     WinOptimize - Herramienta de Limpieza         %COLOR_RESET%
echo %COLOR_TITLE%===================================================%COLOR_RESET%
echo.
echo Este script realizara las siguientes acciones:
echo  - Limpieza de archivos temporales.
echo  - Limpieza de la carpeta Prefetch.
echo  - Limpieza del Visor de Eventos.
echo  - Activacion del plan de Maximo Rendimiento.
echo  - Ejecucion del script de Chris Titus Tech.
echo  - Apertura de la pagina de descarga de QuickCPU.
echo.
echo %COLOR_PAUSE%Presiona cualquier tecla para continuar...%COLOR_RESET%
pause >nul
cls

:: --- Limpieza de Archivos Temporales ---
echo %COLOR_INFO%[INFO] Limpiando archivos temporales de usuario (%%TEMP%%)...%COLOR_RESET%
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%p in ("%TEMP%\*") do rmdir "%%p" /s /q >nul 2>&1
echo %COLOR_INFO%[INFO] Limpiando archivos temporales de Windows (C:\Windows\Temp)...%COLOR_RESET%
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
echo.

:: --- Limpieza de Prefetch ---
echo %COLOR_INFO%[INFO] Limpiando archivos de Prefetch (C:\Windows\Prefetch)...%COLOR_RESET%
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Prefetch\*") do rmdir "%%p" /s /q >nul 2>&1
echo.

:: --- Limpieza del Visor de Eventos ---
echo %COLOR_INFO%[INFO] Limpiando todos los registros del Visor de Eventos en paralelo...%COLOR_RESET%
for /f "tokens=*" %%a in ('wevtutil el') do (
    start "" /b wevtutil cl "%%a" >nul 2>nul
)

:wait_for_wevtutil
timeout /t 1 /nobreak >nul
tasklist /fi "IMAGENAME eq wevtutil.exe" 2>nul | find "wevtutil.exe" >nul
if %errorlevel%==0 goto wait_for_wevtutil

echo %COLOR_INFO%[INFO] Limpieza de registros del Visor de Eventos completada.%COLOR_RESET%
echo.

:: --- Cambiar Plan de Energía a Máximo Rendimiento ---
echo %COLOR_INFO%[INFO] Cambiando el plan de energia a 'Maximo Rendimiento'...%COLOR_RESET%
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo.

:: --- Ejecución de script de Chris Titus Tech (Opcional) ---
set "pregunta=%COLOR_QUESTION%[PREGUNTA] Desea ejecutar el script de optimizacion de Chris Titus Tech? (S/N): %COLOR_RESET%"
set /p response="%pregunta%"
if /i "%response%"=="S" (
    echo %COLOR_INFO%[INFO] Ejecutando el script de optimizacion de Chris Titus Tech...%COLOR_RESET%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://christitus.com/win' -UseBasicParsing | iex"
) else (
    echo %COLOR_INFO%[INFO] Omitiendo el script de Chris Titus Tech.%COLOR_RESET%
)
echo.

:: --- Abrir navegador para descargar QuickCPU (Opcional) ---
set "pregunta=%COLOR_QUESTION%[PREGUNTA] Desea abrir la pagina para descargar QuickCPU? (S/N): %COLOR_RESET%"
set /p response="%pregunta%"
if /i "%response%"=="S" (
    echo %COLOR_INFO%[INFO] Abriendo el navegador para descargar QuickCPU...%COLOR_RESET%
    start "" "https://coderbag.com/product/quickcpu"
) else (
    echo %COLOR_INFO%[INFO] Omitiendo la descarga de QuickCPU.%COLOR_RESET%
)
echo.

echo %COLOR_TITLE%===================================================%COLOR_RESET%
echo %COLOR_TITLE%       Proceso de optimizacion finalizado          %COLOR_RESET%
echo %COLOR_TITLE%===================================================%COLOR_RESET%
echo.
echo %COLOR_PAUSE%Presiona cualquier tecla para salir...%COLOR_RESET%
pause >nul
exit
