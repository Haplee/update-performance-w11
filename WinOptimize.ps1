# Script para Optimización y Limpieza de Windows
# IMPORTANTE: Ejecutar este script con privilegios de Administrador.

# --- Limpieza de Archivos Temporales ---
Write-Host "Limpiando archivos temporales..."
$tempPaths = @(
    "$env:TEMP",
    "C:\Windows\Temp"
)
foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " - Carpeta limpiada: $path"
    } else {
        Write-Host " - La carpeta no existe: $path"
    }
}

# --- Limpieza de Prefetch ---
Write-Host "Limpiando archivos de Prefetch..."
$prefetchPath = "C:\Windows\Prefetch"
if (Test-Path $prefetchPath) {
    Remove-Item -Path "$prefetchPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " - Carpeta Prefetch limpiada."
} else {
    Write-Host " - La carpeta Prefetch no existe."
}

# --- Limpieza del Visor de Eventos ---
Write-Host "Limpiando registros del Visor de Eventos..."
wevtutil el | ForEach-Object {
    Write-Host " - Limpiando $_"
    wevtutil cl "$_" | Out-Null
}
Write-Host " - Todos los registros del Visor de Eventos han sido limpiados."

# --- Cambiar Plan de Energía a Máximo Rendimiento ---
Write-Host "Cambiando el plan de energía a 'Máximo Rendimiento'..."
# Busca el GUID del plan de Máximo Rendimiento
$highPerformancePlan = powercfg -list | Where-Object { $_ -match "Máximo rendimiento" } | ForEach-Object { $_.Split(' ')[3] }

if ($highPerformancePlan) {
    powercfg -setactive $highPerformancePlan
    Write-Host " - Plan de energía establecido a 'Máximo Rendimiento'."
} else {
    Write-Host " - No se pudo encontrar el plan de 'Máximo Rendimiento'. Puede que no exista en este sistema."
}

# --- Ejecución de script de Chris Titus Tech ---
Write-Host "Ejecutando el script de optimización de Chris Titus Tech..."
try {
    iwr -useb https://christitus.com/win | iex
} catch {
    Write-Host " - Error al ejecutar el script de Chris Titus. Verifica tu conexión a internet."
}


# --- Abrir navegador para descargar QuickCPU ---
Write-Host "Abriendo el navegador para descargar QuickCPU..."
$quickCpuUrl = "https://coderbag.com/product/quickcpu"
Start-Process $quickCpuUrl

Write-Host "--- Proceso de optimización finalizado ---"
Read-Host "Presiona Enter para salir."
