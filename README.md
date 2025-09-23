# WinOptimize Script

## Descripción

**WinOptimize** es un script de PowerShell diseñado para realizar una limpieza y optimización integral en sistemas operativos Windows. Con una sola ejecución, el script se encarga de eliminar archivos innecesarios, limpiar registros y configurar el sistema para ofrecer el máximo rendimiento posible.

Este repositorio también incluye una página web estática lista para ser publicada en GitHub Pages, que sirve como portal de presentación y descarga del script.

## Funcionalidades del Script

- **Limpieza de Archivos Temporales**: Borra el contenido de las carpetas `%TEMP%` y `C:\Windows\Temp`.
- **Limpieza de Prefetch**: Vacía la carpeta `C:\Windows\Prefetch` para optimizar los tiempos de arranque.
- **Limpieza del Visor de Eventos**: Elimina todos los registros de eventos de Windows (Aplicación, Seguridad, Sistema, etc.).
- **Plan de Energía**: Activa el plan de energía de "Máximo Rendimiento" para un rendimiento óptimo.
- **Optimización Adicional**: Ejecuta el script de Chris Titus Tech (`christitus.com/win`) para aplicar optimizaciones avanzadas.
- **Descarga de QuickCPU**: Facilita el acceso a la herramienta QuickCPU abriendo la página de descarga oficial en el navegador.

## Instrucciones de Uso del Script

1.  **Descargar el Script**:
    -   Puedes descargarlo directamente desde la [página del proyecto](https://TU_USUARIO.github.io/TU_REPOSITORIO/) (una vez publicada).
    -   O puedes hacer clic derecho en el archivo `WinOptimize.ps1` en este repositorio y seleccionar "Guardar enlace como...".

2.  **Ejecutar como Administrador**:
    -   Haz clic derecho sobre el archivo `WinOptimize.ps1` que descargaste.
    -   Selecciona la opción **"Ejecutar con PowerShell"**.
    -   El script solicitará permisos de administrador para poder realizar las tareas de limpieza y configuración. Es crucial que se los concedas.

3.  **Seguir las Indicaciones**:
    -   El script mostrará en tiempo real las acciones que está realizando.
    -   Al finalizar, abrirá el navegador para la descarga de QuickCPU y esperará a que presiones "Enter" para cerrarse.

## Publicación en GitHub Pages

La página web de este proyecto está en la carpeta `/docs` y está lista para ser desplegada con GitHub Pages.

1.  **Sube el contenido a tu repositorio**: Asegúrate de que todos los archivos, incluyendo la carpeta `docs`, estén en tu repositorio de GitHub.
2.  **Ve a la configuración del repositorio**: En tu repositorio, haz clic en la pestaña "Settings" (Configuración).
3.  **Selecciona la sección "Pages"**: En el menú de la izquierda, busca y haz clic en "Pages".
4.  **Configura la fuente**:
    -   En la sección "Build and deployment", bajo "Source", selecciona **"Deploy from a branch"**.
    -   En la sección "Branch", asegúrate de que la rama sea `main` (o `master`) y la carpeta sea `/docs`.
    -   Haz clic en **"Save"**.
5.  **Visita tu página**: GitHub tardará uno o dos minutos en publicar tu sitio. La URL será algo como: `https://tu-usuario.github.io/tu-repositorio/`.

## Creación de un Archivo Ejecutable (.exe) (Opcional)

Por motivos de seguridad y transparencia, el archivo principal de este proyecto es un script de PowerShell (`.ps1`). De esta forma, puedes revisar el código antes de ejecutarlo.

Si prefieres tener un archivo `.exe` para mayor portabilidad, puedes compilarlo tú mismo siguiendo estos pasos:

1.  **Abrir PowerShell como Administrador**: Busca "PowerShell" en el menú de inicio, haz clic derecho y selecciona "Ejecutar como administrador".

2.  **Instalar el módulo `ps2exe`**: Este módulo permite convertir scripts de PowerShell a ejecutables. Ejecuta el siguiente comando:
    ```powershell
    Install-Module -Name ps2exe
    ```
    Si te pregunta sobre el repositorio de confianza (PSGallery), escribe `S` y presiona Enter.

3.  **Navegar hasta la carpeta del script**: Usa el comando `cd` para moverte a la carpeta donde descargaste `WinOptimize.ps1`.
    ```powershell
    cd C:\Ruta\A\Tu\Carpeta
    ```

4.  **Compilar el script**: Ejecuta el siguiente comando para crear el `.exe`.
    ```powershell
    ps2exe -inputFile 'WinOptimize.ps1' -outputFile 'WinOptimize.exe'
    ```

5.  **¡Listo!** Encontrarás el archivo `WinOptimize.exe` en la misma carpeta.

**Nota de seguridad**: Ten cuidado al ejecutar archivos `.exe` de fuentes desconocidas. Al compilarlo tú mismo, te aseguras de que el ejecutable contiene exactamente el código del script que has revisado.

## Cómo Clonar el Repositorio

Para obtener una copia local de este proyecto, puedes clonar el repositorio usando el siguiente comando en tu terminal:

```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
```

No olvides reemplazar `tu-usuario` y `tu-repositorio` con tus datos.