# Reglas de desarrollo con agentes IA

## 1. Principio

Los agentes IA son asistentes de implementación bajo supervisión humana. No son autoridad para decidir reglas de negocio, cambiar arquitectura financiera o ampliar el alcance.

## 2. Prompt inicial reutilizable

Copia este texto al iniciar una sesión de trabajo con un agente:

> Estás trabajando en `gestion_comercial`, una aplicación Flutter genérica de gestión comercial para Android y Windows. Antes de actuar, lee `AGENTS.md` y los documentos relevantes de `docs/`. Inspecciona el código y pruebas actuales; no supongas que la documentación sustituye al código. La prioridad es la integridad de datos y exactitud financiera.
>
> Tu tarea es exclusivamente: **[DESCRIBIR UNA TAREA CONCRETA]**.
>
> Archivos permitidos: **[LISTAR ARCHIVOS]**.
>
> Archivos/áreas prohibidas: base de datos, migraciones, SQL/triggers, código generado, repositorios y servicios financieros, salvo autorización explícita.
>
> No inventes reglas ni dupliques cálculos. No uses `double` para dinero o cantidades. Reutiliza repositorios y servicios existentes. No accedas directamente a tablas Drift desde widgets. Añade pruebas apropiadas.
>
> Antes de editar, informa brevemente qué archivos vas a inspeccionar/modificar y qué comportamiento implementarás. Si detectas una regla ausente, contradicción, dependencia o necesidad de tocar un área protegida, detente y pregunta.
>
> No hagas commit, push, merge ni cambies de rama. Al terminar, ejecuta formato, análisis y pruebas pertinentes; informa exactamente qué comandos ejecutaste, resultados, archivos modificados y limitaciones. No afirmes validaciones que no hayas ejecutado.

## 3. Tareas bien delimitadas

Una tarea debe indicar:
- resultado observable;
- módulo/pantalla;
- archivos o directorios permitidos;
- datos/repositorios a consumir;
- estados de carga/vacío/error;
- validaciones de UI;
- pruebas y criterios de aceptación.

Evitar instrucciones vagas como “construye todo el frontend” o “mejora la arquitectura”.

## 4. Prohibiciones

- No cambiar esquema, migraciones, triggers, SQL ni código generado.
- No modificar repositorios o servicios financieros en una tarea frontend.
- No editar directamente tablas desde la UI.
- No duplicar lógica de descuentos, impuestos, tasas, redondeos o saldo.
- No usar `double` para dinero/cantidades.
- No eliminar datos históricos ni sustituir registros por valores ficticios.
- No cambiar dependencias/versiones sin aprobación.
- No introducir paquetes nuevos sin justificación y aprobación.
- No borrar archivos aparentemente no usados sin búsqueda global y revisión humana.
- No realizar commits/pushes/merges sin autorización.

## 5. Colaboración entre agentes

- Asignar un único responsable por archivo o grupo de archivos compartidos.
- Evitar que dos agentes editen simultáneamente `app.dart`, tema, router o componentes comunes.
- Definir contratos de navegación, estado y componentes antes de repartir pantallas.
- Un agente puede revisar código ajeno, pero no reescribirlo sin coordinación.
- Registrar dependencias y bloqueos en la tarea.
- Integrar mediante pull request y revisión humana.

## 6. Revisión de salida

Rechazar una entrega si:
- incumple reglas de negocio;
- cambia archivos fuera del alcance;
- introduce cálculos duplicados o `double`;
- no contempla estados de error/carga;
- carece de pruebas razonables;
- rompe formato, análisis o pruebas;
- afirma validaciones no ejecutadas;
- no documenta limitaciones.

## 7. Incidencias conocidas

- Dos `purchase_repository.dart`; el de `data` es el que se encontró importado desde código y pruebas. No borrar el de `domain` incidentalmente.
- Comentarios antiguos de compras pueden no reflejar los repositorios actuales de recepciones/pagos.
- Cambio de `trackInventory` con historia previa requiere decisión.
- Riverpod está declarado pero no configurado en el código auditado.
