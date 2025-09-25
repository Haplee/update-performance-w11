# update-performance-w11: Optimizador de Rendimiento Seguro para Windows 11

[![Estado del Build](https://img.shields.io/badge/build-passing-green.svg)](https://github.com/Haplee/update-performance-w11)
[![Licencia](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Haplee/update-performance-w11/blob/main/LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)

Un script de PowerShell robusto y seguro para auditar, aplicar y revertir optimizaciones de rendimiento en Windows 11. Diseñado con la seguridad, la transparencia y la reversibilidad como prioridades.

---

## 🔥 Resumen Ejecutivo

Este repositorio contiene un único script de PowerShell, `Optimize-Windows.ps1`, que ofrece un método profesional para mejorar el rendimiento de Windows 11. A diferencia de otros scripts "optimizadores", esta herramienta **no ejecuta comandos peligrosos**, no descarga ejecutables de terceros y **cada cambio es 100% reversible**.

## ✅ Filosofía de Diseño: Seguridad Primero

Este script se construyó sobre tres pilares fundamentales:

1.  **Reversibilidad Total**: Antes de aplicar cualquier cambio, el script crea un **backup automático**. Si no estás satisfecho con los resultados, puedes ejecutar el modo `Revert` para restaurar tu sistema exactamente al estado en que se encontraba.
2.  **Transparencia (Modo Auditoría)**: ¿No estás seguro de qué cambios se aplicarán? Usa el modo `Audit`. El script analizará tu sistema y te dirá exactamente qué optimizaciones recomienda, **sin modificar absolutamente nada**.
3.  **Sin Cajas Negras**: El script no descarga ni ejecuta herramientas de fuentes no confiables. Todo lo que hace está contenido en el propio código, que es abierto y auditable por cualquiera.

## 🚀 Modos de Operación

El script se puede ejecutar en tres modos distintos. Si lo ejecutas sin parámetros, te mostrará un menú interactivo para que elijas.

### 1. Modo Auditoría (`-Mode Audit`)

Este es el modo más seguro y el recomendado para el primer uso. Analiza tu sistema en busca de posibles optimizaciones y genera un informe, pero no realiza ningún cambio.

**Para ejecutar en modo Auditoría:**
```powershell
.\Optimize-Windows.ps1 -Mode Audit
```

### 2. Modo Aplicar (`-Mode Apply`)

Este modo aplica las optimizaciones de rendimiento. Antes de hacer nada, crea un backup completo en `C:\ProgramData\update-performance-w11\backup\`.

**Para aplicar las optimizaciones:**
```powershell
.\Optimize-Windows.ps1 -Mode Apply
```

### 3. Modo Revertir (`-Mode Revert`)

Este modo restaura tu sistema al estado anterior utilizando el último backup creado. También puedes especificar un backup concreto si tienes varios.

**Para revertir los cambios:**
```powershell
.\Optimize-Windows.ps1 -Mode Revert
```

## 🛠️ Instrucciones de Uso

1.  **Descargar el Script**:
    *   Haz clic en el botón verde `Code` en la parte superior de esta página.
    *   Selecciona `Download ZIP`.
    *   Extrae el archivo `update-performance-w11-main.zip` en una carpeta de tu elección (por ejemplo, en tu Escritorio).

2.  **Ejecutar el Script**:
    *   Navega a la carpeta `src` que se encuentra dentro del directorio que extrajiste.
    *   Haz clic derecho sobre el archivo `Optimize-Windows.ps1`.
    *   Selecciona **"Ejecutar con PowerShell"**.
    *   El script detectará que necesita privilegios de administrador y pedirá permiso para reiniciarse con ellos (a través del Control de Cuentas de Usuario - UAC).

Aparecerá un menú interactivo para que elijas qué acción deseas realizar.

## ショートカットの作成 (Crear un Acceso Directo - Opcional)

Para un acceso más rápido, puedes crear un acceso directo en tu escritorio que ejecute el script directamente como administrador.

1.  Clic derecho en el Escritorio > **Nuevo** > **Acceso directo**.
2.  En "Escriba la ubicación del elemento", pega lo siguiente (ajusta la ruta si guardaste el script en otro lugar):
    ```
    powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\Desktop\update-performance-w11-main\src\Optimize-Windows.ps1"
    ```
3.  Haz clic en **Siguiente**, dale un nombre (ej. "Optimizador W11") y **Finalizar**.
4.  Clic derecho en el nuevo acceso directo > **Propiedades**.
5.  Ve a la pestaña "Acceso directo" > Botón **Opciones avanzadas...**.
6.  Marca la casilla **"Ejecutar como administrador"** y Aceptar > Aceptar.

Ahora, con un doble clic, el script se iniciará directamente en modo interactivo y con los permisos necesarios.

## ⚠️ Advertencia y Licencia

*   **Úsalo bajo tu propio riesgo.** Aunque este script está diseñado para ser seguro, siempre existe la posibilidad de que ocurran problemas inesperados. Se recomienda probarlo primero en un entorno que no sea de producción si es posible.
*   Este proyecto se distribuye bajo la **Licencia MIT**. Consulta el archivo `LICENSE` para más detalles.

---

*Este repositorio ha sido reestructurado para promover únicamente prácticas seguras y reversibles, eliminando scripts anteriores que no cumplían con estos estándares.*