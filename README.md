# TFM-VIU-2025: Flujo de trabajo para el análisis genómico de bacteriófagos purificados

**Trabajo Fin de Máster — Máster Universitario en Bioinformática (VIU)**  
Alumna: Ester Luengo Rodríguez  
Director: Pablo Marín García  
Convocatoria: Mayo 2026

---

## Descripción

Este repositorio contiene el flujo de trabajo bioinformático diseñado e implementado como parte de la revisión integrativa sobre herramientas para el análisis genómico de bacteriófagos purificados. El pipeline cubre las siete etapas canónicas identificadas en la revisión bibliográfica: control de calidad de lecturas, procesamiento, ensamblaje de novo, descontaminación y selección del contig fágico, reordenamiento del genoma, anotación funcional y estructural, clasificación taxonómica y cribado de bioseguridad.

![Etapas canónicas de la caracterización genómica de fagos.](https://raw.githubusercontent.com/eluengor/TFM-VIU-2025/assets/images/mermaid_workflow.png)
Etapas canónicas de la caracterización genómica de fagos.

El flujo está implementado en **Snakemake**, contenerizado con **Docker** y versionado con **Git/GitHub**, garantizando la reproducibilidad y portabilidad del análisis con independencia del entorno computacional.

![Diagrama DAG del flujo de trabajo generado automáticamente por Snakemake.](https://raw.githubusercontent.com/eluengor/TFM-VIU-2025/assets/images/dag.svg)
Diagrama DAG del flujo de trabajo generado automáticamente por Snakemake.

---

## Estructura del repositorio

```
TFM-VIU-2025/
├── workflow/
│   ├── Snakefile
├── scripts/
│   ├── select_phage_contig.py
│   └── setup_databases.py
├── config/
│   └── config.yaml
├── dockerfiles/
│   └── Dockerfile.phageterm
├── LICENSE
└── README.md
```

---

## Requisitos previos

- [Snakemake](https://snakemake.readthedocs.io/) >= 7.0
- [Docker](https://www.docker.com/)
- Las bases de datos de CheckV, ViralVerify, Pharokka y taxMyPhage deben descargarse antes de la primera ejecución (ver sección "Instalación")

---

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/eluengor/TFM-VIU-2025.git
cd TFM-VIU-2025
```

### 2. Descargar las bases de datos

```bash
bash setup_databases.sh
```

Este script descarga las bases de datos requeridas por CheckV, ViralVerify, Pharokka y taxMyPhage. Solo es necesario ejecutarlo una vez. Las rutas de salida se configuran en `config/config.yaml`.

### 3. Configurar el análisis

Edita `config/config.yaml` para especificar:
- Las rutas a los ficheros FASTQ de entrada
- Las rutas a las bases de datos descargadas
- Los parámetros de filtrado (umbral de calidad Q30, longitud mínima 50 bp, número de lecturas para el subsampling, parámetros de selección del contig...)

---

## Ejecución

```bash
snakemake --use-singularity --cores all
```

### Vista previa del DAG de dependencias

```bash
snakemake --dag | dot -Tpng > dag.png
```

### Ejecución en seco (dry-run)

```bash
snakemake -n
```

---

## Imágenes Docker utilizadas

Cada herramienta del flujo se ejecuta dentro de su propio contenedor. A continuación se listan las imágenes empleadas junto con sus repositorios de referencia.

| Herramienta | Imagen Docker | Repositorio |
|---|---|---|
| FastQC | `docker://pegi3s/fastqc:0.12.1` | [pegi3s/fastqc en Docker Hub](https://hub.docker.com/r/pegi3s/fastqc) |
| BBDuk (BBMap) | `docker://quay.io/biocontainers/bbmap:39.81--h9b5c0a0_1` | [bbmap en BioContainers](https://quay.io/repository/biocontainers/bbmap) |
| Seqtk | `docker://quay.io/biocontainers/seqtk:1.5--h577a1d6_1` | [seqtk en BioContainers](https://quay.io/repository/biocontainers/seqtk) |
| SPAdes | `docker://quay.io/biocontainers/spades:4.2.0--h8d6e82b_2` | [spades en BioContainers](https://quay.io/repository/biocontainers/spades) |
| ViralVerify | `docker://quay.io/biocontainers/viralverify:1.1--hdfd78af_0` | [viralverify en BioContainers](https://quay.io/repository/biocontainers/viralverify) |
| CheckV | `docker://antoniopcamargo/checkv:0.8.1` | [antoniopcamargo/checkv en Docker Hub](https://hub.docker.com/r/antoniopcamargo/checkv) |
| Script selección contig (pandas) | `docker://quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0` | [pandas en BioContainers](https://quay.io/repository/biocontainers/pandas) |
| Pharokka | `docker://quay.io/biocontainers/pharokka:1.9.1--pyhdfd78af_1` | [pharokka en BioContainers](https://quay.io/repository/biocontainers/pharokka) |
| PhageTerm | `docker://eluengor/phageterm:1.0.12-tfm` | [eluengor/phageterm en Docker Hub](https://hub.docker.com/r/eluengor/phageterm) — imagen construida específicamente para este trabajo |
| taxMyPhage | `docker://quay.io/biocontainers/taxmyphage:0.3.6--pyhdfd78af_0` | [taxmyphage en BioContainers](https://quay.io/repository/biocontainers/taxmyphage) |
| BACPHLIP + HMMER | `quay.io/biocontainers/mulled-v2-e16bfb0f667f2f3c236b32087aaf8c76a0cd2864:c64689d7d5c51670ff5841ec4af982edbe7aa406` | [mulled image en BioContainers](https://quay.io/repository/biocontainers/mulled-v2-e16bfb0f667f2f3c236b32087aaf8c76a0cd2864) — imagen combinada con BACPHLIP, HMMER3 y numpy |

> **Nota sobre PhageTerm:** esta herramienta no dispone de imagen pública en repositorios de BioContainers. El `Dockerfile` utilizado para construir `eluengor/phageterm:1.0.12-tfm` se encuentra en `dockerfiles/phageterm/`.

> **Nota sobre BACPHLIP:** el paquete individual de BACPHLIP no incluye `hmmsearch` (HMMER3), que es una dependencia de ejecución obligatoria. Por este motivo se utiliza una imagen que combina BACPHLIP, HMMER y numpy en un único contenedor.

---

## Módulos del flujo

| Módulo | Regla(s) | Herramienta(s) | Descripción |
|---|---|---|---|
| 0 | `r00_qc_raw_reads` | FastQC | Control de calidad de lecturas crudas |
| 1 | `r01a` – `r01d` | BBDuk, FastQC, Seqtk | Recorte de adaptadores, eliminación de PhiX, QC post-trimming y subsampling |
| 2 | `r02a` | SPAdes | Ensamblaje de novo |
| 3 | `r03a`, `r03b`, `r03c` | ViralVerify, CheckV, script Python | Clasificación de contigs, evaluación de la calidad del ensamblaje y selección del contig fágico |
| 4 | `r04_rearrangement` | PhageTerm | Reordenamiento del genoma según el inicio biológico |
| 5 | `r05_annotation` | Pharokka | Predicción de ORFs y anotación funcional y estructural |
| 6 | `r06_taxonomy` | taxMyPhage | Clasificación taxonómica frente a la base de datos ICTV |
| 7 | `r07_biosecurity_lifestyle_predictor` | BACPHLIP | Predicción del estilo de vida (lítico/lisogénico) |

---

---

## Licencia

Este repositorio se distribuye bajo la licencia MIT. Consulta el fichero `LICENSE` para más detalles.