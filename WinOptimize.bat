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

:: --- Inicio del Script de Optimización ---
cls
echo ===================================================
echo      WinOptimize - Herramienta de Limpieza
echo ===================================================
echo.
echo Este script realizara las siguientes acciones:
echo  - Limpieza de archivos temporales.
echo  - Limpieza de la carpeta Prefetch.
echo  - Limpieza del Visor de Eventos.
echo  - Activacion del plan de Maximo Rendimiento.
echo  - Ejecucion del script de Chris Titus Tech.
echo  - Apertura de la pagina de descarga de QuickCPU.
echo.
pause
cls

:: --- Limpieza de Archivos Temporales ---
echo [INFO] Limpiando archivos temporales de usuario (%TEMP%)...
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%p in ("%TEMP%\*") do rmdir "%%p" /s /q >nul 2>&1
echo [INFO] Limpiando archivos temporales de Windows (C:\Windows\Temp)...
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
echo.

:: --- Limpieza de Prefetch ---
echo [INFO] Limpiando archivos de Prefetch (C:\Windows\Prefetch)...
del /f /s /q "C:\Windows\Prefetch\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Prefetch\*") do rmdir "%%p" /s /q >nul 2>&1
echo.

:: --- Limpieza del Visor de Eventos ---
echo [INFO] Limpiando todos los registros del Visor de Eventos...
for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a" >nul 2>nul
    echo  - Limpiado: %%a
)
echo.

:: --- Cambiar Plan de Energía a Máximo Rendimiento ---
echo [INFO] Cambiando el plan de energia a 'Maximo Rendimiento'...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo.

:: --- Ejecución de script de Chris Titus Tech (Opcional) ---
set /p response="[PREGUNTA] Desea ejecutar el script de optimizacion de Chris Titus Tech? (S/N): "
if /i "%response%"=="S" (
    echo [INFO] Ejecutando el script de optimizacion de Chris Titus Tech...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://christitus.com/win' -UseBasicParsing | iex"
) else (
    echo [INFO] Omitiendo el script de Chris Titus Tech.
)
echo.

:: --- Abrir navegador para descargar QuickCPU (Opcional) ---
set /p response="[PREGUNTA] Desea abrir la pagina para descargar QuickCPU? (S/N): "
if /i "%response%"=="S" (
    echo [INFO] Abriendo el navegador para descargar QuickCPU...
    start "" "https://coderbag.com/product/quickcpu"
) else (
    echo [INFO] Omitiendo la descarga de QuickCPU.
)
echo.

echo ===================================================
echo        Proceso de optimizacion finalizado
echo ===================================================
echo.
pause
exit
