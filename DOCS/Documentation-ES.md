# Documentación de MP3Player

## Descripción general

MP3Player es una aplicación de macOS basada en SwiftUI diseñada para reproducir archivos de audio MP3 y M4A con una interfaz limpia y moderna. La aplicación sigue las mejores prácticas de SwiftUI y demuestra el uso adecuado de las características modernas de concurrencia de Swift, gestión de estado e integraciones del sistema.

## Estructura del proyecto

El proyecto está organizado en varios componentes clave:

- **Mp3PlayerApp.swift**: Punto de entrada principal de la aplicación, define la estructura de la aplicación, los menús y los atajos de teclado
- **ContentView.swift**: Vista de interfaz de usuario principal con controles de reproducción y visualización de pistas
- **AudioPlayerManager.swift**: Gestiona la reproducción de audio usando AVAudioPlayer
- **PlaylistManager.swift**: Maneja la lógica de la lista de reproducción, el orden de las pistas y la funcionalidad aleatoria
- **Track.swift**: Modelo de datos que representa una pista de audio con metadatos
- **MenuBarManager.swift**: Gestiona el icono de la barra de menú y las notificaciones del sistema
- **ScrollingText.swift**: Vista personalizada para visualización de texto con desplazamiento animado
- **AppDelegate.swift**: Delegado de la aplicación para el manejo de eventos del sistema

## Características clave e implementación

### 1. Soporte de archivos de audio

**Formatos compatibles**: Archivos MP3 y M4A

**Implementación**:
- Usa `AVAudioPlayer` para la reproducción de audio (AudioPlayerManager.swift)
- Definiciones de UTType para filtrado de tipos de archivo: `.mp3` y `.mpeg4Audio`
- Extracción de metadatos usando `AVAsset` para recuperar título, artista y carátula del álbum

### 2. Mecanismos de carga de archivos

**Carga de archivo individual**:
- Diálogo de selección de archivos usando `NSOpenPanel`
- Soporte para abrir archivos a través del Finder (Abrir con...)
- Marcadores de ámbito de seguridad para acceso persistente a archivos

**Carga de directorio**:
- Enumeración recursiva de directorio para encontrar todos los archivos MP3/M4A
- Ordenación alfabética de pistas por nombre de archivo
- Carga perezosa de metadatos para prevenir limitación de tasa del sistema

**Detalles de implementación** (PlaylistManager.swift):
```swift
func loadFile(_ url: URL)              // Cargar archivo individual con metadatos inmediatos
func loadDirectory(_ url: URL)         // Cargar todos los archivos de audio del directorio
```

### 3. Controles de reproducción

**Controles disponibles**:
- Alternar Reproducir/Pausar
- Detener
- Pista anterior
- Pista siguiente
- Modo aleatorio

**Atajos de teclado** (Mp3PlayerApp.swift):
- `Ctrl+P`: Reproducir/Pausar
- `Ctrl+S`: Detener
- `Ctrl+A`: Pista anterior
- `Ctrl+N`: Pista siguiente
- `Ctrl+H`: Activar/desactivar aleatorio

**Implementación**:
- Los comandos de menú publican notificaciones a NotificationCenter
- ContentView observa las notificaciones y desencadena las acciones apropiadas
- Gestión de estado usando propiedades `@Published` en clases ObservableObject

### 4. Manejo de metadatos

**Metadatos extraídos**:
- Título de la canción
- Nombre del artista
- Carátula del álbum

**Estrategia de carga perezosa** (Track.swift):
- Al cargar un directorio, las pistas se crean sin metadatos (`loadMetadata: false`)
- Los metadatos se cargan bajo demanda cuando una pista comienza a reproducirse
- Previene la limitación de tasa de mensajes del sistema al cargar directorios grandes
- Usa async/await con AVAsset para concurrencia moderna

**Implementación clave**:
```swift
init(url: URL, loadMetadata: Bool = true)
```

### 5. Recursos de ámbito de seguridad

**Propósito**: Mantener permisos de acceso a archivos entre inicios de la aplicación

**Implementación** (AudioPlayerManager.swift, PlaylistManager.swift):
- Marcadores de ámbito de seguridad creados para archivos y directorios seleccionados por el usuario
- Ciclo de vida de acceso a recursos adecuado:
  - `startAccessingSecurityScopedResource()` antes de operaciones con archivos
  - `stopAccessingSecurityScopedResource()` después de completar
- Marcadores almacenados en UserDefaults para persistencia
- Manejo separado para archivos independientes vs. archivos cargados desde directorio

### 6. Persistencia de estado

**Estado guardado**:
- Última pista reproducida (ruta del archivo)
- Último directorio reproducido (si corresponde)
- Marcadores de ámbito de seguridad para restauración

**Flujo de restauración** (PlaylistManager.swift):
1. Intento de restaurar desde marcador de directorio (si se cargó previamente un directorio)
2. Recurso a marcador de archivo individual si falla la restauración del directorio
3. Restaurar posición de reproducción dentro de la lista de reproducción
4. Mantener estado y orden aleatorio

### 7. Modo aleatorio

**Funcionalidad**:
- Orden de reproducción aleatorio
- Habilitado por defecto al cargar un directorio
- Mantiene orden aleatorio consistente durante la sesión de reproducción

**Implementación** (PlaylistManager.swift):
```swift
var shuffledIndices: [Int]              // Índices de pistas pre-mezclados
var currentShufflePosition: Int         // Posición actual en aleatorio
```

### 8. Interfaz de usuario

**Diseño** (ContentView.swift):
- ZStack con fondo de carátula de álbum difuminado
- Visualización de información de pista con título desplazable
- Visualización de tiempo (transcurrido y restante)
- Control deslizante de progreso para buscar
- Botones de control
- Información de lista de reproducción (recuento de pistas, ruta del directorio)

**Elementos dinámicos**:
- Vista ScrollingText para títulos de canciones largos
- Fondo de carátula de álbum con efecto de desenfoque
- Estado deshabilitado para controles cuando no hay lista de reproducción cargada

### 9. Integración con la barra de menú

**Características** (MenuBarManager.swift):
- Icono de nota musical en la barra de menú de macOS
- Muestra que la aplicación está en ejecución incluso cuando la ventana está minimizada

### 10. Notificaciones del sistema

**Requisito de plataforma**: macOS 15 (Sequoia) y posterior

**Funcionalidad**:
- Muestra notificación cuando cambia la canción
- Muestra título y artista de la pista
- Notificaciones silenciosas (sin sonido)
- Aparece incluso cuando la aplicación está en primer plano

**Implementación** (MenuBarManager.swift):
- Usa el framework UserNotifications
- Solicita permisos de notificación al inicio
- Identificador único para cada notificación para evitar agrupación
- El delegado de notificaciones asegura la visualización en primer plano

**Nota de compatibilidad**:
- Notificaciones deshabilitadas en macOS 14 y versiones anteriores debido a problemas de compatibilidad
- El icono de la barra de menú sigue funcionando en todas las versiones de macOS compatibles

### 11. Localización

**Idiomas compatibles**: Inglés y español

**Implementación**:
- NSLocalizedString para todo el texto visible para el usuario
- Directorios .lproj separados para cada idioma
- Cadenas localizables para elementos de UI, elementos de menú y tooltips

### 12. Gestión de ventanas

**Configuración** (Mp3PlayerApp.swift):
- Tamaño de ventana fijo: 500x350 píxeles
- Redimensionamiento basado en contenido (macOS 13+)
- Arquitectura de grupo de ventanas para soporte de múltiples ventanas

### 13. Arquitectura del sistema de notificaciones

**Comunicación central**:
- Usa NotificationCenter para comunicación desacoplada de componentes
- Nombres de notificación personalizados definidos como extensiones de Notification.Name

**Notificaciones clave**:
- `.openFile`, `.openDirectory`: Comandos de apertura de archivo/directorio
- `.playPrevious`, `.playNext`: Navegación de pistas
- `.playTogglePlayPause`, `.playStop`: Control de reproducción
- `.playToggleShuffle`: Alternar modo aleatorio
- `.trackFinished`: Siguiente pista automática cuando se completa la reproducción
- `.trackChanged`: Evento de cambio de pista para notificaciones de barra de menú

## Consideraciones técnicas

### Prevención de limitación de tasa

**Problema**: Cargar metadatos para muchos archivos simultáneamente causa inundación de mensajes del sistema

**Solución**:
- Carga diferida de metadatos al abrir directorios
- Metadatos cargados solo cuando la pista comienza a reproducirse
- Procesamiento secuencial en lugar de carga por lotes en paralelo

### Gestión de memoria

**Limpieza adecuada de recursos**:
- Los deinicializadores detienen el acceso a recursos de ámbito de seguridad
- Invalidación de temporizador en AudioPlayerManager
- Patrón de delegado adecuado de AVAudioPlayer

### Concurrencia

**Patrones modernos**:
- Swift async/await para carga de metadatos
- DispatchQueue para preparación en segundo plano
- Actualizaciones @MainActor para cambios de estado de UI
- Semáforos para sincronización controlada

### Gestión de estado de SwiftUI

**Arquitectura**:
- `@StateObject` para ciclo de vida de objeto vinculado a la vista
- Clases `@ObservableObject` con propiedades `@Published`
- `@EnvironmentObject` para inyección de dependencias
- Flujo de datos unidireccional

## Compilación y ejecución

**Requisitos**:
- macOS 13.0 o posterior
- Xcode 15.0 o posterior
- Swift 5

**Proceso de compilación**:
1. Abrir `Mp3Player.xcodeproj` en Xcode
2. Seleccionar arquitectura de destino (Apple Silicon o Intel)
3. Compilar y ejecutar

## Problemas conocidos y limitaciones

1. **Compatibilidad de notificaciones**: Las notificaciones de cambio de canción solo funcionan en macOS 15+
2. **Limitación de tasa**: Corregido mediante carga perezosa de metadatos, pero mencionado en Console-messages.md como un problema anterior
3. **Gatekeeper**: Firmado ad-hoc, no notarizado, requiere aprobación de seguridad manual

## Mejoras futuras

Áreas potenciales de mejora:
- Soporte de formato extendido (FLAC, AAC, etc.)
- Funcionalidad de guardar/cargar lista de reproducción
- Controles de ecualizador
- Opciones de modo de repetición
- Control de volumen
- Personalización de modo oscuro/claro
- Soporte de tema personalizado
