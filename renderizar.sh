#!/bin/bash
#SBATCH --job-name=render-eqA
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=02:00:00
#SBATCH --output=render-%j.out
#SBATCH --error=render-%j.err

source /mnt/data/bioinfo3/compartido/setup-curso.sh
module load gcc/14.2.0
cd "$SLURM_SUBMIT_DIR"
/cm/shared/apps/rstudio/rstudio_sandbox/usr/lib/rstudio-server/bin/quarto/bin/quarto render reporte.qmd
