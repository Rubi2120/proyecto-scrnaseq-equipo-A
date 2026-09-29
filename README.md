# Proyecto final equipo A

> Análisis de células individuales del conjunto de datos asignado al equipo A
> (artefacto mitocondrial). Bioinformática y Estadística 3, LCG 2027-1.

## Qué es este repositorio

El análisis del conjunto de datos que se le asignó a nuestro equipo, de principio
a fin, de forma que cualquier persona pueda reproducirlo desde cero: llamado de
células, control de calidad, normalización, reducción de dimensionalidad,
agrupamiento y marcadores. La condición que se evalúa (criterio A2 de la rúbrica,
30 %) es que corra en otra máquina sin intervención manual.

## Integrantes

| Nombre | Qué hizo |
|---|---|
| Rubí Martínez Chavarría | |
| Alejandro Pinto Sánchez | |
| Ernesto Gutierrez Piñon | |

## Cómo reproducir este análisis

```bash
git clone <la-url-de-este-repositorio>
cd <el-repositorio>
sbatch renderizar.sh
```

Se ejecuta en el clúster `ken`, desde la carpeta clonada. `renderizar.sh` carga el
entorno del curso (`setup-curso.sh` y `gcc/14.2.0`) y corre
`quarto render reporte.qmd`; tarda unos 9 minutos y produce `reporte.html`. Antes del render limpia los
módulos (`module purge`) y quita `anaconda3` de `LD_LIBRARY_PATH`: sin eso,
`scDblFinder` cerraba R con un *segmentation fault* (ver «Lo que no funcionó»
en el reporte). Si `sbatch` no se encuentra, primero: `module load slurm/slurm/25.11`. No
debe enviarse más de una vez a la vez: dos renders simultáneos se pisan los
archivos temporales.

**Los datos no están en el repositorio** y no deben estarlo: `.gitignore` los
excluye. El reporte los lee de la carpeta compartida del curso.

| Dato | Dónde vive | Cómo se obtuvo |
|---|---|---|
| Objeto `SingleCellExperiment` con la matriz `raw` de cuentas (38,606 genes × 927,681 códigos de barras) | `/mnt/data/bioinfo3/compartido/10x/datasets/proyecto-2026/proyecto-equipo-A.rds` | Entregado por el curso en la carpeta compartida del módulo (formato `.rds`, asignado al equipo A). Se lee desde ahí; no se copia |
| Resumen de referencia del equipo (4,094 células, artefacto mitocondrial, medianas de 9,040 cuentas y 2,978 genes) | `/mnt/data/bioinfo3/compartido/10x/datasets/proyecto-2026/resumen-objetos-proyecto.tsv` | Entregado por el curso; se usó solo como referencia de comparación |

## Estructura

| Carpeta o archivo | Qué va aquí |
|---|---|
| `reporte.qmd` | El reporte ejecutable. Es el entregable |
| `renderizar.sh` | Guion de SLURM que renderiza el reporte |
| `R/` | Funciones que se usen en más de un lugar (vacía por ahora) |
| `datos/` | Vacía a propósito: los datos no se versionan |
| `figuras/` | No la usa el reporte: sus figuras se incrustan en `reporte.html`. No se versiona |

## Bitácora de decisiones

La misma tabla, con más detalle, está en `reporte.qmd` (sección «Tabla de
decisiones»). Las fechas son las de trabajo en el clúster.

| Fecha | Decisión | Por qué | Qué se probó antes | Dónde se aplica en el código |
|---|---|---|---|---|
| 19 sep 2026 | Llamado de células con `emptyDrops`, FDR ≤ 0.001 | Usa el perfil de expresión completo y no solo el total de cuentas; recupera 3,998 células, cerca de las 4,094 de referencia; sin p-valores topados | Codo (3,137 células) e inflexión (4,101) de la curva de rango | `qc-llamado` |
| 19 sep 2026 | Filtro de %MT en 35 % | Las cuentas y los genes se mantienen hasta 35 % y caen después (análisis por tramos); la población de 10 a 35 % se comporta como biología metabólica y no como daño | MAD de 3 desviaciones (11.63 %; descartaba 916 células) y umbral fijo de 20 % (489) | `qc-mt-filtro` |
| 20 sep 2026 | Sin umbral adicional de cuentas ni de genes; se marcan las 108 células bajo 1,721 cuentas o 1,034 genes | `emptyDrops` ya exige un perfil distinto del ambiente; solo 25 de las 108 tienen %MT mayor a 20 %, así que no siguen el perfil clásico de daño; se rastrean en el agrupamiento | Umbral adaptativo de 5 MADs en escala logarítmica (clase 1) | `qc-cuentas-genes` |
| 20 sep 2026 | Conservar y marcar el clúster 9 (284 células; concentra 99 de las 108 marcadas) | Sus marcadores son de linaje T, compartidos con los clústeres 1 y 6, y no tiene un perfil propio; descartarlo eliminaría células compatibles con linfocitos T | Marcadores, `LEF1` y cruce con las células marcadas; reagrupar sin las 108 (sección 4.5.5): el clúster persiste | `qc-cuentas-genes`, `qc-post-cluster`, `sens-sin108` |
| 27 sep 2026 | `scDblFinder` 1.26.7: 186 de 3,916 células (4.75 %) marcadas como doblete y conservadas | Eliminarlas cambiaría todas las cifras y los clústeres; marcarlas permite ver dónde caen (el clúster 5 tiene 31.2 %) | El paquete cerraba R con un segfault; se resolvió renderizando con `module purge`, `gcc/14.2.0` y sin `anaconda3` en `LD_LIBRARY_PATH` | `qc-dobletes`, `dobletes-por-cluster` |
| 20 sep 2026 | Normalización con `logNormCounts` | Estándar de Bioconductor; equivale a `LogNormalize` de la clase 1 | Deconvolución de `scran` (sección 4.5.1): ARI 0.867 contra la elegida | `normalizacion`, `sens-normalizacion` |
| 20 sep 2026 | 2,000 genes variables con `modelGeneVar` y `getTopHVGs` | Es la convención, no un resultado; construyen el espacio y no sirven para anotar | 500, 1,000 y 3,000 genes (sección 4.5.2): el agrupamiento se estabiliza desde 2,000 | `parametros`, `normalizacion`, `sens-hvg` |
| 20 sep 2026 | Sin eliminar covariables por regresión | El %MT está correlacionado con la biología; ninguna de las 10 primeras PCs pasa de 0.5 de correlación con el %MT (máximo 0.27) ni con las cuentas (máximo 0.39) | Correlaciones de las PCs con %MT y con cuentas | `pca-diagnostico` |
| 20 sep 2026 | 15 componentes principales | Codo entre PC5 y PC6; errar por exceso es más seguro que por defecto | Varianza acumulada con 10, 20 y 30 PCs: 40.1 %, 42.5 % y 43.9 % | `parametros`, `pca`, `pca-diagnostico` |
| 20 sep 2026 | UMAP con los valores por defecto de `runUMAP`, 15 PCs y semilla 20260903 | Un UMAP se usa para comunicar, no para derivar conclusiones | 15 y 30 PCs con `n_neighbors` 5, 15 y 50 (sección 4.5.3): mismas poblaciones, cambia el dibujo | `umap-agrupamiento`, `sens-umap` |
| 20 sep 2026 | Agrupamiento con Louvain, k = 20 y 15 PCs | Da 10 clústeres de 77 a 741 células | k = 10 y 30, y 10 y 30 PCs (sección 4.5.4): ARI 0.81–0.95, de 7 a 12 clústeres | `umap-agrupamiento`, `sens-agrupamiento` |
