# Instrucciones para agentes de IA — Gestión Comercial

> Lee este archivo completo antes de inspeccionar o modificar el proyecto. Las instrucciones específicas de `docs/` complementan este documento; si hay conflicto, detente y solicita aclaración al responsable humano.

## 1. Identidad y objetivo del proyecto

`gestion_comercial` es una aplicación genérica de gestión comercial para distintos tipos de negocio. **No está limitada a impresión 3D ni a DEGAr3.** El objetivo es ofrecer una gestión fiable de productos, precios, inventario, proveedores, compras, pagos y, progresivamente, otros procesos comerciales.

Plataformas objetivo desde el inicio: Android y Windows. La prioridad transversal es la integridad de los datos y la exactitud de los cálculos, especialmente los financieros.

## 2. Estado técnico conocido

Este documento se elaboró a partir de la auditoría del repositorio en la rama `feature/frontend`, con referencia al commit `9791a0b` (`style(purchases): format purchase repository`). Comprueba el estado real de la rama antes de asumir que sigue siendo idéntico.

- Flutter estable auditado: 3.47.9; Dart 3.13.7.
- `drift` 2.35.3; `drift_dev` 2.35.2.
- `flutter_riverpod` 3.4.3; `go_router` 18.1.2.
- Base de datos Drift: `schemaVersion == 11`.
- Se identificaron 12 tablas declaradas en `AppDatabase`.
- El frontend todavía es un esqueleto: una ruta `/`, `HomePage` provisional y tema Material 3 básico.
- Riverpod está declarado en dependencias, pero en la auditoría no se encontraron `ProviderScope`, providers ni `ProviderContainer`.
- GitHub Actions ejecuta formato, análisis y pruebas. El último resultado comunicado por el responsable en la auditoría fue exitoso.

Fuentes de verdad: código, pruebas automatizadas, migraciones y decisiones expresas del responsable. Esta documentación es una guía derivada de esa evidencia, no sustituye al código.

## 3. Reglas obligatorias de trabajo

1. Antes de editar, inspecciona el código relacionado, sus llamadas y sus pruebas.
2. Limita cada tarea al alcance asignado. No hagas refactors colaterales.
3. No inventes reglas de negocio, campos, pantallas, estados ni validaciones. Si falta una decisión, registra la pregunta y consulta al responsable.
4. Reutiliza repositorios y servicios existentes. La interfaz no debe acceder directamente a tablas Drift.
5. No dupliques cálculos financieros ni de inventario en widgets, controladores o providers.
6. No conviertas importes o cantidades a `double`.
7. No modifiques datos históricos para hacer que la interfaz resulte más sencilla.
8. Mantén la compatibilidad Android y Windows; no introduzcas APIs exclusivas de una plataforma sin aprobación.
9. Añade o actualiza pruebas adecuadas para cada cambio.
10. No hagas commits, pushes, merges, rebases destructivos ni cambios de rama sin autorización expresa del responsable humano.
11. No declares una validación como exitosa si no ejecutaste el comando y observaste su resultado.
12. No cambies dependencias o versiones sin justificarlo y pedir aprobación.

## 4. Áreas protegidas

Se consideran áreas sensibles y quedan fuera del alcance normal del trabajo frontend:

- `lib/core/database/app_database.dart`
- `lib/core/database/app_database.g.dart` (generado)
- Migraciones, `schemaVersion`, tablas, índices, triggers, restricciones y SQL.
- Repositorios de `data/`.
- Servicios de dominio que calculan importes o afectan saldos.
- Reglas de conversión de moneda y snapshots históricos.
- Registro, corrección y acumulación de movimientos de inventario.
- Ciclo de vida e inmutabilidad de compras, recepciones y pagos.

No edites estas áreas salvo que el responsable asigne explícitamente una tarea backend o de datos. Una necesidad visual no justifica cambiar el modelo de datos.

## 5. Integración frontend/backend

- La UI recoge entradas, muestra datos y comunica acciones.
- Los repositorios validan y persisten.
- Los servicios de dominio realizan cálculos.
- Los streams existentes deben aprovecharse cuando la pantalla necesite observar cambios.
- Presenta los errores de dominio sin ocultarlos ni sustituirlos por resultados ficticios.
- No escribas directamente en tablas Drift desde widgets.
- No actualices directamente `InventoryBalances` ni `InventoryMovements`.
- No marques una compra como recibida por el simple hecho de confirmarla.

Consulta `docs/architecture/DATABASE_AND_BUSINESS_RULES.md` antes de implementar formularios de compras, pagos, precios, monedas o inventario.

## 6. Convenciones frontend

- Sigue Material 3 y el tema existente en `lib/app/theme/app_theme.dart`.
- Diseña interfaces adaptables a pantallas Android y Windows.
- Mantén widgets pequeños y con responsabilidades claras.
- Separa presentación, estado y acceso a datos.
- No introduzcas una arquitectura nueva de estado o navegación sin documentar la decisión y obtener aprobación.
- Riverpod y GoRouter están en dependencias, pero su configuración real debe verificarse antes de asumir providers, scopes o rutas.
- Los formularios deben validar entradas para ayudar al usuario, pero las validaciones del repositorio siguen siendo la autoridad.
- Los importes deben formatearse según la moneda seleccionada y su `decimalDigits`; no asumir que todas las monedas tienen dos decimales.

## 7. Duplicidad conocida que no debe limpiarse incidentalmente

Existen dos archivos con el nombre `purchase_repository.dart`:

- `lib/features/purchases/data/purchase_repository.dart`
- `lib/features/purchases/domain/purchase_repository.dart`

En la auditoría, las referencias desde `lib` y `test` apuntaban al archivo de `data`; no se encontraron referencias al de `domain`. No borres, muevas ni fusiones el archivo aparentemente no utilizado sin una tarea separada y una verificación completa.

También se detectó un comentario en el repositorio de compras que describe recepciones y pagos como trabajo futuro, aunque ya existen repositorios separados. No uses ese comentario desactualizado como especificación.

## 8. Flujo mínimo antes de entregar

Desde la raíz del proyecto, ejecuta:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
git status --short
git diff --stat
```

Si cambiaste código generado por Drift, no edites el `.g.dart` manualmente. Detente y solicita autorización si la tarea requiere cambios de esquema o generación.

En la entrega informa:
- Archivos modificados.
- Comportamiento implementado.
- Pruebas añadidas/actualizadas.
- Comandos ejecutados y resultados reales.
- Riesgos, limitaciones y decisiones pendientes.
- Cualquier desviación del alcance.

## 9. Antes de empezar una tarea

1. Lee este archivo y los documentos pertinentes de `docs/`.
2. Ejecuta `git status --short` y comprueba rama/commit.
3. Inspecciona las implementaciones y pruebas relacionadas.
4. Resume el plan y los archivos que piensas tocar.
5. Si la tarea implica áreas protegidas, reglas no documentadas o cambios de arquitectura, solicita aprobación antes de editar.

## 10. Responsabilidades y colaboración del equipo

El proyecto trabaja con dos responsables principales:

- **Backend:** responsable principal de base de datos, migraciones, repositorios, servicios de dominio, reglas de negocio, cálculos financieros e inventario.
- **Frontend:** responsable principal de interfaces, pantallas, formularios, navegación, estado de presentación y experiencia de usuario.

La propiedad de los archivos se organiza así:

| Ubicación | Responsable principal |
|---|---|
| `lib/core/database/` | Backend |
| `lib/features/*/data/` | Backend |
| `lib/features/*/domain/` | Backend |
| `lib/app/` | Frontend |
| `lib/features/*/presentation/` | Frontend |
| `test/` | Responsable del módulo correspondiente |
| `pubspec.yaml` | Compartido; requiere coordinación |

Estas responsabilidades son obligatorias como criterio de coordinación, pero no impiden consultar o analizar el código de otras áreas.

### Reglas adicionales

1. El agente IA debe identificar quién es responsable del área antes de modificar archivos.
2. No debe modificar archivos cuya responsabilidad principal corresponda al otro programador sin coordinación previa.
3. Si una funcionalidad frontend necesita cambios backend, debe documentar la necesidad y solicitar coordinación.
4. Los cambios compartidos deben tener un responsable de implementación acordado.
5. Los agentes no deben sobrescribir ni descartar cambios de otro programador.
6. La integración de cambios requiere revisión y autorización humana.
7. Cada programador debe trabajar en su propia rama de trabajo, siguiendo `docs/development/GIT_WORKFLOW.md`.
8. No crear, cambiar, fusionar ni eliminar ramas sin autorización expresa.
9. No realizar commits ni pushes sin autorización expresa.

Consulta `docs/development/TEAM_RESPONSIBILITIES.md` para conocer el reparto completo de responsabilidades y límites de modificación.

Consulta `docs/development/GIT_WORKFLOW.md` para las reglas de trabajo paralelo e integración.
