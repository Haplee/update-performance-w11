@echo off
:: ############################################################################
:: # OPTIMIZADOR WINDOWS 11 - RENDIMIENTO v6.0 ULTIMATE PLUS               #
:: ############################################################################
:: # Autor: FranVi                                                            #
:: ############################################################################

setlocal EnableDelayedExpansion
chcp 65001 >nul
title OPTIMIZADOR ULTIMATE PLUS - WINDOWS 11 [v6.0]
mode con: cols=100 lines=40

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "CLR=!ESC![0m"
set "RED=!ESC![31m"
set "GRN=!ESC![32m"
set "YLW=!ESC![33m"
set "BLU=!ESC![34m"
set "CYN=!ESC![36m"
set "WHT=!ESC![37m"

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%[!] ERROR: Se requieren privilegios de Administrador.%CLR%
    pause
    exit /b
)

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
echo %WHT%          OPTIMIZADOR AVANZADO WINDOWS 11 - ULTIMATE v6.0 %CLR%
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

if "%opt%"=="1" (set "isExtreme=false" & set "isRestore=false" & set "total=18" & goto start_process)
if "%opt%"=="2" (set "isExtreme=true" & set "isRestore=false" & set "total=24" & goto start_process)
if "%opt%"=="3" (set "isExtreme=false" & set "isRestore=true" & set "total=16" & goto start_process)
if "%opt%"=="4" (exit /b)
goto menu

:start_process
echo INICIO DE OPERACION: Opcion %opt% seleccionado >> "!LOG_FILE!"
set "current=0"
cls

if "!isRestore!"=="true" goto restore_logic

:: --- OPTIMIZACION ESTANDAR ---

set /a current+=1
call :step !current! !total! "LIMPIEZA DE TEMPORALES Y CACHE"
del /q /s "%TEMP%\*" >nul 2>&1
del /q /s "%windir%\Temp\*" >nul 2>&1
rd /s /q "%windir%\SoftwareDistribution\Download" >nul 2>&1
md "%windir%\SoftwareDistribution\Download" >nul 2>&1
del /q /s "%localappdata%\Microsoft\Windows\INetCache\*" >nul 2>&1
echo [+] Temporales y Cache limpiados. >> "!LOG_FILE!"

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
powercfg /change monitor-timeout-ac 0 >nul 2>&1
powercfg /change disk-timeout-ac 0 >nul 2>&1
echo [+] Plan Maximo Rendimiento activado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO SERVICIOS INNECESARIOS"
for %%s in (DiagTrack dmwappushservice SysMain WerSvc Webclient W32Time Spooler RemoteRegistry SSDPSRV) do (
    sc config "%%s" start= disabled >nul 2>&1
    sc stop "%%s" >nul 2>&1
    echo [!] Servicio %%s: Desactivado. >> "!LOG_FILE!"
)

set /a current+=1
call :step !current! !total! "OPTIMIZANDO REGISTRO DE INTERFAZ"
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualFX" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeeks /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Optimizacion de interfaz aplicada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION DE PRIORIDAD DE CPU"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Prioridad de CPU ajustada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "MANTENIMIENTO DE ALMACENAMIENTO (DISM)"
dism /online /cleanup-image /startcomponentcleanup /quiet /norestart >nul 2>&1
dism /online /cleanup-image /checkhealth >nul 2>&1
echo [+] Limpieza de componentes DISM completada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION DE RED Y DNS"
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global ecn=disabled >nul 2>&1
netsh int ip set global routing=disabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [+] Pila TCP/IP y DNS optimizados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO POWER THROTTLING"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Power Throttling desactivado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO BING EN BUSQUEDA"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Bing Search desactivado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "AJUSTES DE LATENCIA MULTIMEDIA"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Latencia multimedia optimizada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO LIMITACIONES PCI"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
echo [+] Ajustes PCI desbloqueados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZANDO EXPLORADOR DE ARCHIVOS"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Explorador de archivos optimizado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZANDO SYSPREP Y BOOT"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "PurgeCaches" /t REG_SZ /d "sfc /cquarantine scan" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Optimizacion de memoria avanzada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO INDEXADO"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\I/O System" /v "AsyncMachineQuota" /t REG_DWORD /d 0 /f >nul 2>&1
sc config "WSearch" start= disabled >nul 2>&1
sc stop "WSearch" >nul 2>&1
echo [+] Indexado de Windows desactivado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZANDO DNS Y MTU"
for /f "tokens=2*" %%a in ('netsh interface show interface ^| findstr /i "connected"') do set "NETINT=%%b"
if defined NETINT (
    netsh interface ipv4 set dns name="!NETINT!" static 8.8.8.8 >nul 2>&1
    netsh interface ipv4 add dns name="!NETINT!" 8.8.4.4 index=2 >nul 2>&1
    netsh interface ipv6 set dns name="!NETINT!" static 2001:4860:4860::8888 >nul 2>&1
) else (
    netsh interface ipv4 set dns name="Ethernet" static 8.8.8.8 >nul 2>&1
    netsh interface ipv4 add dns name="Ethernet" 8.8.4.4 index=2 >nul 2>&1
    netsh interface ipv6 set dns name="Ethernet" static 2001:4860:4860::8888 >nul 2>&1
)
echo [+] DNS de Google configurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO ACTUALIZACIONES AUTOMATICAS"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "AUOptions" /t REG_DWORD /d 1 /f >nul 2>&1
sc config "wuauserv" start= disabled >nul 2>&1
echo [+] Actualizaciones automaticas ajustadas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "LIMPIEZA DE HISTORIAL Y COOKIES"
del /q /s "%localappdata%\Microsoft\Windows\WebCache\*" >nul 2>&1
echo [+] Cache de Edge/Chrome limpiado. >> "!LOG_FILE!"

if "!isExtreme!"=="false" goto end_process

:: --- MODO EXTREME / GAMER ---

set /a current+=1
call :step !current! !total! "HABILITANDO GPU HAGS Y HARDWARE SCHEDULING"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "SchedulerAccessPolicy" /t REG_DWORD /d 4 /f >nul 2>&1
echo [+] Extreme: GPU HAGS y Hardware Scheduling activados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DEBLOAT: APPS BASURA"
powershell -Command "Get-AppxPackage *TikTok*,*DisneyPlus*,*Microsoft.Messaging*,*Microsoft.Office.OneNote*,*Spotify*,*CandyCrush* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Extreme: Debloat de apps completado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO TAREAS TELEMETRIA"
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\CeipParticipant" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Application Experience\AitArtist" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MocaMetadataProvider" /Disable >nul 2>&1
echo [+] Extreme: Tareas de telemetria desactivadas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "ACTIVANDO MODO GAMER PRO"
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNewGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FluentCaptureMode" /t REG_DWORD /d 0 /f >nul 2>&1
echo [+] Extreme: Modo Gamer Pro activado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION EXTREMA DE CPU"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Processor" /v "C-states" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\486e2516-1c6e-49ce-b172-9d686d0e71b7" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
echo [+] Extreme: C-states CPU desactivados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "OPTIMIZACION GPU DEDICADA"
reg add "HKLM\SOFTWARE\Intel\GFX" /v "LoopTuningPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\Display" /v "PowerMizerEnable" /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Extreme: GPU optimizada al maximo. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "DESACTIVANDO WINDOWS DEFENDER (OPCIONAL)"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
echo [+] Extreme: Windows Defender parcialmente desactivado. >> "!LOG_FILE!"

goto end_process

:: --- RESTAURACION ---

:restore_logic

set /a current+=1
call :step !current! !total! "RESTAURANDO SERVICIOS"
for %%s in (SysMain Webclient WerSvc W32Time Spooler RemoteRegistry SSDPSRV) do (sc config "%%s" start= auto >nul 2>&1 & sc start "%%s" >nul 2>&1)
sc config "DiagTrack" start= delayed-auto >nul 2>&1
sc config "WSearch" start= delayed-auto >nul 2>&1
echo [R] Servicios restaurados. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO ANIMACIONES"
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "400" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeeks /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] Animaciones restauradas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO PRIORIDAD DE CPU"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 2 /f >nul 2>&1
echo [R] Prioridad de CPU restaurada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO PLAN DE ENERGIA"
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
powercfg -h on >nul 2>&1
echo [R] Plan Equilibrado activado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO BING SEARCH"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] Bing Search restaurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO RED"
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=default >nul 2>&1
echo [R] Configuracion de red restaurada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO POWER THROTTLING"
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PowerThrottlingOff" /f >nul 2>&1
echo [R] Power Throttling restaurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO LATENCIA MULTIMEDIA"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
echo [R] Latencia multimedia restaurada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO HAGS"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo [R] GPU HAGS restaurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RE-HABILITANDO TELEMETRIA"
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1
echo [R] Telemetria re-activada. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO GAME MODE"
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f >nul 2>&1
echo [R] Game Mode restaurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO ACTUALIZACIONES"
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\AUOptions" /f >nul 2>&1
sc config "wuauserv" start= auto >nul 2>&1
echo [R] Actualizaciones restauradas. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "RESTAURANDO WINDOWS DEFENDER"
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f >nul 2>&1
echo [R] Windows Defender restaurado. >> "!LOG_FILE!"

set /a current+=1
call :step !current! !total! "LIMPIEZA DNS FINAL"
ipconfig /flushdns >nul 2>&1
echo [R] DNS limpiado. >> "!LOG_FILE!"

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
