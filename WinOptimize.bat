@echo off
:: ############################################################################
:: # OPTIMIZADOR WINDOWS 11 - RENDIMIENTO v5.2 ULTIMATE                       #
:: ############################################################################
:: # Autor: FranVi                                                            #
:: ############################################################################

setlocal EnableDelayedExpansion
chcp 65001 >nul
title OPTIMIZADOR ULTIMATE - WINDOWS 11 [v5.2]
mode con: cols=100 lines=40

:: Generar caracter ESC para colores ANSI
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "CLR=!ESC![0m"
set "RED=!ESC![31m"
set "GRN=!ESC![32m"
set "YLW=!ESC![33m"
set "BLU=!ESC![34m"
set "CYN=!ESC![36m"
set "WHT=!ESC![37m"

:: 1. Comprobar Privilegios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%[!] ERROR: Se requieren privilegios de Administrador.%CLR%
    pause
    exit /b
)

:: Configuracion de Log
set "LOG_NAME=WinOptimize_Log.txt"
set "LOG_FILE=%USERPROFILE%\Desktop\%LOG_NAME%"
if not exist "%USERPROFILE%\Desktop" set "LOG_FILE=C:\%LOG_NAME%"

echo ################################################# > "!LOG_FILE!"
echo # LOG DE OPERACIONES - OPTIMIZADOR WINDOWS 11     # >> "!LOG_FILE!"
echo # Fecha: %date% %time%                          # >> "!LOG_FILE!"
echo ################################################# >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

:menu
cls
echo %CYN%================================================================================%CLR%
echo %WHT%          OPTIMIZADOR AVANZADO WINDOWS 11 - ULTIMATE v5.2 %CLR%
echo %CYN%================================================================================%CLR%
echo.
echo  Selecciona una accion:
echo.
echo  [1] %GRN%OPTIMIZACION ESTANDAR%CLR%
echo  [2] %RED%OPTIMIZACION EXTREME / GAMER%CLR%
echo  [3] %YLW%DESHACER TODOS LOS CAMBIOS (Restaurar valores defecto)%CLR%
echo  [4] %WHT%SALIR%CLR%
echo.
echo  Log actual: !LOG_FILE!
echo %CYN%--------------------------------------------------------------------------------%CLR%
set /p opt="%YLW% Elige una opcion [1-4]: %CLR%"

if "%opt%"=="1" (set "isExtreme=false" & set "isRestore=false" & set "total=12" & goto start_process)
if "%opt%"=="2" (set "isExtreme=true" & set "isRestore=false" & set "total=16" & goto start_process)
if "%opt%"=="3" (set "isExtreme=false" & set "isRestore=true" & set "total=14" & goto start_process)
if "%opt%"=="4" (exit /b)
goto menu

:start_process
echo INICIO DE OPERACION: Opcion %opt% seleccionado >> "!LOG_FILE!"
set "current=0"
cls

if "!isRestore!"=="true" goto restore_logic

:: --- LOGICA DE OPTIMIZACION ---

set /a current+=1
call :step !current! !total! "LIMPIEZA DE TEMPORALES"
del /q /s "%TEMP%\*" >nul 2>&1
rd /s /q "%windir%\SoftwareDistribution\Download" >nul 2>&1
md "%windir%\SoftwareDistribution\Download" >nul 2>&1
echo [+] Temporales y Cache de Windows Update limpiados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "ELIMINACION DE PREFETCH Y LOGS"
del /q /s "C:\Windows\Prefetch\*" >nul 2>&1
for /f %%i in ('wevtutil el 2^>nul') do wevtutil cl "%%i" >nul 2>&1
echo [+] Prefetch y registros de eventos vaciados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "ACTIVANDO PLAN DE MAXIMO RENDIMIENTO"
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg -h off >nul 2>&1
echo [+] Plan Maximo Rendimiento activado e Hibernacion desactivada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO SERVICIOS INNECESARIOS"
for %%s in (DiagTrack dmwappushservice SysMain WerSvc Webclient) do (
    sc config "%%s" start= disabled >nul 2>&1
    sc stop "%%s" >nul 2>&1
    echo [!] Servicio %%s: Desactivado. >> "!LOG_FILE!"
)

set /a current+=1
call :step !current! !total! "AJUSTES DE INTERFAZ"
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Optimizacion de interfaz (Registro) aplicada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION DE PRIORIDAD DE CPU"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
echo [+] Prioridad de CPU ajustada a 38 (Foco Apps). >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "MANTENIMIENTO DE ALMACENAMIENTO (DISM)"
dism /online /cleanup-image /startcomponentcleanup /quiet /norestart >nul 2>&1
echo [+] Limpieza de componentes DISM completada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION DE RED Y DNS"
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [+] Pila TCP/IP y DNS optimizados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO POWER THROTTLING"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Power Throttling desactivado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO BING EN BUSQUEDA"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Bing Search desactivado del sistema. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "AJUSTES DE LATENCIA MULTIMEDIA"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Registros de respuesta de red y sistema ajustados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO LIMITACIONES PCI"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
echo [+] Visibilidad de ajustes PCI en planes de energia desbloqueada. >> "!LOG_FILE!"

if "!isExtreme!"=="false" goto end_process

:: EXTREME BLOQUE
set /a current+=1
call :step !current! !total! "HABILITANDO GPU HAGS"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
echo [+] Extreme: GPU HAGS Activado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DEBLOAT: APPS BASURA"
powershell -Command "Get-AppxPackage *TikTok*,*DisneyPlus*,*Microsoft.Messaging* | Remove-AppxPackage" >nul 2>&1
echo [+] Extreme: Debloat de apps completado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO TAREAS TELEMETRIA"
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
echo [+] Extreme: Tareas de telemetria desactivadas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "ACTIVANDO MODO GAMER PRO"
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Extreme: Modo Gamer Pro activado. >> "!LOG_FILE!"

goto end_process

:: --- LOGICA DE RESTAURACION ---
:restore_logic

set /a current+=1
call :step !current! !total! "RESTAURANDO SERVICIOS"
for %%s in (SysMain Webclient WerSvc) do (sc config "%%s" start= auto >nul 2>&1 & sc start "%%s" >nul 2>&1)
sc config "DiagTrack" start= delayed-auto >nul 2>&1
echo [R] Servicios restaurados a valores por defecto. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO ANIMACIONES"
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "400" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] Animaciones de interfaz restauradas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO PRIORIDAD DE CPU"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 2 /f >nul 2>&1
echo [R] Prioridad de CPU restaurada (Valor 2). >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO PLAN DE ENERGIA EQUILIBRADO"
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
powercfg -h on >nul 2>&1
echo [R] Plan Equilibrado activado e Hibernacion activada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO BING SEARCH"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] Bing Search re-habilitado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO RED Y DNS"
netsh int tcp set global autotuninglevel=normal >nul 2>&1
echo [R] Configuracion autotuning de red restaurada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO POWER THROTTLING"
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PowerThrottlingOff" /f >nul 2>&1
echo [R] Power Throttling restaurado a estado original. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO LATENCIA MULTIMEDIA"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
echo [R] Latencia multimedia restaurada (Defaults). >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESHABILITANDO GPU HAGS"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] GPU HAGS Desactivado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RE-HABILITANDO TAREAS TELEMETRIA"
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1
echo [R] Tareas de telemetria re-activadas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTABLECER CONFIGURACION GAME MODE"
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f >nul 2>&1
echo [R] Configuracion Gamer restaurada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "LIMPIEZA FINAL"
ipconfig /flushdns >nul 2>&1
echo [R] Limpieza DNS de seguridad. >> "!LOG_FILE!"

goto end_process

:end_process
cls
echo %GRN%================================================================================%CLR%
if "!isRestore!"=="true" (
    echo %WHT%                 RESTAURACION COMPLETADA! [OK]%CLR%
    echo OPERACION FINALIZADA: Sistema restaurado con exito. >> "!LOG_FILE!"
) else (
    echo %WHT%                 OPTIMIZACION COMPLETADA! [OK]%CLR%
    echo OPERACION FINALIZADA: Sistema optimizado con exito. >> "!LOG_FILE!"
)
echo %GRN%================================================================================%CLR%
echo.
echo  %WHT%Archivo log generado en:%CLR%
echo  %CYN%!LOG_FILE!%CLR%
echo.
echo %RED%  REINICIA TU ORDENADOR PARA APLICAR LOS CAMBIOS!%CLR%
echo.
pause
exit /b

:: --- FUNCION PASOS ---
:step
set /a pct=(%~1 * 100) / %~2
set /a filled=(%~1 * 40) / %~2
set /a empty=40 - %filled%
set "bar="
for /L %%i in (1,1,%filled%) do set "bar=!bar!#"
for /L %%i in (1,1,%empty%) do set "bar=!bar! "
cls
echo.
echo  %WHT%ESTADO: [%CYN%!bar!%WHT%] !pct!%%%CLR%
echo  %WHT%ACCION: %YLW%%~3%CLR%
echo.
exit /b
