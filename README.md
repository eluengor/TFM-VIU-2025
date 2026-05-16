# Flujo de trabajo automático de Snakemake para la caracterización genómica de bacteriófagos
## Descripción



## Uso

1. Descarga las bases de datos ejecutando:
```bash
bash scripts/setup_databases.sh 
```
2. Ejecuta `docker build -t phagetermvirome:4.3 -f Dockerfile.phagetermvirome .` antes de lanzar Snakemake.
3. 
4. Coloca los archivos FASTQ del fago en `data/raw_reads/`.
5. Ejecuta el snakefile:
```bash
   snakemake --use-singularity --cores N
   # N puede ser un número, o all
```


