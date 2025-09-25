<#
.SYNOPSIS
    Audita, aplica y revierte un conjunto de optimizaciones de rendimiento para Windows 11.

.DESCRIPTION
    Este script proporciona un conjunto de herramientas para mejorar el rendimiento de Windows 11
    de forma segura y reversible. Está diseñado para ser ejecutado por usuarios técnicos o administradores
    en entornos de laboratorio o corporativos.

    Modos de operación:
    - Audit: Realiza un análisis del sistema y muestra las optimizaciones recomendadas sin aplicar cambios.
    - Apply: Aplica las optimizaciones de rendimiento. Crea un backup completo antes de realizar cualquier cambio.
    - Revert: Restaura el sistema al estado exacto en que se encontraba antes de aplicar los cambios, utilizando el backup más reciente o uno específico.

    El script es idempotente; ejecutar 'Apply' varias veces no causará cambios adicionales ni errores.
    Todos los cambios son reversibles a través del modo 'Revert'.

    ADVERTENCIA: Aunque este script está diseñado para ser seguro, úselo bajo su propio riesgo.
    Siempre es recomendable probarlo en un entorno de no producción primero.
    En entornos gestionados por MDM/Intune, algunas configuraciones pueden ser revertidas o controladas por políticas corporativas.

.PARAMETER Mode
    Especifica el modo de operación.
    - Audit: Solo informa sobre el estado actual y los cambios potenciales.
    - Apply: Aplica las optimizaciones y crea un backup.
    - Revert: Revierte los cambios usando un backup.

.PARAMETER WhatIf
    Muestra lo que sucedería si se ejecutara el cmdlet, pero no ejecuta el cmdlet.

.PARAMETER Quiet
    Ejecuta el script sin ninguna interacción del usuario (confirmaciones). Útil para automatización.

.PARAMETER LogPath
    Ruta opcional para almacenar los archivos de log. Por defecto es 'C:\ProgramData\update-performance-w11\logs'.

.PARAMETER BackupTimestamp
    En modo 'Revert', especifica el timestamp del backup a restaurar (formato yyyyMMddHHmmss).
    Si no se especifica, se utiliza el backup más reciente.

.PARAMETER ExportReport
    Ruta opcional para exportar un informe consolidado en formato JSON con los resultados de los benchmarks y los cambios realizados.

.EXAMPLE
    PS> .\update-performance-w11.ps1
    Muestra el menú interactivo para elegir el modo de operación.

.EXAMPLE
    PS> .\update-performance-w11.ps1 -Mode Apply -Verbose
    Aplica las optimizaciones mostrando información detallada de cada paso.

.EXAMPLE
    PS> .\update-performance-w11.ps1 -Mode Apply -WhatIf
    Muestra todos los cambios que se realizarían en el modo 'Apply' sin ejecutarlos realmente.

.EXAMPLE
    PS> .\update-performance-w11.ps1 -Mode Revert
    Restaura el sistema utilizando el backup más reciente.

.EXAMPLE
    PS> .\update-performance-w11.ps1 -Mode Revert -BackupTimestamp 20231027103000
    Restaura el sistema utilizando un backup específico.

.NOTES
    Autor: Jules (Asistente de IA)
    Versión: 1.0
    Requisitos: PowerShell 5.1+, se recomienda PowerShell 7+. Ejecutar como Administrador.
#>

#region USO RÁPIDO Y RECOMENDACIONES DE DESPLIEGUE
# -------------------------------------------------------------------------------------
# USO RÁPIDO:
# 1. Guarda este script como 'update-performance-w11.ps1' en tu Escritorio.
# 2. Haz clic derecho en el archivo > "Ejecutar con PowerShell". El script detectará que no está
#    elevado y se volverá a lanzar como Administrador (pedirá confirmación UAC).
#
# CREAR ACCESO DIRECTO CON ELEVACIÓN AUTOMÁTICA:
# 1. Clic derecho en el Escritorio > Nuevo > Acceso directo.
# 2. En "Escriba la ubicación del elemento", pega lo siguiente (ajusta la ruta si es necesario):
#    powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Desktop\update-performance-w11.ps1"
# 3. Haz clic en "Siguiente", dale un nombre (ej. "Optimizador W11") y "Finalizar".
# 4. Clic derecho en el nuevo acceso directo > Propiedades.
# 5. Ve a la pestaña "Acceso directo" > Botón "Opciones avanzadas...".
# 6. Marca la casilla "Ejecutar como administrador" y Aceptar > Aceptar.
# 7. Ahora, al hacer doble clic en el acceso directo, se ejecutará directamente con privilegios elevados.
#
# FIRMA DE CÓDIGO (RECOMENDADO PARA ENTORNOS CORPORATIVOS):
# Para aumentar la seguridad, puedes firmar este script con un certificado de firma de código.
# 1. Obtén un certificado de firma de código (de una CA interna o pública).
# 2. Ejecuta en PowerShell:
#    $cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
#    Set-AuthenticodeSignature -FilePath "C:\ruta\a\update-performance-w11.ps1" -Certificate $cert
# 3. Ajusta la política de ejecución de PowerShell en los equipos cliente para permitir scripts firmados:
#    Set-ExecutionPolicy AllSigned
# -------------------------------------------------------------------------------------
#endregion

#region TESTS SUGERIDOS (Pester)
# -------------------------------------------------------------------------------------
# Si deseas crear pruebas unitarias para este script, puedes usar el framework Pester.
# Guarda el siguiente código como 'update-performance-w11.Tests.ps1' y ejecútalo con 'Invoke-Pester'.
#
# Describe 'update-performance-w11.ps1 - Optimizations' {
#     BeforeAll {
#         # Mock de funciones para no realizar cambios reales en el sistema
#         Mock -CommandName Set-ItemProperty -MockWith { Write-Output "Mocked Set-ItemProperty" }
#         Mock -CommandName powercfg -MockWith { Write-Output "Mocked powercfg" }
#         Mock -CommandName Set-Service -MockWith { Write-Output "Mocked Set-Service" }
#         # Importante: El script se debe poder "dot-sourcear" para probar funciones individuales.
#         . ".\update-performance-w11.ps1"
#     }
#
#     Context 'Set-VisualEffectsForPerformance' {
#         It 'Should attempt to set VisualFxSetting to 2' {
#             # Ejemplo de cómo podrías probar la lógica interna
#             # Esto requeriría refactorizar el script para que las funciones sean independientes
#             # y se puedan llamar desde un contexto de prueba.
#             Assert-DoesNotThrow { Set-VisualEffectsForPerformance -Mode Apply -BackupPath "C:\temp\backup" }
#         }
#     }
#
#     Context 'Set-PowerPlanHighPerformance' {
#         It 'Should attempt to set the high performance power plan' {
#             # Similar al anterior, se necesitaría poder llamar a la función directamente
#             Assert-DoesNotThrow { Set-PowerPlanHighPerformance -Mode Apply -BackupPath "C:\temp\backup" }
#         }
#     }
# }
# -------------------------------------------------------------------------------------
#endregion

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Especifica el modo de operación: Audit, Apply, o Revert.")]
    [ValidateSet('Audit', 'Apply', 'Revert')]
    [string]$Mode,

    [Parameter(Mandatory = $false, HelpMessage = "Ejecuta el script sin prompts de confirmación.")]
    [switch]$Quiet,

    [Parameter(Mandatory = $false, HelpMessage = "Ruta opcional para los archivos de log.")]
    [string]$LogPath,

    [Parameter(Mandatory = $false, HelpMessage = "En modo Revert, especifica el timestamp del backup a restaurar.")]
    [string]$BackupTimestamp,

    [Parameter(Mandatory = $false, HelpMessage = "Ruta para exportar un informe consolidado en formato JSON.")]
    [string]$ExportReport
)

#region Script Setup and Global Variables

# --- Detección de versión de PowerShell ---
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "Estás usando PowerShell $($PSVersionTable.PSVersion). El script está optimizado para PowerShell 7+ pero intentará funcionar. Algunas funciones como el formateo de tablas pueden ser limitadas."
}

# --- Detección de Elevación y Auto-Elevación ---
function Test-IsElevated {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsElevated)) {
    Write-Warning "Este script requiere privilegios de Administrador para funcionar correctamente."
    $promptMessage = "El script intentará reiniciarse como Administrador. ¿Deseas continuar?"

    if ($Quiet) {
        $doElevate = $true
    } else {
        $choice = Read-Host "$promptMessage (S/N)"
        if ($choice -match '^[sS]$') {
            $doElevate = $true
        } else {
            Write-Error "Operación cancelada por el usuario."
            exit 1
        }
    }

    if ($doElevate) {
        $params = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"")
        if ($Mode) { $params += "-Mode", $Mode }
        if ($Quiet) { $params += "-Quiet" }
        if ($LogPath) { $params += "-LogPath", $LogPath }
        if ($BackupTimestamp) { $params += "-BackupTimestamp", $BackupTimestamp }
        if ($ExportReport) { $params += "-ExportReport", $ExportReport }

        Start-Process powershell -Verb RunAs -ArgumentList $params
        exit
    }
}

# --- Variables Globales ---
$ScriptHash = (Get-FileHash -Path $PSCommandPath -Algorithm SHA256).Hash
$BaseDir = "C:\ProgramData\update-performance-w11"
$BackupBaseDir = Join-Path $BaseDir "backup"
$LogBaseDir = if ($LogPath) { $LogPath } else { Join-Path $BaseDir "logs" }
$Timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$CurrentBackupDir = Join-Path $BackupBaseDir $Timestamp

# --- Crear directorios necesarios ---
if ($pscmdlet.ShouldProcess($BaseDir, "Crear directorio base de la aplicación")) {
    if (-not (Test-Path $BaseDir)) { New-Item -Path $BaseDir -ItemType Directory -Force | Out-Null }
    if (-not (Test-Path $BackupBaseDir)) { New-Item -Path $BackupBaseDir -ItemType Directory -Force | Out-Null }
    if (-not (Test-Path $LogBaseDir)) { New-Item -Path $LogBaseDir -ItemType Directory -Force | Out-Null }
}
$LogFile = Join-Path $LogBaseDir "update-performance-w11-$($Timestamp).log.json"

#endregion

#region Helper Functions

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $true)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level,
        [string]$Details = ""
    )

    $logEntry = @{
        Timestamp = (Get-Date -Format 'o')
        Level     = $Level
        Message   = $Message
        Details   = $Details
        ScriptHash = $ScriptHash
    }

    $logJson = $logEntry | ConvertTo-Json -Depth 5
    $logJson | Out-File -FilePath $LogFile -Append -Encoding utf8

    # También mostrar en consola si no es modo silencioso
    if (-not $Quiet) {
        $color = @{
            INFO    = 'White'
            WARN    = 'Yellow'
            ERROR   = 'Red'
            SUCCESS = 'Green'
        }
        Write-Host "[$Level] $Message" -ForegroundColor $color[$Level]
        if ($Details) {
            Write-Host "  > $Details"
        }
    }
}

function Collect-Benchmark {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Stage, # 'baseline' o 'post-apply'
        [Parameter(Mandatory=$true)]
        [string]$BackupPath
    )

    $benchmarkDir = Join-Path $BackupPath "benchmarks"
    if ($pscmdlet.ShouldProcess($benchmarkDir, "Crear directorio de benchmarks")) {
        if (-not (Test-Path $benchmarkDir)) {
            New-Item -Path $benchmarkDir -ItemType Directory -Force | Out-Null
        }
    }

    Write-Log -Level INFO -Message "Iniciando recolección de benchmark ($Stage)..."

    # Priorizar Get-Counter por ser más seguro y no requerir WPR instalado.
    $counters = @(
        '\Procesador(_Total)\% de tiempo de procesador',
        '\Memoria\Megabytes disponibles',
        '\Disco físico(_Total)\Promedio de seg de disco/lectura',
        '\Disco físico(_Total)\Promedio de seg de disco/escritura',
        '\Disco físico(_Total)\Longitud promedio de la cola del disco'
    )
    $filePath = Join-Path $benchmarkDir "${Stage}-counters.csv"

    if ($pscmdlet.ShouldProcess($filePath, "Recolectar contadores de rendimiento")) {
        try {
            Write-Verbose "Recolectando contadores: $($counters -join ', ')"
            $data = Get-Counter -Counter $counters -SampleInterval 1 -MaxSamples 5
            $data.CounterSamples | Select-Object Path, CookedValue | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
            Write-Log -Level SUCCESS -Message "Benchmark ($Stage) guardado en $filePath"
            return $data.CounterSamples | Select-Object Path, CookedValue
        } catch {
            Write-Log -Level ERROR -Message "No se pudieron recolectar los contadores de rendimiento." -Details $_.Exception.Message
            return $null
        }
    }
}

#endregion

#region Optimization Functions

function Set-VisualEffectsForPerformance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Audit', 'Apply', 'Revert')][string]$Mode,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )

    $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    $regValueName = "VisualFxSetting"
    $backupFile = Join-Path $BackupPath "visual-effects.reg"
    $targetValue = 2 # 2 = Ajustar para obtener el mejor rendimiento

    switch ($Mode) {
        'Audit' {
            $currentValue = (Get-ItemProperty -Path $regKey -Name $regValueName -ErrorAction SilentlyContinue).$regValueName
            if ($currentValue -ne $targetValue) {
                Write-Log -Level INFO -Message "Efectos Visuales: Se recomienda 'Ajustar para obtener el mejor rendimiento'." -Details "Valor actual: $currentValue, Valor recomendado: $targetValue"
            } else {
                Write-Log -Level SUCCESS -Message "Efectos Visuales: Ya están optimizados para el rendimiento."
            }
        }
        'Apply' {
            Write-Log -Level INFO -Message "Optimizando efectos visuales..."
            # Backup
            if ($pscmdlet.ShouldProcess($regKey, "Exportar clave de registro para backup")) {
                reg.exe export "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "$backupFile" /y | Out-Null
            }
            # Apply
            if ($pscmdlet.ShouldProcess($regKey, "Establecer VisualFxSetting a '$targetValue'")) {
                Set-ItemProperty -Path $regKey -Name $regValueName -Value $targetValue -Force
                Write-Log -Level SUCCESS -Message "Efectos visuales ajustados para el mejor rendimiento."
            }
        }
        'Revert' {
            Write-Log -Level INFO -Message "Revirtiendo efectos visuales..."
            if (Test-Path $backupFile) {
                if ($pscmdlet.ShouldProcess($backupFile, "Importar clave de registro desde backup")) {
                    reg.exe import "$backupFile" | Out-Null
                    Write-Log -Level SUCCESS -Message "Efectos visuales restaurados desde el backup."
                }
            } else {
                Write-Log -Level WARN -Message "No se encontró archivo de backup para los efectos visuales en '$backupFile'."
            }
        }
    }
}

function Set-PowerPlanHighPerformance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Audit', 'Apply', 'Revert')][string]$Mode,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )

    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a8f-a46b82378134"
    $ultimatePerfGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $backupFile = Join-Path $BackupPath "powerplan-active.guid"

    # Determinar el mejor plan disponible
    $powerPlans = powercfg /list
    $targetPlanGuid = if ($powerPlans -match $ultimatePerfGuid) { $ultimatePerfGuid } else { $highPerfGuid }
    $targetPlanName = if ($targetPlanGuid -eq $ultimatePerfGuid) { "Ultimate Performance" } else { "High Performance" }

    switch ($Mode) {
        'Audit' {
            $activeScheme = (powercfg /getactivescheme) -match 'GUID del plan de energía: (.*)  \('
            $activeGuid = $matches[1]
            if ($activeGuid -ne $targetPlanGuid) {
                Write-Log -Level INFO -Message "Plan de energía: Se recomienda cambiar a '$targetPlanName'." -Details "Plan actual: $activeGuid"
            } else {
                Write-Log -Level SUCCESS -Message "Plan de energía: Ya está configurado en '$targetPlanName'."
            }
        }
        'Apply' {
            Write-Log -Level INFO -Message "Configurando el plan de energía a '$targetPlanName'..."
            # Backup
            $activeScheme = (powercfg /getactivescheme) -match 'GUID del plan de energía: (.*)  \('
            $activeGuid = $matches[1]
            if ($pscmdlet.ShouldProcess($backupFile, "Guardar GUID del plan de energía activo")) {
                Set-Content -Path $backupFile -Value $activeGuid
            }
            # Apply
            if ($pscmdlet.ShouldProcess($targetPlanName, "Establecer plan de energía activo")) {
                powercfg /setactive $targetPlanGuid
                Write-Log -Level SUCCESS -Message "Plan de energía establecido en '$targetPlanName'."
            }
        }
        'Revert' {
            Write-Log -Level INFO -Message "Revirtiendo plan de energía..."
            if (Test-Path $backupFile) {
                $previousGuid = Get-Content $backupFile
                if ($pscmdlet.ShouldProcess($previousGuid, "Restaurar plan de energía activo")) {
                    powercfg /setactive $previousGuid
                    Write-Log -Level SUCCESS -Message "Plan de energía restaurado al estado anterior."
                }
            } else {
                Write-Log -Level WARN -Message "No se encontró archivo de backup para el plan de energía en '$backupFile'."
            }
        }
    }
}

function Tune-WindowsSearch {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Audit', 'Apply', 'Revert')][string]$Mode,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )

    $serviceName = "WSearch"
    $backupFile = Join-Path $BackupPath "wsearch-service.json"

    # Esta optimización solo aplica a discos HDD. En SSD, el indexado es beneficioso.
    $diskType = (Get-PhysicalDisk | Where-Object { $_.BusType -ne 'File Backed Virtual' } | Select-Object -First 1).MediaType
    if ($diskType -ne 'HDD') {
        Write-Log -Level INFO -Message "Servicio de Búsqueda: No se requiere acción. El disco principal no es HDD (es $diskType)."
        return
    }

    switch ($Mode) {
        'Audit' {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq 'Running') {
                Write-Log -Level INFO -Message "Servicio de Búsqueda: Se recomienda deshabilitar el servicio en discos HDD." -Details "Estado actual: $($service.Status), Tipo de inicio: $($service.StartType)"
            } else {
                Write-Log -Level SUCCESS -Message "Servicio de Búsqueda: El servicio ya está detenido o no existe."
            }
        }
        'Apply' {
            Write-Log -Level INFO -Message "Ajustando el servicio de búsqueda de Windows para disco HDD..."
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                # Backup
                if ($pscmdlet.ShouldProcess($backupFile, "Guardar estado del servicio de búsqueda")) {
                    $service | Select-Object Name, Status, StartType | ConvertTo-Json | Set-Content -Path $backupFile
                }
                # Apply
                if ($pscmdlet.ShouldProcess($serviceName, "Detener y deshabilitar servicio")) {
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $serviceName -StartupType Disabled
                    Write-Log -Level SUCCESS -Message "Servicio de búsqueda de Windows detenido y deshabilitado."
                }
            }
        }
        'Revert' {
            Write-Log -Level INFO -Message "Revirtiendo configuración del servicio de búsqueda..."
            if (Test-Path $backupFile) {
                $backupState = Get-Content $backupFile | ConvertFrom-Json
                if ($pscmdlet.ShouldProcess($serviceName, "Restaurar servicio de búsqueda a tipo de inicio '$($backupState.StartType)'")) {
                    Set-Service -Name $serviceName -StartupType $backupState.StartType
                    if ($backupState.Status -eq 'Running') {
                        Start-Service -Name $serviceName
                    }
                    Write-Log -Level SUCCESS -Message "Servicio de búsqueda de Windows restaurado a su estado anterior."
                }
            } else {
                Write-Log -Level WARN -Message "No se encontró archivo de backup para el servicio de búsqueda en '$backupFile'."
            }
        }
    }
}

function Disable-StartupApps {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Audit', 'Apply', 'Revert')][string]$Mode,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )

    # Esta función es compleja y potencialmente riesgosa.
    # Por seguridad, solo se audita. La deshabilitación manual por parte del usuario es más segura.
    # En un futuro, se podría implementar una lógica para deshabilitar apps de terceros no firmadas.

    Write-Log -Level INFO -Message "Analizando aplicaciones de inicio..."
    $backupFile = Join-Path $BackupPath "startup-apps.csv"

    $startupLocations = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    $apps = foreach ($path in $startupLocations) {
        if (Test-Path $path) {
            Get-ItemProperty -Path $path | Get-Member -MemberType NoteProperty | ForEach-Object {
                $appName = $_.Name
                $appCommand = (Get-ItemProperty -Path $path)."$appName"
                [PSCustomObject]@{
                    Name     = $appName
                    Command  = $appCommand
                    Location = $path
                    Status   = 'Enabled'
                }
            }
        }
    }

    if ($Mode -eq 'Audit') {
        if ($apps.Count -gt 0) {
            Write-Log -Level INFO -Message "Se encontraron $($apps.Count) aplicaciones de inicio. Revisa la lista y deshabilita las innecesarias manualmente desde el Administrador de Tareas > Inicio."
            $apps | Format-Table -AutoSize | Out-String | Write-Host
            if ($pscmdlet.ShouldProcess($backupFile, "Exportar lista de apps de inicio a CSV")) {
                $apps | Export-Csv -Path $backupFile -NoTypeInformation -Encoding UTF8
            }
        } else {
            Write-Log -Level SUCCESS -Message "No se encontraron aplicaciones de inicio en las ubicaciones comunes del registro."
        }
    }

    if ($Mode -eq 'Apply') {
        Write-Log -Level WARN -Message "La deshabilitación automática de aplicaciones de inicio no está implementada por seguridad." -Details "Se realizará una auditoría en su lugar. Por favor, deshabilite las aplicaciones no deseadas desde el Administrador de Tareas."
        Disable-StartupApps -Mode Audit -BackupPath $BackupPath
    }

    if ($Mode -eq 'Revert') {
        Write-Log -Level INFO -Message "La reversión de aplicaciones de inicio no es aplicable ya que no se realizaron cambios."
    }
}

#endregion

#region Main Execution Logic

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "  Optimizador de Rendimiento para Windows 11  " -ForegroundColor White
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "  1. Auditar Sistema" -ForegroundColor Yellow
    Write-Host "     (Analiza el sistema y recomienda cambios sin modificar nada)"
    Write-Host
    Write-Host "  2. Aplicar Optimizaciones" -ForegroundColor Green
    Write-Host "     (Crea un backup y aplica las mejoras de rendimiento)"
    Write-Host
    Write-Host "  3. Revertir Cambios" -ForegroundColor Red
    Write-Host "     (Restaura el sistema al estado previo usando el último backup)"
    Write-Host
    Write-Host "  4. Salir" -ForegroundColor White
    Write-Host
}

function Invoke-Audit {
    Write-Log -Level INFO -Message "Iniciando modo Auditoría..."
    $auditBackupPath = Join-Path $BackupBaseDir "audit-$Timestamp"
    New-Item -Path $auditBackupPath -ItemType Directory -Force | Out-Null

    Collect-Benchmark -Stage "baseline" -BackupPath $auditBackupPath
    Set-VisualEffectsForPerformance -Mode Audit -BackupPath $auditBackupPath
    Set-PowerPlanHighPerformance -Mode Audit -BackupPath $auditBackupPath
    Tune-WindowsSearch -Mode Audit -BackupPath $auditBackupPath
    Disable-StartupApps -Mode Audit -BackupPath $auditBackupPath

    Write-Log -Level SUCCESS -Message "Auditoría completada. No se han realizado cambios en el sistema."
}

function Invoke-Apply {
    if (-not $Quiet) {
        $confirm = Read-Host "Estás a punto de aplicar cambios de rendimiento. Se creará un backup en '$CurrentBackupDir'. ¿Estás seguro de que quieres continuar? (S/N)"
        if ($confirm -notmatch '^[sS]$') {
            Write-Log -Level WARN -Message "Operación cancelada por el usuario."
            exit
        }
    }

    Write-Log -Level INFO -Message "Iniciando modo Aplicar... Backup se guardará en '$CurrentBackupDir'"
    if ($pscmdlet.ShouldProcess($CurrentBackupDir, "Crear directorio de backup para esta sesión")) {
        New-Item -Path $CurrentBackupDir -ItemType Directory -Force | Out-Null
    }

    # -- Benchmarking Pre-Aplicación --
    $baselineData = Collect-Benchmark -Stage "baseline" -BackupPath $CurrentBackupDir

    # -- Aplicación de Optimizaciones con Backup --
    Set-VisualEffectsForPerformance -Mode Apply -BackupPath $CurrentBackupDir -WhatIf:$WhatIfPreference
    Set-PowerPlanHighPerformance -Mode Apply -BackupPath $CurrentBackupDir -WhatIf:$WhatIfPreference
    Tune-WindowsSearch -Mode Apply -BackupPath $CurrentBackupDir -WhatIf:$WhatIfPreference
    Disable-StartupApps -Mode Apply -BackupPath $CurrentBackupDir -WhatIf:$WhatIfPreference # Actuará como auditoría

    # -- Benchmarking Post-Aplicación --
    $postApplyData = Collect-Benchmark -Stage "post-apply" -BackupPath $CurrentBackupDir

    Write-Log -Level SUCCESS -Message "Modo Aplicar completado. Se ha creado un backup en '$CurrentBackupDir'."

    # -- Exportar Informe --
    if ($ExportReport) {
        if ($pscmdlet.ShouldProcess($ExportReport, "Exportar informe consolidado")) {
            $report = @{
                ExecutionTimestamp = $Timestamp
                Mode = 'Apply'
                BackupPath = $CurrentBackupDir
                Changes = Get-ChildItem $CurrentBackupDir -Filter *.reg,*.guid,*.json,*.csv -Recurse | ForEach-Object {
                    @{
                        File = $_.Name
                        Optimization = $_.Directory.Name
                    }
                }
                Benchmark = @{
                    Baseline = $baselineData
                    PostApply = $postApplyData
                }
            }
            $report | ConvertTo-Json -Depth 5 | Set-Content -Path $ExportReport -Encoding UTF8
            Write-Log -Level SUCCESS -Message "Informe exportado a '$ExportReport'."
        }
    }
}

function Invoke-Revert {
    $revertBackupDir = if ($BackupTimestamp) {
        Join-Path $BackupBaseDir $BackupTimestamp
    } else {
        # Encontrar el backup más reciente
        Get-ChildItem -Path $BackupBaseDir -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    }

    if (-not $revertBackupDir -or -not (Test-Path $revertBackupDir.FullName)) {
        Write-Log -Level ERROR -Message "No se encontró un directorio de backup válido." -Details "Directorio buscado: $($revertBackupDir.FullName)"
        exit 1
    }

    $revertPath = $revertBackupDir.FullName

    if (-not $Quiet) {
        $confirm = Read-Host "Estás a punto de revertir los cambios usando el backup de '$($revertBackupDir.Name)'. ¿Estás seguro? (S/N)"
        if ($confirm -notmatch '^[sS]$') {
            Write-Log -Level WARN -Message "Operación de reversión cancelada por el usuario."
            exit
        }
    }

    Write-Log -Level INFO -Message "Iniciando modo Revertir usando backup de '$revertPath'..."

    Set-VisualEffectsForPerformance -Mode Revert -BackupPath $revertPath -WhatIf:$WhatIfPreference
    Set-PowerPlanHighPerformance -Mode Revert -BackupPath $revertPath -WhatIf:$WhatIfPreference
    Tune-WindowsSearch -Mode Revert -BackupPath $revertPath -WhatIf:$WhatIfPreference
    Disable-StartupApps -Mode Revert -BackupPath $revertPath -WhatIf:$WhatIfPreference # No hace nada, pero mantiene la consistencia

    Write-Log -Level SUCCESS -Message "Modo Revertir completado."
}


# --- Entry Point ---
if (-not $Mode) {
    # Modo Interactivo
    while ($true) {
        Show-Menu
        $choice = Read-Host "Selecciona una opción [1-4]"
        switch ($choice) {
            '1' { $Mode = 'Audit'; break }
            '2' { $Mode = 'Apply'; break }
            '3' { $Mode = 'Revert'; break }
            '4' { Write-Host "Saliendo..."; exit }
            default { Write-Warning "Opción no válida. Inténtalo de nuevo." ; Start-Sleep -Seconds 2 }
        }
    }
}

# --- Main Switch ---
try {
    switch ($Mode) {
        'Audit' { Invoke-Audit }
        'Apply' { Invoke-Apply }
        'Revert' { Invoke-Revert }
    }
    Write-Host "`nOperación '$Mode' finalizada con éxito." -ForegroundColor Green
} catch {
    Write-Log -Level ERROR -Message "Se ha producido un error crítico durante la ejecución." -Details $_.Exception.Message
    exit 1
}

#endregion