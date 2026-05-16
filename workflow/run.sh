#!/usr/bin/env bash
set -euo pipefail

# Carpetas para Singularity dentro de /home (140 GB libres)
export SINGULARITY_CACHEDIR="$HOME/singularity/cache"
export SINGULARITY_TMPDIR="$HOME/singularity/tmp"
export APPTAINER_CACHEDIR="$HOME/singularity/cache"
export APPTAINER_TMPDIR="$HOME/singularity/tmp"

SIF_PREFIX="$HOME/singularity/snakemake_prefix"

mkdir -p "$SINGULARITY_CACHEDIR" "$SINGULARITY_TMPDIR" "$SIF_PREFIX"

snakemake \
  --use-singularity \
  --singularity-prefix "$SIF_PREFIX" \
  --cores all