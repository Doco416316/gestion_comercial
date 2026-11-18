# Gestión Comercial

Aplicación de gestión comercial desarrollada con Flutter y Dart, con persistencia local mediante SQLite y Drift. El proyecto está preparado para Android y Windows y utiliza Riverpod para el estado y GoRouter para la navegación.

> Estado del proyecto: base de datos y repositorios de varias áreas implementados; interfaz de clientes, proveedores y productos disponible en esta entrega local. Inventario dispone ahora de consulta de existencias y registro/historial de movimientos; compras y configuración todavía requieren completar sus flujos de interfaz. No se debe considerar el producto listo para producción hasta ejecutar las validaciones y completar los módulos pendientes.

## Requisitos

- Flutter SDK compatible con Dart `^3.13.7`.
- Android SDK para compilar Android.
- Windows 10/11 con Visual Studio y el workload de desarrollo para escritorio con C++ para compilar Windows.

## Preparación

```bash
flutter pub get
```

## Ejecutar

```bash
flutter run
```

Para ejecutar en un dispositivo o plataforma concreta, consulta primero los destinos disponibles:

```bash
flutter devices
```

## Validación

Ejecuta estos comandos desde la raíz del proyecto:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

La integración continua de GitHub Actions ejecuta instalación de dependencias, formato, análisis estático y pruebas automatizadas.

## Arquitectura actual

- `lib/app/`: configuración de Material, tema, rutas y navegación adaptable.
- `lib/core/database/`: esquema SQLite, migraciones, índices y triggers de integridad mediante Drift.
- `lib/core/providers/`: proveedores compartidos de infraestructura.
- `lib/features/`: módulos de negocio separados por área.
- `test/`: pruebas unitarias de repositorios y lógica, migraciones y pruebas de widgets.

### Módulos existentes

| Área | Persistencia / lógica | Interfaz |
|---|---|---|
| Clientes | Repositorio, validaciones y consultas | Listado y formulario CRUD |
| Proveedores | Repositorio y consultas | Listado y formulario CRUD |
| Productos | Repositorio, SKU y precios por moneda | Catálogo y formulario CRUD básico |
| Inventario | Movimientos, saldos, correcciones y protecciones SQLite | Existencias, movimientos, historial y corrección compensatoria |
| Compras | Borradores, cálculos, confirmación, recepciones y pagos | Pendiente |
| Monedas y tasas | Monedas, moneda base e historial de tasas | Pendiente |

La base de datos declara la versión de esquema `12`. Las migraciones deben conservarse y ampliarse de forma incremental; no se debe recrear la base de datos de usuarios para incorporar cambios de esquema.

## Alcance aún pendiente

La presencia de tablas o repositorios no implica que un proceso esté disponible para el usuario final. Aún debe implementarse o verificarse la experiencia completa de punto de venta, ventas y devoluciones, caja, pedidos/reservas, producción/recetas, informes, notificaciones, copias de seguridad y restauración, exportaciones, servidor local y sincronización entre dispositivos.

Consulta [`docs/auditoria_fase1.md`](docs/auditoria_fase1.md) para el estado auditado y la secuencia de trabajo propuesta, y [`docs/fase2_inventario.md`](docs/fase2_inventario.md) para el alcance de inventario.
