# Guía de mensajes de consola de Xcode

Este documento explica los diversos mensajes de consola que puedes ver cuando ejecutas Mp3Player y si requieren atención.

## Mensajes del sistema inofensivos (se pueden ignorar)

Estos mensajes provienen de frameworks del sistema macOS y son comportamiento normal. No afectan la funcionalidad de la aplicación y se pueden ignorar con seguridad:

### 1. Mensaje de SQLite al inicio
```
cannot open file at line 51040 of [f0ca7bba1c]
os_unix.c:51040: (2) open(/private/var/db/DetachedSignatures) - No such file or directory
```
**Causa:** Operación interna de SQLite intentando acceder a una base de datos del sistema que puede no existir.  
**Impacto:** Ninguno. Este es un mensaje del sistema benigno.  
**Acción:** Se puede ignorar.

### 2. Mensajes de complementos de Core Audio
```
AddInstanceForFactory: No factory registered for id <CFUUID 0x6000004d9740> F8BB1C28-BAE8-11D6-9C31-00039315CD46
HALC_ShellDriverPlugIn.cpp:107    HALC_ShellDriverPlugIn::Open: opening the plug-in failed, Error: 2003329396 (what)
```
**Causa:** Framework de Core Audio intentando cargar complementos de audio opcionales.  
**Impacto:** Ninguno. La aplicación usa reproducción de audio estándar que funciona bien.  
**Acción:** Se puede ignorar.

### 3. Compilación de shaders de Metal
```
flock failed to lock list file (/var/folders/.../com.apple.metal/.../libraries.list): errno = 35
flock failed to lock list file (/var/folders/.../com.apple.metal/.../functions.list): errno = 35
```
**Causa:** Framework de Metal compilando shaders de GPU con acceso concurrente.  
**Impacto:** Ninguno. Esto es normal para operaciones gráficas.  
**Acción:** Se puede ignorar.

### 4. Mensajes del sistema de audio
```
LoudnessManager.mm:1261  GetHardwarePlatformKey: cannot get acoustic ID
```
**Causa:** Sistema de audio de macOS intentando obtener configuraciones de audio específicas del hardware.  
**Impacto:** Ninguno. La reproducción de audio estándar funciona sin esto.  
**Acción:** Se puede ignorar.

### 5. Registro del sistema
```
Reporter disconnected. { function=sendMessage, reporterID=13898514169857 }
```
**Causa:** Desconexión de infraestructura de registro a nivel del sistema.  
**Impacto:** Ninguno. Comportamiento normal del sistema.  
**Acción:** Se puede ignorar.

## Mensajes a corregir

### Mensaje de limitación de tasa
```
Message send exceeds rate-limit threshold and will be dropped. { reporterID=0, rateLimit=32hz }
```
**Causa:** Carga de metadatos de demasiados archivos MP3 simultáneamente al abrir un directorio.  
**Impacto:** Mensajes excesivos del sistema y posible degradación del rendimiento.  
**Solución:** Los metadatos deben cargarse de forma perezosa/asíncrona para evitar saturar el sistema.
