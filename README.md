# WinOptimize Script (.bat)

## Descripción

**WinOptimize** es un script de procesamiento por lotes (`.bat`) diseñado para ser una solución de un solo clic para la limpieza y optimización de sistemas operativos Windows. El script es fácil de usar y automatiza varias tareas para mejorar el rendimiento del sistema.

Este repositorio también incluye una página web estática lista para ser publicada en GitHub Pages, que sirve como portal de presentación y descarga del script.

## Funcionalidades del Script

- **Limpieza de Archivos Temporales**: Borra el contenido de las carpetas `%TEMP%` y `C:\Windows\Temp`.
- **Limpieza de Prefetch**: Vacía la carpeta `C:\Windows\Prefetch` para optimizar los tiempos de arranque.
- **Limpieza del Visor de Eventos**: Elimina todos los registros de eventos de Windows.
- **Plan de Energía**: Activa el plan de energía de "Máximo Rendimiento" para un rendimiento óptimo.
- **Optimización Adicional**: Ejecuta el script de Chris Titus Tech para aplicar optimizaciones avanzadas.
- **Descarga de QuickCPU**: Abre la página de descarga oficial de QuickCPU en el navegador.

## Instrucciones de Uso

El uso del script es muy sencillo:

1.  **Descargar el Script**:
    -   Descarga el archivo `WinOptimize.bat` desde el botón en la [página del proyecto](https://Haplee.github.io/update-performance-w11/).
    -   **Importante**: El enlace del botón de descarga en la página ya está configurado para este repositorio.

2.  **Ejecutar como Administrador**:
    -   Haz clic derecho sobre el archivo `WinOptimize.bat` que descargaste.
    -   Selecciona la opción **"Ejecutar como administrador"**.
    -   El script se encargará de solicitar los permisos necesarios y comenzará el proceso.
3.  **Seguir las Indicaciones**: El script te guiará a través de los pasos en una ventana de comandos.

## Publicación en GitHub Pages

La página web de este proyecto está en la carpeta `/docs` y está lista para ser desplegada.

1.  **Sube el contenido a tu repositorio** de GitHub.
2.  Ve a **Settings > Pages** en tu repositorio.
3.  En la sección "Build and deployment", selecciona la rama `main` (o `master`) y la carpeta `/docs` como fuente.
4.  Guarda los cambios. Tu página estará disponible en `https://Haplee.github.io/update-performance-w11/`.

## Creación de un Archivo Ejecutable (.exe) (Opcional)

Si deseas convertir el archivo `.bat` en un `.exe`, puedes usar una herramienta de terceros como "Bat To Exe Converter".

1.  **Busca y descarga** un convertidor de "Bat a Exe".
2.  **Carga el archivo** `WinOptimize.bat` en la herramienta.
3.  **Configura y compila** el `.exe` a tu gusto.

**Nota de seguridad**: Compilar el archivo tú mismo te da la certeza de que el `.exe` es seguro y se basa en el código que has revisado.

## Cómo Clonar el Repositorio

Para obtener una copia local de este proyecto, usa el siguiente comando:

```bash
git clone https://github.com/Haplee/update-performance-w11.git
```