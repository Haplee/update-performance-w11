@echo off
setlocal

echo [INFO] ===============================================
echo [INFO]            INICIANDO SUITE DE PRUEBAS
echo [INFO] ===============================================
echo.

echo [TEST] --- Ejecutando test_fix.bat ---
call test_fix.bat
echo.

echo [TEST] --- Ejecutando test_performance.bat ---
call test_performance.bat
echo.

echo [TEST] --- Ejecutando test_powerplan.bat ---
call test_powerplan.bat
echo.

echo [TEST] --- Ejecutando test_security_warning.bat ---
call test_security_warning.bat
echo.

echo [INFO] ===============================================
echo [INFO]           SUITE DE PRUEBAS FINALIZADA
echo [INFO] ===============================================

endlocal
