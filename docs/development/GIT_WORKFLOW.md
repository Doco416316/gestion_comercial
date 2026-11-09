# Flujo Git y colaboración

## 1. Estado de referencia auditado

Repositorio remoto: `Doco416316/gestion_comercial`.

En la auditoría:
- rama activa: `feature/frontend`;
- commit: `9791a0b`;
- `feature/frontend` estaba sincronizada con `origin/feature/frontend`;
- `main` y `develop` apuntaban al commit inicial `824c597`.

Comprueba siempre el estado real con `git status`, `git branch --show-current` y `git log` antes de trabajar.

## 2. Propuesta de ramas

Propuesta para acordar entre responsables:
- `main`: versiones estables.
- `develop`: integración.
- `feature/<tema>`: trabajo por funcionalidad.
- `fix/<tema>`: correcciones.
- Pull requests hacia `develop`; promoción a `main` mediante revisión.

La rama `feature/frontend` ya existe y tiene historia. No renombrarla ni reemplazarla sin acuerdo explícito.

## 3. Trabajo paralelo

- Asignar módulos/archivos exclusivos a cada programador.
- Evitar que ambos trabajen sobre router, tema, layout o providers compartidos al mismo tiempo.
- Si hay cambios compartidos, definir primero un contrato y un responsable.
- No trabajar directamente sobre la misma rama compartida si ambos pueden modificar los mismos archivos.
- Actualizar la rama de trabajo de forma controlada antes de integrar.
- Resolver conflictos entendiendo el comportamiento, no eligiendo automáticamente “ours” o “theirs”.

## 4. Commits y pull requests

Convención sugerida:
- `feat(frontend): ...`
- `fix(frontend): ...`
- `test(frontend): ...`
- `docs: ...`
- `refactor(frontend): ...`

Cada PR debe incluir:
- objetivo y alcance;
- capturas cuando haya cambios visuales;
- archivos relevantes;
- pruebas ejecutadas;
- resultado de CI;
- limitaciones y decisiones pendientes.

No hacer push, commit, merge, rebase destructivo ni cambios de rama sin autorización expresa del responsable del proyecto.

## 5. Protección de ramas

Recomendado configurar en GitHub:
- PR obligatorio hacia ramas protegidas;
- CI requerido;
- revisión humana antes de merge;
- evitar force push;
- no permitir que agentes integren sus propios cambios sin revisión.

La disponibilidad de estas opciones depende de la configuración y el plan de GitHub; comprobarlo en el repositorio.

## 6. Comandos de inspección

```powershell
git status --short
git branch --show-current
git log -5 --oneline --decorate
git diff --stat
git diff --check
```

## 7. No hacer

- No incluir `.dart_tool/` o `build/` en commits.
- No hacer commit de cambios ajenos a la tarea.
- No sobrescribir cambios locales de otro programador.
- No forzar push para resolver divergencias.
- No integrar sin revisar CI y pruebas.
