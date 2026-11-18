# Fase 2 — Inventario operativo

## Incluido

- Consulta reactiva de existencias de productos activos con control de inventario.
- Búsqueda por SKU, nombre y categoría.
- Registro de entradas, salidas, ajustes positivos/negativos y devoluciones de cliente/proveedor.
- Validación de cantidad positiva con precisión de hasta tres decimales, motivo obligatorio y referencia opcional.
- Historial por producto y consulta de los 100 movimientos más recientes.
- Corrección de movimientos mediante un movimiento compensatorio, conservando la trazabilidad original.
- Reutilización del repositorio y de las transacciones SQLite existentes.

## Decisiones y límites

- No se modificó el esquema ni la versión de base de datos 12.
- Los saldos continúan calculándose y protegiéndose mediante los mecanismos existentes de SQLite.
- No se añadieron alertas de stock mínimo: el esquema actual no define umbrales por producto y no se debe inventar esa regla.
- Las cantidades se muestran con tres decimales porque la persistencia utiliza milésimas de unidad.
- La corrección no elimina ni modifica el movimiento original; registra su compensación.

## Validación pendiente

Ejecutar desde la raíz del proyecto:

```powershell
dart format lib/features/inventory test/features/inventory
flutter analyze
flutter test test/features/inventory/inventory_repository_test.dart --reporter expanded
flutter test test/features/master_data_pages_test.dart --reporter compact
flutter test
```

Esta entrega se preparó sin un SDK Flutter/Dart disponible en el entorno de edición. No se afirma que el análisis ni las pruebas hayan pasado hasta ejecutarlos en el equipo de desarrollo.
