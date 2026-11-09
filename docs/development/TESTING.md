# Pruebas y validación

## 1. Comandos base

Ejecutar desde la raíz del proyecto, en PowerShell:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
```

Si el formato detecta cambios, primero formatear los archivos modificados y repetir la comprobación:

```powershell
dart format ruta\al\archivo.dart
dart format --output=none --set-exit-if-changed .
```

No afirmar que las pruebas pasan sin ejecutar los comandos y leer el resultado.

## 2. Orden recomendado

1. Prueba dirigida al módulo modificado.
2. `dart format --output=none --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`
5. `git diff --check`
6. Revisar `git status --short` y `git diff --stat`.

## 3. Pruebas frontend

Para cada pantalla/flujo, cubrir cuando aplique:
- render inicial;
- estado de carga;
- estado vacío;
- estado de error;
- entrada válida e inválida;
- interacción principal;
- prevención de doble envío;
- navegación;
- adaptación básica a tamaños/plataformas objetivo.

Los tests widget no sustituyen los tests de repositorio/servicio.

## 4. Reglas financieras y de inventario

Añadir pruebas cuando la interfaz coordine operaciones sensibles:
- no duplicar operaciones al tocar dos veces;
- no mostrar éxito si el repositorio falla;
- respetar moneda y `decimalDigits`;
- cantidades convertidas exactamente a milésimas;
- no sobrepasar cantidades pendientes;
- no permitir que el usuario modifique historia inmutable;
- mostrar correctamente saldo/estado devuelto por los repositorios.

No reimplementar los cálculos en tests de UI como si fueran la fuente de verdad; probar la integración con el servicio/repositorio y mantener pruebas unitarias del dominio.

## 5. CI

El workflow auditado `.github/workflows/flutter-ci.yml` ejecuta:
- formato Dart;
- `flutter analyze`;
- `flutter test`.

Comprueba el archivo actual para confirmar el contenido vigente del workflow.

## 6. Entorno Windows y proxy

El entorno de desarrollo auditado es Windows/PowerShell. En algunas configuraciones con proxy institucional, las pruebas locales pueden requerir:

```powershell
$env:NO_PROXY = "localhost,127.0.0.1,::1"
$env:no_proxy = "localhost,127.0.0.1,::1"
```

No cambiar la configuración global de proxy como parte de una tarea frontend sin autorización.
