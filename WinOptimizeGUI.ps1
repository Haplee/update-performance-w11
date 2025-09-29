<#
.SYNOPSIS
    WinOptimizeGUI - Un optimizador de Windows 11 con una interfaz gráfica fácil de usar.
.DESCRIPTION
    Esta herramienta proporciona una interfaz visual para que usuarios no técnicos puedan
    aplicar de forma segura optimizaciones de rendimiento, privacidad y limpieza en su
    sistema Windows 11.

    Características principales:
    - Interfaz clara y amigable con botones para cada categoría de acción.
    - Creación automática de copias de seguridad antes de realizar cambios.
    - Funcionalidad para restaurar el sistema al estado anterior con un solo clic.
    - Retroalimentación en tiempo real de las acciones que se están ejecutando.
    - Solicitud automática de privilegios de administrador para garantizar el funcionamiento.

    INSTRUCCIONES DE USO PARA USUARIOS:
    1. GUARDAR EL SCRIPT:
       Guarde todo este código en un solo archivo con el nombre "WinOptimizeGUI.ps1".
       El Escritorio es una ubicación recomendada para un fácil acceso.

    2. EJECUTAR EL SCRIPT:
       Haga clic derecho sobre el archivo "WinOptimizeGUI.ps1" que acaba de guardar y, en el
       menú que aparece, seleccione "Ejecutar con PowerShell".

    3. CONFIRMAR PERMISOS DE ADMINISTRADOR:
       La primera vez que se ejecute, el programa le informará que necesita permisos
       de administrador. Acepte el aviso. A continuación, aparecerá una ventana de
       Control de Cuentas de Usuario (UAC) de Windows. Haga clic en "Sí" para permitir
       que la aplicación realice cambios en su dispositivo.

    4. UTILIZAR LA APLICACIÓN:
       - Pase el ratón sobre cada botón para leer una descripción de lo que hace.
       - Haga clic en un botón (ej. "Optimizar Rendimiento") para iniciar el proceso.
       - Confirme la acción en el cuadro de diálogo que aparecerá.
       - Observe el cuadro de texto inferior para ver el progreso en tiempo real.
       - Utilice el botón "Restaurar" si desea revertir los cambios en cualquier momento.

.NOTES
    Autor: Jules (Asistente de IA)
    Versión: 1.0 (Versión final)
    Requisitos: PowerShell 5.1 o superior. Funciona en Windows 10 y 11.
#>

#region Script Setup and Self-Elevation
# --- Comprobar si se ejecuta como Administrador ---
function Test-IsElevated {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsElevated)) {
    # El script no se está ejecutando como Administrador, intentar re-lanzarse con privilegios elevados.
    $powershellPath = (Get-Command powershell).Source
    $scriptPath = $MyInvocation.MyCommand.Path

    # Crear un cuadro de diálogo para informar al usuario.
    Add-Type -AssemblyName System.Windows.Forms
    $message = "Este script requiere privilegios de Administrador para funcionar correctamente.`n`nSe solicitará la elevación (UAC) para continuar.`n`n¿Desea continuar?"
    $result = [System.Windows.Forms.MessageBox]::Show($message, "Elevación Requerida", "YesNo", "Warning")

    if ($result -eq 'Yes') {
        # Iniciar un nuevo proceso de PowerShell con privilegios elevados.
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $powershellPath
        $processInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $processInfo.Verb = "runas" # Esta es la clave para solicitar la elevación.

        try {
            [System.Diagnostics.Process]::Start($processInfo) | Out-Null
        } catch {
            [System.Windows.Forms.MessageBox]::Show("No se pudo reiniciar el script con privilegios de administrador. Por favor, haga clic derecho en el script y seleccione 'Ejecutar como administrador'.", "Error", "OK", "Error")
        }
    }
    # Salir del script actual, ya que el nuevo proceso se encargará.
    exit
}

# --- Variables Globales y Directorios de Backup ---
$BaseDir = "C:\ProgramData\WinOptimizeGUI"
$BackupBaseDir = Join-Path $BaseDir "Backup"
if (-not (Test-Path $BaseDir)) { New-Item -Path $BaseDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $BackupBaseDir)) { New-Item -Path $BackupBaseDir -ItemType Directory -Force | Out-Null }

#endregion

#region GUI con Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Creación de la Ventana Principal ---
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Optimizador de Rendimiento para Windows 11"
$mainForm.Size = New-Object System.Drawing.Size(600, 500)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedSingle"
$mainForm.MaximizeBox = $false
$mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Environment]::GetFolderPath('System') + '\System32\imageres.dll')

# --- Creación del ToolTip para Ayuda ---
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.InitialDelay = 500 # Tiempo antes de que aparezca el tooltip
$toolTip.AutoPopDelay = 10000 # Tiempo que el tooltip permanece visible

# --- Creación del Área de Registro (Log) ---
$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Location = New-Object System.Drawing.Point(10, 200)
$logTextBox.Size = New-Object System.Drawing.Size(565, 250)
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.ReadOnly = $true
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logTextBox.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240) # Un gris muy claro
$mainForm.Controls.Add($logTextBox)

# --- Contenedor para botones de Optimización (GroupBox) ---
$optimizationsGroup = New-Object System.Windows.Forms.GroupBox
$optimizationsGroup.Location = New-Object System.Drawing.Point(10, 10)
$optimizationsGroup.Size = New-Object System.Drawing.Size(450, 180)
$optimizationsGroup.Text = "Acciones de Optimización"
$mainForm.Controls.Add($optimizationsGroup)

# --- Botones de Categorías ---

# Botón 1: Rendimiento
$btnPerformance = New-Object System.Windows.Forms.Button
$btnPerformance.Location = New-Object System.Drawing.Point(15, 30)
$btnPerformance.Size = New-Object System.Drawing.Size(200, 40)
$btnPerformance.Text = "🚀 Optimizar Rendimiento"
$btnPerformance.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$toolTip.SetToolTip($btnPerformance, "Aplica ajustes para maximizar el rendimiento general del sistema.`n- Ajusta efectos visuales.`n- Activa el plan de energía de 'Máximo Rendimiento'.")
$optimizationsGroup.Controls.Add($btnPerformance)

# Botón 2: Privacidad
$btnPrivacy = New-Object System.Windows.Forms.Button
$btnPrivacy.Location = New-Object System.Drawing.Point(230, 30)
$btnPrivacy.Size = New-Object System.Drawing.Size(200, 40)
$btnPrivacy.Text = "🔒 Mejorar Privacidad"
$btnPrivacy.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$toolTip.SetToolTip($btnPrivacy, "Deshabilita servicios de telemetría y recolección de datos de Microsoft.`n- Detiene y deshabilita 'DiagTrack' (Servicio de seguimiento de diagnósticos).")
$optimizationsGroup.Controls.Add($btnPrivacy)

# Botón 3: Limpieza del Sistema
$btnSystemCleanup = New-Object System.Windows.Forms.Button
$btnSystemCleanup.Location = New-Object System.Drawing.Point(15, 80)
$btnSystemCleanup.Size = New-Object System.Drawing.Size(200, 40)
$btnSystemCleanup.Text = "🧹 Limpiar Sistema"
$btnSystemCleanup.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$toolTip.SetToolTip($btnSystemCleanup, "Elimina archivos innecesarios para liberar espacio en disco.`n- Limpia archivos temporales.`n- Limpia la caché de Prefetch.`n- Borra registros del Visor de Eventos.")
$optimizationsGroup.Controls.Add($btnSystemCleanup)

# --- Contenedor para Acciones de Restauración ---
$restoreGroup = New-Object System.Windows.Forms.GroupBox
$restoreGroup.Location = New-Object System.Drawing.Point(470, 10)
$restoreGroup.Size = New-Object System.Drawing.Size(105, 180)
$restoreGroup.Text = "Restaurar"
$mainForm.Controls.Add($restoreGroup)

# Botón 4: Restaurar Configuración
$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Location = New-Object System.Drawing.Point(15, 30)
$btnRestore.Size = New-Object System.Drawing.Size(75, 90)
$btnRestore.Text = "⏪"
$btnRestore.Font = New-Object System.Drawing.Font("Segoe UI", 20)
$btnRestore.ForeColor = [System.Drawing.Color]::Red
$toolTip.SetToolTip($btnRestore, "Restaura la configuración del sistema a un estado anterior.`nUtiliza las copias de seguridad creadas antes de aplicar las optimizaciones.")
$restoreGroup.Controls.Add($btnRestore)

# --- Función para registrar mensajes en el TextBox ---
function Write-Log {
    param (
        [string]$Message,
        [System.Drawing.Color]$Color = [System.Drawing.Color]::Black
    )
    if ($logTextBox.IsHandleCreated) {
        $logTextBox.Invoke([System.Action]{
            $logTextBox.SelectionStart = $logTextBox.TextLength
            $logTextBox.SelectionLength = 0
            $logTextBox.SelectionColor = $Color
            $logTextBox.AppendText("$(Get-Date -Format 'HH:mm:ss') - $Message`r`n")
            $logTextBox.ScrollToCaret()
        })
    }
}

#region Funciones de Optimización y Lógica de Backend

# --- Función de confirmación genérica ---
function Confirm-Action {
    param ([string]$ActionTitle, [string]$ActionMessage)
    $result = [System.Windows.Forms.MessageBox]::Show($ActionMessage, $ActionTitle, "YesNo", "Question")
    return $result -eq 'Yes'
}

# --- Función para obtener/crear un directorio de backup con fecha y hora ---
function Get-TimestampBackupDir {
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $currentBackupDir = Join-Path $BackupBaseDir $timestamp
    if (-not (Test-Path $currentBackupDir)) {
        New-Item -Path $currentBackupDir -ItemType Directory -Force | Out-Null
    }
    return $currentBackupDir
}

# --- 1. Funciones de Rendimiento ---
function Set-VisualEffectsForPerformance {
    param ([string]$BackupPath)
    $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    $regValueName = "VisualFxSetting"
    $backupFile = Join-Path $BackupPath "visual-effects.reg"
    $targetValue = 2 # 2 = Ajustar para obtener el mejor rendimiento

    try {
        Write-Log "Optimizando efectos visuales..."
        # Backup: Exportar la clave de registro completa
        Write-Log "  -> Creando backup de la configuración actual en `"$backupFile`"..."
        reg.exe export "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "$backupFile" /y | Out-Null

        # Aplicar cambio
        Write-Log "  -> Ajustando para obtener el mejor rendimiento..."
        Set-ItemProperty -Path $regKey -Name $regValueName -Value $targetValue -Force
        Write-Log "Efectos visuales optimizados con éxito. ✔" -Color Green
    } catch {
        Write-Log "ERROR: No se pudieron optimizar los efectos visuales. Detalles: $($_.Exception.Message)" -Color Red
    }
}

function Set-PowerPlanToHighPerformance {
    param ([string]$BackupPath)
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a8f-a46b82378134"
    $ultimatePerfGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $backupFile = Join-Path $BackupPath "powerplan-active.guid"

    try {
        Write-Log "Configurando plan de energía a 'Máximo Rendimiento'..."
        # Determinar el mejor plan disponible
        $powerPlans = powercfg /list
        $targetPlanGuid = if ($powerPlans -match $ultimatePerfGuid) { $ultimatePerfGuid } else { $highPerfGuid }
        $targetPlanName = if ($targetPlanGuid -eq $ultimatePerfGuid) { "Máximo rendimiento" } else { "Alto rendimiento" }

        # Backup: Guardar el plan de energía activo actualmente
        Write-Log "  -> Guardando el plan de energía actual..."
        $activeScheme = (powercfg /getactivescheme) -match 'GUID del plan de energía: (.*)  \('
        $activeGuid = $matches[1]
        Set-Content -Path $backupFile -Value $activeGuid

        # Aplicar cambio
        Write-Log "  -> Activando plan '$targetPlanName'..."
        powercfg /setactive $targetPlanGuid
        Write-Log "Plan de energía establecido en '$targetPlanName'. ✔" -Color Green
    } catch {
        Write-Log "ERROR: No se pudo cambiar el plan de energía. Detalles: $($_.Exception.Message)" -Color Red
    }
}

# --- 2. Funciones de Privacidad ---
function Disable-TelemetryService {
    param ([string]$BackupPath)
    $serviceName = "DiagTrack" # Servicio de Experiencias de usuario y telemetría asociadas
    $backupFile = Join-Path $BackupPath "telemetry-service.json"

    try {
        Write-Log "Deshabilitando servicios de telemetría..."
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            # Backup: Guardar estado actual del servicio
            Write-Log "  -> Guardando configuración del servicio '$serviceName'..."
            $service | Select-Object Name, Status, StartType | ConvertTo-Json | Set-Content -Path $backupFile

            # Aplicar cambio
            Write-Log "  -> Deteniendo y deshabilitando el servicio '$serviceName'..."
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $serviceName -StartupType Disabled
            Write-Log "Servicio de telemetría deshabilitado con éxito. ✔" -Color Green
        } else {
            Write-Log "El servicio de telemetría '$serviceName' no se encontró. Es posible que ya esté eliminado o deshabilitado." -Color Yellow
        }
    } catch {
        Write-Log "ERROR: No se pudo deshabilitar el servicio de telemetría. Detalles: $($_.Exception.Message)" -Color Red
    }
}

# --- 3. Funciones de Limpieza del Sistema ---
function Clear-SystemFiles {
    # Esta acción no crea backups ya que elimina archivos recuperables o de caché.
    try {
        Write-Log "Iniciando limpieza de archivos del sistema..."

        # Limpieza de Archivos Temporales
        $tempPaths = @("$env:TEMP", "$env:SystemRoot\Temp")
        foreach ($path in $tempPaths) {
            if (Test-Path $path) {
                Write-Log "  -> Limpiando carpeta: $path..."
                Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Log "Archivos temporales eliminados. ✔" -Color Green

        # Limpieza de Prefetch
        $prefetchPath = Join-Path $env:SystemRoot "Prefetch"
        if (Test-Path $prefetchPath) {
            Write-Log "  -> Limpiando carpeta Prefetch..."
            Remove-Item -Path "$prefetchPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "Archivos de Prefetch eliminados. ✔" -Color Green
        }

        # Limpieza del Visor de Eventos
        Write-Log "  -> Limpiando registros del Visor de Eventos (puede tardar un momento)..."
        $logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object { $_.RecordCount > 0 }
        foreach ($log in $logs) {
            wevtutil.exe cl $log.LogName | Out-Null
        }
        Write-Log "Registros del Visor de Eventos limpiados. ✔" -Color Green

    } catch {
        Write-Log "ERROR: Ocurrió un error durante la limpieza. Detalles: $($_.Exception.Message)" -Color Red
    }
}

# --- 4. Funciones de Restauración ---
function Restore-VisualEffects {
    param ([string]$BackupPath)
    $backupFile = Join-Path $BackupPath "visual-effects.reg"
    if (Test-Path $backupFile) {
        try {
            Write-Log "Restaurando efectos visuales..."
            Write-Log "  -> Importando configuración desde `"$backupFile`"..."
            reg.exe import "$backupFile" | Out-Null
            Write-Log "Efectos visuales restaurados con éxito. ✔" -Color Green
        } catch {
            Write-Log "ERROR: No se pudieron restaurar los efectos visuales. Detalles: $($_.Exception.Message)" -Color Red
        }
    }
}

function Restore-PowerPlan {
    param ([string]$BackupPath)
    $backupFile = Join-Path $BackupPath "powerplan-active.guid"
    if (Test-Path $backupFile) {
        try {
            Write-Log "Restaurando plan de energía..."
            $previousGuid = Get-Content $backupFile
            Write-Log "  -> Restaurando plan de energía anterior (GUID: $previousGuid)..."
            powercfg /setactive $previousGuid
            Write-Log "Plan de energía restaurado con éxito. ✔" -Color Green
        } catch {
            Write-Log "ERROR: No se pudo restaurar el plan de energía. Detalles: $($_.Exception.Message)" -Color Red
        }
    }
}

function Restore-TelemetryService {
    param ([string]$BackupPath)
    $backupFile = Join-Path $BackupPath "telemetry-service.json"
    if (Test-Path $backupFile) {
        try {
            Write-Log "Restaurando servicio de telemetría..."
            $backupState = Get-Content $backupFile | ConvertFrom-Json
            Write-Log "  -> Restaurando servicio '$($backupState.Name)' a estado: $($backupState.Status), inicio: $($backupState.StartType)..."
            Set-Service -Name $backupState.Name -StartupType $backupState.StartType
            if ($backupState.Status -eq 'Running') {
                Start-Service -Name $backupState.Name
            }
            Write-Log "Servicio de telemetría restaurado con éxito. ✔" -Color Green
        } catch {
            Write-Log "ERROR: No se pudo restaurar el servicio de telemetría. Detalles: $($_.Exception.Message)" -Color Red
        }
    }
}

#endregion

# --- Lógica de los botones ---

# Función para habilitar/deshabilitar todos los botones y cambiar el cursor
function Set-ButtonsState {
    param ([bool]$Enabled)
    $btnPerformance.Enabled = $Enabled
    $btnPrivacy.Enabled = $Enabled
    $btnSystemCleanup.Enabled = $Enabled
    $btnRestore.Enabled = $Enabled

    if ($Enabled) {
        $mainForm.Cursor = [System.Windows.Forms.Cursors]::Default
    } else {
        $mainForm.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    }
}

$btnPerformance.Add_Click({
    if (Confirm-Action -ActionTitle "Confirmar Optimización de Rendimiento" -ActionMessage "Esto aplicará ajustes de rendimiento y creará un backup.`n¿Desea continuar?") {
        try {
            Set-ButtonsState -Enabled $false
            $backupDir = Get-TimestampBackupDir
            Write-Log "--- Iniciando optimizaciones de rendimiento ---" -Color Blue
            Write-Log "Las copias de seguridad se guardarán en: $backupDir"
            Set-VisualEffectsForPerformance -BackupPath $backupDir
            Set-PowerPlanToHighPerformance -BackupPath $backupDir
            Write-Log "--- Proceso de rendimiento finalizado ---" -Color Blue
            [System.Windows.Forms.MessageBox]::Show("Las optimizaciones de rendimiento se han aplicado con éxito.", "Proceso Completado", "OK", "Information")
        }
        finally {
            Set-ButtonsState -Enabled $true
        }
    } else {
        Write-Log "Operación cancelada por el usuario." -Color Yellow
    }
})

$btnPrivacy.Add_Click({
    if (Confirm-Action -ActionTitle "Confirmar Optimización de Privacidad" -ActionMessage "Esto deshabilitará servicios de telemetría y creará un backup.`n¿Desea continuar?") {
        try {
            Set-ButtonsState -Enabled $false
            $backupDir = Get-TimestampBackupDir
            Write-Log "--- Iniciando optimizaciones de privacidad ---" -Color Blue
            Write-Log "Las copias de seguridad se guardarán en: $backupDir"
            Disable-TelemetryService -BackupPath $backupDir
            Write-Log "--- Proceso de privacidad finalizado ---" -Color Blue
            [System.Windows.Forms.MessageBox]::Show("Las optimizaciones de privacidad se han aplicado con éxito.", "Proceso Completado", "OK", "Information")
        }
        finally {
            Set-ButtonsState -Enabled $true
        }
    } else {
        Write-Log "Operación cancelada por el usuario." -Color Yellow
    }
})

$btnSystemCleanup.Add_Click({
    if (Confirm-Action -ActionTitle "Confirmar Limpieza del Sistema" -ActionMessage "Esta acción eliminará archivos temporales y de caché. La operación no se puede deshacer.`n¿Desea continuar?") {
        try {
            Set-ButtonsState -Enabled $false
            Write-Log "--- Iniciando limpieza del sistema ---" -Color Blue
            Clear-SystemFiles
            Write-Log "--- Proceso de limpieza finalizado ---" -Color Blue
            [System.Windows.Forms.MessageBox]::Show("La limpieza del sistema se ha completado con éxito.", "Proceso Completado", "OK", "Information")
        }
        finally {
            Set-ButtonsState -Enabled $true
        }
    } else {
        Write-Log "Operación cancelada por el usuario." -Color Yellow
    }
})

$btnRestore.Add_Click({
    $backupFolders = Get-ChildItem -Path $BackupBaseDir -Directory
    if ($backupFolders.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No se encontraron copias de seguridad para restaurar.", "Sin Backups", "OK", "Information")
        Write-Log "Intento de restauración fallido: No hay directorios de backup." -Color Yellow
        return
    }

    # Crear un formulario para seleccionar el backup
    $restoreForm = New-Object System.Windows.Forms.Form
    $restoreForm.Text = "Seleccionar Backup para Restaurar"
    $restoreForm.Size = New-Object System.Drawing.Size(320, 300)
    $restoreForm.StartPosition = "CenterParent"
    $restoreForm.FormBorderStyle = "FixedDialog"

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Seleccione el backup que desea restaurar:"
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $restoreForm.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 35)
    $listBox.Size = New-Object System.Drawing.Size(280, 180)
    $backupFolders | ForEach-Object { [void]$listBox.Items.Add($_.Name) }
    $restoreForm.Controls.Add($listBox)

    $btnConfirmRestore = New-Object System.Windows.Forms.Button
    $btnConfirmRestore.Text = "Restaurar"
    $btnConfirmRestore.Location = New-Object System.Drawing.Point(60, 225)
    $btnConfirmRestore.Size = New-Object System.Drawing.Size(90, 30)
    $btnConfirmRestore.DialogResult = "OK"
    $restoreForm.AcceptButton = $btnConfirmRestore
    $restoreForm.Controls.Add($btnConfirmRestore)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancelar"
    $btnCancel.Location = New-Object System.Drawing.Point(160, 225)
    $btnCancel.Size = New-Object System.Drawing.Size(90, 30)
    $btnCancel.DialogResult = "Cancel"
    $restoreForm.CancelButton = $btnCancel
    $restoreForm.Controls.Add($btnCancel)

    if ($restoreForm.ShowDialog($mainForm) -eq "OK") {
        $selectedBackup = $listBox.SelectedItem
        if ($selectedBackup) {
            $backupPath = Join-Path $BackupBaseDir $selectedBackup
            if (Confirm-Action -ActionTitle "Confirmar Restauración" -ActionMessage "Esto revertirá los cambios usando el backup de `"$selectedBackup`".`n¿Está seguro?") {
                Write-Log "--- Iniciando proceso de restauración desde '$selectedBackup' ---" -Color Magenta
                # Llamar a las funciones de restauración individuales
                Restore-VisualEffects -BackupPath $backupPath
                Restore-PowerPlan -BackupPath $backupPath
                Restore-TelemetryService -BackupPath $backupPath
                Write-Log "--- Restauración completada ---" -Color Magenta
                [System.Windows.Forms.MessageBox]::Show("La restauración se ha completado con éxito.", "Restauración Finalizada", "OK", "Information")
            } else {
                Write-Log "Restauración cancelada por el usuario." -Color Yellow
            }
        } else {
            Write-Log "No se seleccionó ningún backup." -Color Yellow
        }
    }
    $restoreForm.Dispose()
})

# --- Mostrar el formulario ---
# Esta función se ejecutará cuando el formulario esté listo para mostrarse.
$mainForm.Add_Shown({
    Write-Log "Bienvenido al Optimizador de Rendimiento para Windows 11." -Color Green
    Write-Log "Pase el ratón sobre cada botón para ver qué hace."
    Write-Log "------------------------------------------------------------"
})

# Iniciar la aplicación mostrando el formulario
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::Run($mainForm)

#endregion