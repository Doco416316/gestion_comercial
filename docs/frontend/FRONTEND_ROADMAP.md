# Hoja de ruta frontend (propuesta)

Este documento es una propuesta de secuencia, no una autorización automática para implementar todos los módulos.

## Fase 0 — Acordar arquitectura frontend
- Confirmar navegación y estructura responsive Android/Windows.
- Decidir configuración de Riverpod y ciclo de vida de `AppDatabase`/repositorios.
- Definir layout general, tema, componentes y tratamiento común de errores.
- Acordar estrategia de rutas y permisos si aplica.

**Criterio de salida:** decisiones registradas y una aplicación base navegable sin cambiar backend.

## Fase 1 — Catálogos base
- Monedas y tasas.
- Productos y precios por moneda.
- Proveedores.

**Criterio de salida:** formularios/listados conectados a repositorios existentes, validaciones y pruebas.

## Fase 2 — Inventario
- Consulta de existencias.
- Historial de movimientos.
- Registro de entradas, salidas y ajustes.
- Correcciones compensatorias según el flujo que se acuerde.

**Criterio de salida:** nunca se manipulan saldos directamente; se muestran cantidades con precisión de milésimas.

## Fase 3 — Compras
- Listado y filtros por estado.
- Crear/editar borrador.
- Líneas, descuentos e impuestos.
- Confirmación y cancelación según reglas vigentes.

**Criterio de salida:** los cálculos provienen de `PurchaseCalculationService`; no hay duplicación de fórmulas.

## Fase 4 — Recepciones
- Cantidades compradas, recibidas y pendientes.
- Recepciones parciales y completas.
- Historial de recepciones.

**Criterio de salida:** el stock solo cambia por movimientos creados por el repositorio de recepciones.

## Fase 5 — Pagos a proveedores
- Pagos en moneda de compra o moneda distinta.
- Tasa aplicable y snapshot.
- Total pagado y saldo pendiente.

**Criterio de salida:** conversión y validación realizadas por el repositorio; no se permiten sobrepagos.

## Fase 6 — Dashboard e informes
Definir previamente fórmulas, moneda de presentación, periodos y fuentes. No inventar KPI ni sumar importes de monedas distintas sin conversión definida.

## Gestión de alcance

Cada fase debe dividirse en tareas pequeñas, con:
- responsable humano;
- archivos autorizados;
- criterios de aceptación;
- pruebas requeridas;
- dependencias;
- definición de terminado.

Un agente IA no debe comenzar una fase completa sin una tarea concreta.
