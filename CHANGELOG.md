# Changelog

Todas las notas de versiones del paquete `tomza_kit`.

## [0.2.0] - 2025-01-XX
### Agregado
- **UI Components**: Nuevo `CustomDatePicker` widget con calendario visual, restricciones de fecha, formato español y responsive design.
- **Utils/Validators**: Expansión de `AppValidator` con validaciones avanzadas para contraseñas, fechas (dd/mm/yyyy y mm/dd/yyyy), tiempo (HH:mm), email, teléfono Guatemala y campos requeridos.
- **Features/Media**: Utilidades base64 para codificar/decodificar imágenes (encode/decode con manejo de archivos).
- **Core/Network**: Modelo de dominio `Failure` con `Equatable` y `FailureMapper` para manejo consistente de errores.
- **Tests**: Cobertura completa para nuevos componentes (failures, image_utils, validators, custom_date_picker).

### Mejorado
- **README**: Documentación ampliada con ejemplos de uso del `CustomDatePicker` y módulos actualizados.
- **Network**: Mejor manejo de errores con mapeo a tipos específicos de failure (ServerFailure, AuthFailure, etc.).
- **Validators**: Soporte para múltiples formatos de fecha y validaciones más robustas.

## [0.1.0] - 2025-09-11
### Inicial
- Estructura base de librería (sin carpetas de plataforma).
- Barrel `tomza_kit.dart` con exportaciones de módulos.
- Núcleo: auth (in-memory), network (Dio wrapper + EnvConfig), storage (in-memory), location utils.
- Features: media (stubs), reports (KPIs básicos), notifications (stubs), printing (stubs + widgets), impresión Bixolon placeholder.
- UI: botones, card, dialog, colores y tipografía.
- Utils: constants, validators, formatters (intl).
- Ejemplo mínimo (`example/`).
- Pruebas iniciales (auth, printing, network build).
- README detallado (uso, versionado, roadmap).

---
Formato inspirado en Keep a Changelog.
