## tomza_kit

Librería interna modular para proyectos Flutter de TOMZA. Centraliza lógica transversal (auth, red, almacenamiento, ubicación, media, reportes, notificaciones, impresión, UI y utilidades) para reutilizar y reducir duplicación entre apps.

---
### Repositorio

GitHub (público/privado según configuración):
```
HTTPS: https://github.com/GrullonDev/tomza_kit.git
SSH:   git@github.com:GrullonDev/tomza_kit.git
```

Clonar (HTTPS):
```
git clone https://github.com/GrullonDev/tomza_kit.git
```

Clonar (SSH):
```
git clone git@github.com:GrullonDev/tomza_kit.git
```

Agregar como remoto adicional:
```
git remote add tomza-kit https://github.com/GrullonDev/tomza_kit.git
```

---
### 1. Estructura del paquete

```
lib/
	tomza_kit.dart            # Barrel: exportaciones públicas
	core/                     # Núcleo (auth, network, storage, location)
	features/                 # Funcionalidades (media, reports, notifications, printing)
	ui/                       # Widgets y temas compartidos
	utils/                    # Constantes, validadores, formateadores
example/                    # App ejemplo mínima
test/                       # Pruebas unitarias
```

No contiene carpetas de plataforma (android/ ios/ web/ etc.) porque se distribuye como librería pura dentro del monorepo/organización.

---
### 2. Cómo agregarlo a un proyecto Flutter

#### Opción A: Dependencia por ruta local (desarrollo)
```yaml
dependencies:
	tomza_kit:
		path: ../libs/tomza_kit   # Ajustar a tu estructura real
```

#### Opción B: Dependencia via Git (repositorio GitHub)
```yaml
dependencies:
	tomza_kit:
		git:
			url: git@github.com:GrullonDev/tomza_kit.git
			ref: main        # O un tag versión como v0.1.0
```

#### Opción C: Tag fijo para builds reproducibles
```yaml
dependencies:
	tomza_kit:
		git:
			url: git@github.com:GrullonDev/tomza_kit.git
			ref: v0.1.0
```

Luego ejecutar:
```
flutter pub get
```

Importación general:
```dart
import 'package:tomza_kit/tomza_kit.dart';
```

---
### 3. Inicialización básica (network + auth)

En `main.dart` de la app consumidora:
```dart
void main() {
	EnvConfig.initialize(
		baseUrl: 'https://api.midominio.com',
		isDevelopment: !kReleaseMode,
		insecureSsl: false, // true solo para entornos locales si hay cert self-signed
		defaultHeaders: {'X-App': 'supervisores'},
	);
	runApp(const MyApp());
}
```

Llamadas HTTP:
```dart
final resp = await ApiClient.get<Map<String, dynamic>>('/usuarios');
final data = resp.data;
```

Auth temporal (stub):
```dart
final auth = InMemoryAuthService();
final ok = await auth.signIn(username: 'demo', password: '1234');
if (ok) {
	// Guardar token en SessionManager (ejemplo):
	SessionManager().saveToken('token-demo');
}
```

Impresión (simulada):
```dart
final pm = PrintManager();
await pm.printItems([
	PrintText('Ticket ejemplo'),
	PrintQr('QR-DATA'),
]);
```

---
### 4. Módulos incluidos

| Módulo | Descripción | Siguientes pasos recomendados |
|--------|-------------|--------------------------------|
| core/auth | Sesión y login en memoria | Sustituir por backend real + token refresh |
| core/network | Cliente Dio centralizado | Agregar interceptor de token + retry + logging configurable |
| core/storage | Preferencias y secure storage en memoria | Integrar shared_preferences / flutter_secure_storage |
| core/location | GPS y utilidades | Integrar geolocator / geocoding |
| features/media | Cámara e imágenes (stubs) | Integrar camera / image_picker / compresión |
| features/reports | KPIs y reportes simples | Extender con motores de agregación reales |
| features/notifications | Push / locales (stubs) | Integrar firebase_messaging y flutter_local_notifications |
| features/printing | Impresión Bixolon (stubs) | Canal nativo + manejo de colas / reconexión |
| ui | Widgets reutilizables | Añadir catálogo + theming avanzado |
| utils | Constantes, validadores, formateadores | Extender utilidades de fechas, números, masks |

---
### 5. Versionado y políticas de actualización

Se usa versionado semántico (SemVer): `MAJOR.MINOR.PATCH`.

- Incrementar `PATCH` para correcciones internas sin romper APIs (0.1.1 → 0.1.2).
- Incrementar `MINOR` para nuevas funcionalidades backward-compatible (0.1.0 → 0.2.0 si todavía no hay estabilidad completa, o 0.1.0 → 0.1.1 si es pequeño).
- Incrementar `MAJOR` (o mientras esté en 0.x, documentar claramente) al introducir breaking changes (renombres, firmas cambiadas, eliminación de APIs públicas).

Recomendación mientras esté en estado preliminar (<1.0.0):
> Documentar cualquier cambio incompatible en un archivo `CHANGELOG.md` y mantener PRs pequeños.

#### Flujo sugerido de actualización en proyectos consumidores
1. Crear rama: `chore/update-tomza-kit`.
2. Actualizar referencia (tag/commit) en `pubspec.yaml`.
3. Ejecutar: `flutter pub get && flutter analyze && flutter test`.
4. Validar manualmente funcionalidades críticas (auth, impresión si aplica).
5. Merge cuando todo esté verde.

---
### 6. Actualizar la librería a nuevas versiones de Flutter

Cuando aparezca una nueva versión estable de Flutter:
1. Actualizar localmente SDK (ej: `flutter upgrade`).
2. Ejecutar en este paquete:
	 ```
	 flutter clean
	 flutter pub get
	 flutter analyze
	 flutter test
	 ```
3. Ajustar `environment.sdk` en `pubspec.yaml` si corresponde (ej: subir rango mínimo).
4. Actualizar dependencias que muestren advertencias con: `flutter pub upgrade --major-versions` (revisar cambios breaking primero).
5. Si hubo cambios de APIs en dependencias (por ejemplo Dio), adaptar wrappers aquí.
6. Ejecutar CI (si existe) y publicar tag nuevo: `git tag v0.2.0 && git push origin v0.2.0`.
7. Actualizar proyectos consumidores a ese tag.

Checklist rápida interna antes de crear un tag:
- [ ] Tests verdes
- [ ] Lint sin errores críticos
- [ ] `CHANGELOG.md` actualizado
- [ ] README refleja nuevas APIs

---
### 7. Buenas prácticas de contribución
1. Evitar exponer símbolos innecesarios: exportar solo lo que sea parte del contrato público.
2. Escribir pruebas mínimas para cada nueva funcionalidad.
3. Documentar decisiones técnicas en el PR (breve). 
4. Mantener funciones puras donde sea posible y reducir side-effects.
5. Evitar dependencias pesadas si un utilitario simple basta.

---
### 8. Roadmap (resumen)
- Interceptor de token + refresh automático
- Logging configurable (callback) en lugar de prints
- Integración real de storage seguro
- Canal nativo impresión Bixolon + manejo de reconexión
- Ejemplos adicionales por módulo (`example/`)
- Añadir `CHANGELOG.md`

---
### 9. FAQ
**¿Por qué no incluye carpetas de plataforma?**  Porque se distribuye como librería, y las apps consumidoras ya tienen su propio scaffold.

**¿Puedo sobreescribir headers por request?** Sí, usando parámetros `Options` de Dio directamente (extender wrapper más adelante si se requiere).

**¿Cómo inyecto un token dinámico?** Próxima iteración: agregar un interceptor configurable que lea de `SessionManager`.

---
### 10. Licencia / Uso
Uso interno corporativo. No publicar en pub.dev.

---
### 11. Ejemplo completo rápido
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tomza_kit/tomza_kit.dart';

void main() {
	EnvConfig.initialize(
		baseUrl: 'https://api.midominio.com',
		isDevelopment: !kReleaseMode,
		insecureSsl: false,
	);
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});
	@override
	Widget build(BuildContext context) => MaterialApp(
				home: Scaffold(
					appBar: AppBar(title: const Text('Demo tomza_kit')),
					body: Center(
						child: TomzaButton(
							label: 'Ping',
							onPressed: () async {
								try {
									final r = await ApiClient.get<String>('/status');
									debugPrint('OK => ${r.data}');
								} catch (e) {
									debugPrint('ERROR => $e');
								}
							},
						),
					),
				),
			);
}
```

---
### 12. Soporte
Reportar incidencias internas en el repositorio (Issues) con plantilla: contexto, versión del paquete y pasos para reproducir.

