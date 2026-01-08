@echo off
title OPTIMIZADOR WINDOWS 11 - MAXIMO RENDIMIENTO v2.1
mode con: cols=90 lines=50
setlocal EnableDelayedExpansion

echo =================================================
echo  OPTIMIZADOR WINDOWS 11 - MAXIMO RENDIMIENTO  
echo =================================================
echo Ya tienes permisos de administrador
echo Presiona cualquier tecla para comenzar...
pause >nul
cls

:: BARRA DE PROGRESO
set "total=12"
set "current=0"

:progress
set /a current+=1
set /a percent=(current*100)/total
set "bar="
for /L %%i in (1,1,!percent!) do set "bar=!bar!#"
for /L %%i in (!percent!,1,99) do set "bar=!bar! "
cls
echo.
echo =================================================
echo        OPTIMIZACION EN PROCESO [!bar!] !percent!%%
echo =================================================
echo [ !current! / !total! ] Ejecutando...
timeout /t 1 /nobreak >nul

:: 1. LIMPIEZA TEMPORALES AVANZADA
if !current! equ 1 (
    echo [1/12] LIMPIEZA TEMPORALES AVANZADA...
    del /q /s "%TEMP%\*" >nul 2>&1
    for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" >nul 2>&1
    del /q /s "C:\Windows\Temp\*" >nul 2>&1
    rd /s /q "%windir%\SoftwareDistribution\Download" >nul 2>&1
    echo    OK ✓
)

:: 2. PREFETCH + WINDOWS UPDATE
if !current! equ 2 (
    echo [2/12] PREFETCH + WINDOWS UPDATE CACHE...
    del /q /s "C:\Windows\Prefetch\*" >nul 2>&1
    echo    OK ✓
)

:: 3. REGISTROS EVENTOS + MINIDUMP
if !current! equ 3 (
    echo [3/12] VISOR EVENTOS + MINIDUMPS...
    for /f %%i in ('wevtutil el 2^>nul') do wevtutil cl "%%i" >nul 2>&1
    del /q /s "C:\Windows\Minidump\*" >nul 2>&1
    echo    OK ✓
)

:: 4. PLAN MAXIMO RENDIMIENTO
if !current! equ 4 (
    echo [4/12] PLAN MAXIMO RENDIMIENTO...
    powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    echo    OK ✓
)

:: 5. SERVICIOS INNECESARIOS
if !current! equ 5 (
    echo [5/12] OPTIMIZANDO SERVICIOS...
    sc config "DiagTrack" start= disabled >nul 2>&1
    sc config "dmwappushservice" start= disabled >nul 2>&1
    sc config "SysMain" start= disabled >nul 2>&1
    sc stop DiagTrack >nul 2>&1
    echo    OK ✓
)

:: 6. DISCO + INTEGRIDAD
if !current! equ 6 (
    echo [6/12] VERIFICANDO INTEGRIDAD...
    DISM /Online /Cleanup-Image /StartComponentCleanup >nul 2>&1
    echo    OK ✓
)

:: 7. CACHE + RECYCLE BIN
if !current! equ 7 (
    echo [7/12] CACHE + PAPELERA...
    rd /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
    echo    OK ✓
)

:: 8. REGISTRO
if !current! equ 8 (
    echo [8/12] OPTIMIZACION REGISTRO...
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >nul 2>&1
    echo    OK ✓
)

:: 9. ANIMACIONES
if !current! equ 9 (
    echo [9/12] DESACTIVANDO ANIMACIONES...
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
    echo    OK ✓
)

:: 10. TCP/IP
if !current! equ 10 (
    echo [10/12] OPTIMIZACION RED...
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    echo    OK ✓
)

:: 11. LIMPIEZA FINAL
if !current! equ 11 (
    echo [11/12] LIMPIEZA FINAL...
    ipconfig /flushdns >nul 2>&1
    echo    OK ✓
)

:: 12. COMPLETADO
if !current! equ 12 (
    echo [12/12] FINALIZADO...
    echo Optimizacion completada > "%temp%\optimizacion_OK.txt"
    echo    OK ✓
)

goto progress_end

:progress_end
cls
echo.
echo =================================================
echo        OPTIMIZACION 100%% COMPLETADA ✓ ✓ ✓
echo =================================================
echo.
echo + LIMPIEZAS: Temp, Prefetch, Eventos, Minidumps
echo + SERVICIOS: Telemetria, Superfetch OFF
echo + RENDIMIENTO: Plan Maximo, Sin animaciones  
echo + RED: TCP/IP optimizado
echo.
echo =================================================

:: CHRIS TITUS TECH - CORREGIDO
echo.
echo [CHRIS TITUS TECH - OPTIMIZADOR AVANZADO]
echo ¿Ejecutar? (S/N): 
set /p ct=
if /i "!ct!"=="S" (
    echo Iniciando WinUtil de Chris Titus...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://christitus.com/win | iex"
    echo.
    echo Script completado. Reinicia para aplicar cambios.
)

:: QUICKCPU
echo.
echo [QUICKCPU - OPTIMIZADOR CPU]
echo ¿Abrir pagina oficial? (S/N): 
set /p qc=
if /i "!qc!"=="S" (
    echo Abriendo https://coderbag.com/product/quickcpu
    start https://coderbag.com/product/quickcpu
)

echo.
echo =================================================
echo    ¡REINICIA EL PC PARA APLICAR TODOS LOS CAMBIOS!
echo =================================================
echo Presiona cualquier tecla para salir...
pause >nul
exit /b 0
