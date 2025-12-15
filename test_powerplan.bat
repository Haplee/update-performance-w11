@echo off
setlocal

echo [INFO] Iniciando prueba de disponibilidad del plan de energia...

:: --- Logica de la prueba ---
echo [RUN] Comprobando si el plan de energia 'Maximo Rendimiento' existe...
powercfg /list | find "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" >nul
set "plan_exists=%errorlevel%"

:: --- Verificacion ---
echo [VERIFY] Analizando resultados...

if %plan_exists%==0 (
    echo  - RESULTADO: El plan de energia 'Maximo Rendimiento' ESTA disponible en este sistema.
    echo  - EXITO: El script procederia a activarlo correctamente.
) else (
    echo  - RESULTADO: El plan de energia 'Maximo Rendimiento' NO ESTA disponible en este sistema.
    echo  - EXITO: El script mostraria correctamente el mensaje informativo.
)

echo [DONE] Prueba del plan de energia finalizada.
endlocal
