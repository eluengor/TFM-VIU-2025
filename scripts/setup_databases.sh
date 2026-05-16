#!/usr/bin/env bash

set -euo pipefail

WORKING_DIR="$(dirname "$(cd "$(dirname "$0")" && pwd)")"
DB_DIR="$WORKING_DIR/db"
LOG="$WORKING_DIR/log/setup_databases.log"

mkdir -p "$DB_DIR"
mkdir -p "$WORKING_DIR/log"
echo "" > "$LOG"

TAXMYPHAGE_IMAGE="quay.io/biocontainers/taxmyphage:0.3.7--pyhdfd78af_0"

CHECKV_IMAGE="antoniopcamargo/checkv:0.8.1"



# ----------------- Pull Docker images -----------------
echo -e "Pulling Docker images..." >> "$LOG"

docker pull "$TAXMYPHAGE_IMAGE" \
    2>> "$LOG"

docker pull "$CHECKV_IMAGE" \
    2>> "$LOG"



# ----------------- checkV -----------------
echo -e "Downloading CheckV database in db/checkv..." \
    >> "$LOG"

mkdir -p "$DB_DIR/checkv"

wget -q \
    -O "$DB_DIR/checkv/checkv-db-v1.5.tar.gz" \
    https://portal.nersc.gov/CheckV/checkv-db-v1.5.tar.gz \
    2>> "$LOG"

tar -xzf "$DB_DIR/checkv/checkv-db-v1.5.tar.gz" \
    -C "$DB_DIR/checkv" \
    --strip-components=1 \
    2>> "$LOG"


docker run --rm \
    --entrypoint diamond \
    -v "$DB_DIR/checkv:/db" \
    "$CHECKV_IMAGE" \
        makedb         \
            --in /db/genome_db/checkv_reps.faa \
            --db /db/genome_db/checkv_reps \
    2>> "$LOG"

rm -f "$DB_DIR/checkv/checkv-db-v1.5.tar.gz"

docker rmi "$CHECKV_IMAGE" \
    2>> "$LOG"



# ----------------- taxMyPhage -----------------
echo -e "Downloading taxMyPhage database in db/taxmyphage..." \
    >> "$LOG"

mkdir -p "$DB_DIR/taxmyphage"

docker run --rm \
    -v "$DB_DIR/taxmyphage:/db" \
    "$TAXMYPHAGE_IMAGE" \
        taxmyphage install -db /db  \
    2>> "$LOG"

mv "$DB_DIR/taxmyphage/ICTV.msh" "$DB_DIR/taxmyphage/ICTV_2024.msh"

docker rmi "$TAXMYPHAGE_IMAGE" \
    2>> "$LOG"



# ----------------- viralVerify -----------------
echo -e "Downloading viralVerify database in db/viralverify..." \
    >> "$LOG"

mkdir -p "$DB_DIR/viralverify"

wget -q \
    -O "$DB_DIR/viralverify/nbc_hmms.hmm.gz" \
    https://ndownloader.figshare.com/files/17904323 \
    2>>"$LOG"

gunzip -f "$DB_DIR/viralverify/nbc_hmms.hmm.gz" \
    2>>"$LOG"



# ----------------- pharokka -----------------
echo -e "Downloading pharokka's database in db/pharokka..." \

mkdir -p "$DB_DIR/pharokka"

wget -q \
    -O "$DB_DIR/pharokka/pharokka_v1.4.0_databases.tar.gz" \
    "https://zenodo.org/record/8276347/files/pharokka_v1.4.0_databases.tar.gz" \
    2>> "$LOG"

tar -xzf "$DB_DIR/pharokka/pharokka_v1.4.0_databases.tar.gz" \
    -C "$DB_DIR/pharokka" \
    --strip-components=1 \
    2>> "$LOG"

rm -rf "$DB_DIR/pharokka/pharokka_v1.4.0_databases.tar.gz" \
    2>> "$LOG"



echo -e "All databases downloaded.\n"