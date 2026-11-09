# Base de datos y reglas de negocio

Este documento resume reglas verificadas en los repositorios, servicios y pruebas auditados. Para cualquier cambio, confirma la implementación actual y consulta al responsable si hay ambigüedad.

## 1. Persistencia y protección

- Persistencia con Drift/SQLite.
- `AppDatabase.schemaVersion` auditado: 11.
- Tablas declaradas: 12 (ver `SYSTEM_OVERVIEW.md`).
- Hay índices y triggers para proteger inventario, historia financiera y ciclo de vida de compras.
- El archivo `app_database.g.dart` es generado: nunca editarlo manualmente.
- No cambiar migraciones, triggers o esquema como parte de una tarea frontend.

La auditoría encontró pruebas de migración 3→6, 4→6, 5→6, 7→11 y 9→11. Comprueba el test actual para conocer la cobertura vigente.

## 2. Monedas y tasas

### Monedas
- El código de moneda se normaliza a mayúsculas.
- El código debe tener tres letras.
- La moneda base no puede desactivarse.
- La moneda base no puede cambiarse una vez que existe historia de tasas, compras o pagos.
- La moneda base usa tasa 1; no se registra una tasa histórica para ella.
- Cada moneda tiene `decimalDigits`; no asumir que todas tienen dos decimales.

### Tasas de cambio
- Las tasas deben ser positivas.
- Solo se registran para monedas existentes y activas.
- No se edita la historia: una tasa nueva se registra como nuevo dato con fecha efectiva.
- La tasa aplicable es la más reciente cuya `effectiveAt` sea menor o igual a la fecha consultada.
- `getRateToBaseForDate` puede devolver `null` si no existe tasa aplicable.
- La UI debe permitir seleccionar moneda y fecha, mostrar la tasa aplicable y comunicar la ausencia de tasa.
- No recalcular documentos históricos con tasas actuales.

### Importes
- Los importes monetarios se almacenan como enteros en unidades menores (`amountMinorUnits` u otros campos de minor units).
- La conversión y el cálculo deben respetar `decimalDigits`.
- No usar `double` para dinero.
- No asumir dos decimales: mostrar/formatear de acuerdo con la moneda seleccionada.

## 3. Productos y precios

`ProductRepository`:
- SKU obligatorio, normalizado con `trim()` y mayúsculas.
- Nombre y unidad obligatorios.
- SKU duplicado rechazado.
- Descripción y categoría opcionales; vacíos se normalizan a `null`.
- `trackInventory` determina si el producto controla existencias.
- Un producto puede tener un precio por moneda en `ProductPrices`.
- `setPrice` rechaza importes negativos; precio cero está permitido por la validación observada.
- La moneda del precio debe existir y estar activa.
- Desactivar un producto conserva su información.

**Pendiente:** `updateProduct` permite modificar `trackInventory`. Antes de habilitar el cambio en UI para productos con movimientos o saldo, revisar consecuencias y definir regla explícita. No inventar una política ni modificar el repositorio desde frontend.

## 4. Proveedores

`SupplierRepository`:
- Nombre obligatorio, máximo 150 caracteres.
- Tax ID, teléfono, email, dirección y notas son opcionales.
- Campos opcionales vacíos se normalizan a `null`.
- Listados y búsquedas excluyen inactivos por defecto.
- Se pueden incluir inactivos explícitamente.
- La búsqueda se realiza por nombre o identificación fiscal.
- Desactivar conserva información; se permite reactivar.
- No se observó validación de formato de email en el repositorio auditado. No afirmar que existe.

## 5. Cantidades de inventario

- Las cantidades se representan en milésimas de unidad: `quantityMilliUnits`.
- 1000 unidades internas equivalen a 1 unidad mostrada (si la unidad del producto es `unidad`; adapta el texto a la unidad real).
- No usar `double` para cantidades.
- `InventoryBalances` es el saldo mantenido por triggers; no actualizarlo directamente.
- `InventoryMovements` es un historial inmutable.
- No borrar ni editar movimientos para corregir errores.

### Tipos de movimiento
- `entry`
- `exit`
- `positive_adjustment`
- `negative_adjustment`
- `customer_return`
- `supplier_return`

Aumentan stock: `entry`, `positive_adjustment`, `customer_return`. Los demás reducen stock.

### Validaciones
- Producto debe existir, estar activo y controlar inventario.
- Cantidad mayor que cero.
- Motivo obligatorio.
- Los movimientos que reducen stock requieren saldo suficiente.
- La operación se ejecuta en transacción.
- SQLite/triggers protegen la inmutabilidad, la corrección única y la cadena de correcciones.
- La corrección crea un movimiento inverso enlazado a `correctionOfId`.
- No se puede corregir un movimiento compensatorio ni corregir dos veces el original.
- Las salidas simultáneas no deben provocar saldo negativo.

### Interfaz
- Mostrar saldo observado mediante `watchStock` cuando corresponda.
- Consultar historial mediante `getMovementHistory`.
- Registrar y corregir mediante `InventoryRepository`.
- Nunca escribir directamente en `InventoryBalances` o `InventoryMovements`.

## 6. Compras y cálculo

### Estados
Los estados observados son:
- `draft`
- `confirmed`
- `cancelled`

Las compras se crean como borradores. Los detalles y cabecera se modifican mientras están en borrador. La confirmación requiere detalles y validaciones de proveedor, moneda y productos. Una compra confirmada/cancelada está protegida por reglas de ciclo de vida.

La confirmación de compra **no significa que los productos hayan entrado físicamente al inventario**. La entrada ocurre al registrar una recepción, si el producto controla inventario.

### Cálculos
`PurchaseCalculationService` es la fuente de verdad para los cálculos de líneas y compras. No reimplementar sus fórmulas en UI, providers ni controladores.

- `quantityMilliUnits`: cantidad en milésimas.
- `unitCostMinorUnits`: coste unitario en unidades menores.
- Ajustes: `fixed` o `percentage`.
- Un porcentaje se expresa como número porcentual: `5` significa 5%, no `0.05`.
- El descuento porcentual no puede superar 100%.
- El descuento no puede superar el importe bruto.
- La base imponible es bruto menos descuento.
- El impuesto se calcula sobre la base imponible.
- Los importes calculados usan aritmética decimal exacta y redondeo HALF_UP.
- Se comprueban límites de entero SQLite.
- No usar `double`.

La UI puede recoger si el ajuste es fijo o porcentual y mostrar una previsualización obtenida del servicio. No debe mantener un segundo motor de cálculo.

### Recepciones
`PurchaseReceiptRepository`:
- Solo admite compras confirmadas.
- Cada recepción debe tener al menos una línea.
- Identificadores de detalle no vacíos y no repetidos en una misma recepción.
- Cantidades positivas.
- El detalle debe pertenecer a la compra.
- No se puede recibir más de la cantidad comprada, descontando recepciones previas.
- Permite recepciones parciales y múltiples recepciones hasta completar.
- Para productos activos con `trackInventory == true`, crea un movimiento `entry`.
- Para productos que no controlan inventario, registra la recepción sin movimiento.
- Las operaciones se realizan en una transacción.
- Cabecera/detalles y movimientos quedan protegidos por reglas de inmutabilidad.

La pantalla debe distinguir cantidad comprada, recibida y pendiente. No incrementar stock directamente.

## 7. Pagos a proveedores

`SupplierPaymentRepository`:
- Solo permite pagar compras confirmadas.
- El importe debe ser positivo.
- La moneda de pago debe existir y estar activa.
- La moneda de compra debe existir.
- La tasa snapshot de compra debe ser positiva.
- Obtiene la tasa de pago aplicable a la fecha del pago.
- Admite pagar en moneda distinta de la compra.
- Convierte a la moneda de compra considerando `decimalDigits`.
- Usa aritmética Decimal/Rational y redondeo HALF_UP, sin `double`.
- Rechaza el sobrepago.
- Conserva snapshot de tasa para que las tasas futuras no alteren la historia.
- Los pagos registrados son historia financiera; no editarlos o borrarlos desde UI.

La interfaz debe mostrar moneda del documento, moneda del pago, tasa aplicable/snapshot, importe pagado y saldo pendiente sin recalcular por su cuenta.

## 8. Límites y errores

- No ocultar `ArgumentError`/`StateError` del dominio.
- Traducirlos a mensajes entendibles en UI sin cambiar el resultado del negocio.
- Las validaciones visuales mejoran la experiencia, pero el repositorio es autoridad.
- No permitir que una pantalla aparente éxito si la operación transaccional falló.
- No usar valores de ejemplo o mocks como si fueran datos persistidos en producción.

## 9. Preguntas pendientes que requieren decisión humana

1. Política para cambiar `trackInventory` cuando ya existen movimientos o saldo.
2. Reglas de validación/formato para correo, teléfono e identificación fiscal, si se desean.
3. Reglas visuales y flujos exactos para pantallas no especificadas.
4. Si y cómo se expondrán ajustes de compra, cancelaciones y otros procesos sensibles a usuarios con distintos permisos.

No resuelvas estas preguntas por inferencia.
