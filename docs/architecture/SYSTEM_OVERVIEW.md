# Visión general del sistema

## 1. Propósito

`gestion_comercial` es una aplicación genérica de gestión comercial. No debe acoplarse a un sector particular. El diseño debe permitir gestionar diferentes negocios manteniendo consistencia de datos, trazabilidad y cálculos fiables.

Plataformas objetivo: Android y Windows. La arquitectura debe priorizar la integridad de los datos y la exactitud de operaciones comerciales y financieras.

## 2. Estado auditado

Referencia de auditoría: rama `feature/frontend`, commit `9791a0b`.

- Flutter 3.47.9 / Dart 3.13.7.
- Persistencia local con Drift/SQLite.
- `schemaVersion`: 11.
- Tablas declaradas: 12.
- Navegación: GoRouter, actualmente solo ruta `/`.
- UI: `GestionComercialApp`, `HomePage` provisional y tema Material 3.
- Riverpod está en `pubspec.yaml`; no se encontraron providers ni `ProviderScope` en el código auditado.
- La implementación frontend funcional todavía está pendiente.

## 3. Dependencias principales

Versiones resueltas observadas en `pubspec.lock` durante la auditoría:

| Paquete | Versión |
|---|---:|
| Flutter SDK | 3.47.9 |
| Dart SDK | 3.13.7 |
| flutter_riverpod | 3.4.3 |
| go_router | 18.1.2 |
| drift | 2.35.3 |
| drift_flutter | 0.3.1 |
| drift_dev | 2.35.2 |
| decimal | 3.2.6 |
| intl | 0.20.3 |
| path_provider | 2.1.6 |
| uuid | 4.6.0 |

No actualices versiones por iniciativa propia. Comprueba `pubspec.yaml` y `pubspec.lock` antes de usar esta tabla como estado actual.

## 4. Estructura observada de `lib/`

```text
lib/
  main.dart
  app/
    app.dart
    theme/
      app_theme.dart
  core/
    database/
      app_database.dart
      app_database.g.dart
  features/
    inventory/data/inventory_repository.dart
    products/data/product_repository.dart
    purchases/
      data/
        purchase_receipt_repository.dart
        purchase_repository.dart
        supplier_payment_repository.dart
      domain/
        purchase_calculation_service.dart
        purchase_repository.dart
    settings/data/
      currency_repository.dart
      exchange_rate_repository.dart
    suppliers/data/supplier_repository.dart
```

La estructura observada ya separa funcionalidades por `features/` y contiene repositorios en `data/` y servicios/reglas de compra en `domain/`. No asumas que todos los módulos tienen la misma organización ni crees capas vacías sin una necesidad concreta.

## 5. Entrada y aplicación

- `main.dart` inicializa Flutter y ejecuta `GestionComercialApp`.
- `app.dart` construye `MaterialApp.router`.
- GoRouter tiene `initialLocation: '/'` y una única ruta `/`.
- `HomePage` es provisional.
- El router se instancia dentro de `build`; no lo cambies como refactor incidental. Si se decide reorganizar navegación, hacerlo como tarea delimitada.

## 6. Tema visual existente

`AppTheme.light` usa Material 3. La auditoría observó:
- Color semilla azul `#2563EB`.
- Fondo `#F5F7FA`.
- AppBar y tarjetas blancas.
- Tarjetas con radio aproximado de 14.
- Bordes sutiles `#E8ECF2`.

El frontend debe partir del tema existente y proponer cambios globales de forma coherente, no introducir estilos aislados en cada pantalla.

## 7. Módulos de negocio existentes

| Módulo | Capacidades implementadas en backend |
|---|---|
| Productos | Alta, edición, activación, SKU y precios por moneda |
| Inventario | Saldos, streams, movimientos, correcciones e historial |
| Proveedores | Alta, edición, búsqueda y activación |
| Monedas | Alta, activación y selección de moneda base |
| Tasas de cambio | Registro de tasas históricas y consulta por fecha |
| Compras | Borradores, detalles, cálculo, confirmación y cancelación |
| Recepciones | Recepciones parciales/completas, historial y movimientos de inventario |
| Pagos a proveedores | Pagos en moneda propia o distinta y saldo pendiente |

Que exista backend no significa que exista una pantalla terminada.

## 8. Tablas declaradas en AppDatabase

La auditoría identificó estas 12 tablas:

1. `Currencies`
2. `Products`
3. `ProductPrices`
4. `InventoryMovements`
5. `InventoryBalances`
6. `Suppliers`
7. `ExchangeRates`
8. `Purchases`
9. `PurchaseDetails`
10. `PurchaseReceipts`
11. `PurchaseReceiptDetails`
12. `SupplierPayments`

Para campos, relaciones, índices y restricciones, consulta directamente `app_database.dart` y las migraciones. No infieras columnas a partir de los nombres.

## 9. Pruebas observadas

```text
test/
  widget_test.dart
  core/database/app_database_migration_test.dart
  features/
    inventory/inventory_repository_test.dart
    products/product_repository_test.dart
    purchases/
      purchase_calculation_service_test.dart
      purchase_receipt_repository_test.dart
      purchase_repository_test.dart
      supplier_payment_repository_test.dart
    settings/
      currency_repository_test.dart
      exchange_rate_repository_test.dart
    suppliers/supplier_repository_test.dart
```

En el momento de la auditoría se habían comunicado 186 pruebas exitosas y CI verde. Repite los comandos en la rama actual antes de afirmar que el estado sigue vigente.

## 10. Incidencias y pendientes conocidos

- El frontend real está por construir.
- Riverpod está declarado, pero no configurado en el código auditado.
- GoRouter tiene solo `/`.
- Hay dos `purchase_repository.dart`; el de `data` es el que se encontró importado desde `lib` y `test`. No eliminar el de `domain` sin análisis separado.
- Hay comentarios antiguos en el repositorio de compras que no reflejan la existencia actual de repositorios de recepciones y pagos.
- Revisar el cambio de `trackInventory` en productos que ya tienen movimientos/saldo antes de exponer esa operación en UI.
