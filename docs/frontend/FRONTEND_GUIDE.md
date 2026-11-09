# Guía de desarrollo frontend

## 1. Situación inicial

La auditoría encontró:
- `GestionComercialApp` como raíz de la aplicación.
- GoRouter con una única ruta `/`.
- `HomePage` provisional.
- Tema Material 3 básico en `AppTheme.light`.
- Riverpod declarado en dependencias, pero sin `ProviderScope` ni providers encontrados.

Por tanto, esta guía define restricciones y dirección de trabajo; no afirma que ya exista una arquitectura frontend completa.

## 2. Objetivos de experiencia

- Aplicación genérica para cualquier negocio.
- Android y Windows.
- Interfaz profesional, minimalista, intuitiva y adaptable.
- Navegación clara entre módulos.
- Formularios con validación y mensajes comprensibles.
- Estados de carga, vacío, error y éxito explícitos.
- Tablas/listas adaptadas al espacio disponible.
- Consistencia visual a través del tema central.

## 3. Separación de responsabilidades

Responsabilidad recomendada:

| Capa | Responsabilidad |
|---|---|
| Widgets/pantallas | Presentación, interacción y validación básica |
| Estado (por definir) | Estado de pantalla, filtros, selección y coordinación |
| Repositorios | Lectura/escritura y reglas transaccionales ya implementadas |
| Servicios de dominio | Cálculos y reglas reutilizables |
| Drift | Persistencia y restricciones |

La pantalla no debe acceder directamente a tablas Drift ni implementar reglas financieras.

## 4. Estado y navegación

- `flutter_riverpod` y `go_router` están disponibles en dependencias.
- Antes de implementar, confirmar si el responsable aprueba introducir `ProviderScope`, providers y una estructura de routing compartida.
- No crear múltiples instancias de repositorios/base de datos por pantalla si el diseño acordado requiere compartirlas.
- Evitar lógica de negocio dentro de `build`.
- No cambiar la arquitectura global por iniciativa individual.

## 5. Formularios

- Mantener valores de entrada claramente tipados.
- Separar valor mostrado y valor almacenado cuando la moneda/unidad lo requiera.
- En formularios monetarios, identificar siempre la moneda.
- Respetar `decimalDigits`.
- Para cantidades de inventario, convertir de forma exacta a `quantityMilliUnits`; no usar `double`.
- Los campos opcionales vacíos pueden convertirse a `null` cuando el repositorio así lo hace.
- Deshabilitar acciones mientras una operación está en curso.
- Mostrar errores de dominio en lenguaje claro.
- No mostrar confirmación hasta que la operación termine correctamente.

## 6. Dinero y cantidades

- No usar `double` en cálculos ni como representación persistente de importes/cantidades.
- Importes: enteros en unidades menores.
- Cantidades de inventario: enteros en milésimas.
- Conversión, cálculo y redondeo: reutilizar servicios/repositorios.
- No asumir que toda moneda tiene dos decimales.
- No formatear el importe sin conocer su moneda.

## 7. Observación de datos

Usar los streams de repositorio cuando la pantalla deba reflejar cambios:
- Productos activos.
- Precios por producto.
- Stock por producto.
- Historial/listados de compras, recepciones y pagos.
- Proveedores y monedas.

Verifica la firma real de cada stream en el repositorio antes de implementarlo.

## 8. Accesibilidad y adaptación

- Controles con etiquetas legibles.
- Áreas táctiles adecuadas en Android.
- Uso eficiente de espacio y teclado/ratón en Windows.
- No depender solo del color para comunicar estados.
- Evitar tablas rígidas que desborden en móvil.
- Mantener contraste y jerarquía tipográfica.
- No fijar anchos absolutos para todo el diseño.

## 9. Secuencia sugerida

La secuencia exacta debe acordarse con el responsable. Una propuesta de dependencias:
1. Esqueleto de navegación, layout y tema.
2. Componentes reutilizables y manejo común de estados/errores.
3. Monedas y tasas de cambio.
4. Productos y precios.
5. Proveedores.
6. Inventario.
7. Compras y detalle.
8. Recepciones.
9. Pagos a proveedores.
10. Dashboard e indicadores cuando las definiciones estén acordadas.

No asumir que este orden ya está aprobado como plan de entrega.
