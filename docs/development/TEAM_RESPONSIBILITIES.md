# Responsabilidades del equipo

## 1. Objetivo

Establecer una separación clara entre el desarrollo del backend y del
frontend de Gestión Comercial, permitiendo que dos programadores y sus
respectivos agentes IA trabajen en paralelo sin comprometer la arquitectura,
los datos ni las reglas de negocio.

## 2. Responsables

### Responsable principal del backend

Responsable de:
- Base de datos Drift y sus migraciones.
- Tablas, índices, restricciones y triggers.
- Repositorios y servicios de dominio.
- Reglas de negocio.
- Cálculos financieros y conversiones monetarias.
- Inventario, movimientos y recepciones.
- Compras, pagos y conservación de información histórica.
- Pruebas de backend y base de datos.

### Responsable principal del frontend

Responsable de:
- Diseño y construcción de interfaces.
- Pantallas, formularios y componentes visuales.
- Navegación y rutas.
- Gestión del estado de presentación.
- Adaptación a Android y Windows.
- Accesibilidad, responsividad y experiencia de usuario.
- Pruebas de widgets e integración visual.

### Responsabilidad compartida

Ambos participan en:
- Definición de contratos entre frontend y backend.
- Integración de funcionalidades.
- Revisión de cambios que afecten a ambas áreas.
- Validación de flujos completos.
- Resolución de conflictos de integración.

## 3. Propiedad de archivos

| Ubicación | Responsable principal |
|---|---|
| lib/core/database/ | Backend |
| lib/features/*/data/ | Backend |
| lib/features/*/domain/ | Backend |
| lib/app/ | Frontend |
| lib/features/*/presentation/ | Frontend |
| test/ | Responsable del módulo correspondiente |
| pubspec.yaml | Compartido; requiere coordinación |

La propiedad principal no impide consultar ni analizar archivos de otras áreas.

## 4. Límites de modificación

El responsable de frontend no debe modificar por iniciativa propia:
- Tablas o esquemas de Drift.
- Migraciones de base de datos.
- Triggers, índices o restricciones.
- Repositorios de datos.
- Servicios de dominio.
- Reglas financieras, monetarias o de inventario.

Si una pantalla necesita una operación que el backend no proporciona,
debe documentar la necesidad y coordinarla con el responsable del backend.

El responsable de backend no debe realizar cambios visuales o de experiencia
de usuario fuera de una tarea coordinada.

Los cambios en archivos compartidos, dependencias o configuración requieren
acuerdo previo.

## 5. Reglas para agentes IA

Todo agente IA debe:
1. Leer AGENTS.md antes de trabajar.
2. Leer la documentación relacionada con su tarea.
3. Identificar los archivos que necesita modificar.
4. Respetar la propiedad de cada módulo.
5. No inventar APIs, métodos o comportamientos inexistentes.
6. No duplicar reglas de negocio ni cálculos en el frontend.
7. No acceder directamente a la base de datos desde las pantallas.
8. No eliminar ni reemplazar código ajeno sin autorización.
9. Informar archivos modificados, decisiones y pruebas ejecutadas.
10. Detenerse y solicitar coordinación cuando una tarea cruce los límites
    de responsabilidad.

## 6. Integración

- Cada programador trabaja en su propia rama.
- Los cambios se integran mediante Pull Requests.
- No se trabaja directamente sobre main.
- Los cambios de backend deben superar sus pruebas antes de integrarse.
- Los cambios de frontend deben superar análisis, pruebas y validación visual.
- Los cambios que afecten a ambos lados requieren revisión conjunta.
- No se acepta una integración que rompa pruebas existentes.

## 7. Principio fundamental

La interfaz presenta y recoge información; el backend valida y ejecuta
las reglas de negocio.

La integridad de los datos y la exactitud de los cálculos tienen prioridad
sobre la rapidez de implementación.
