#!/bin/bash
#SBATCH --job-name=render-eqA
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=02:00:00
#SBATCH --output=render-%j.out
#SBATCH --error=render-%j.err

module purge
source /mnt/data/bioinfo3/compartido/setup-curso.sh
module load gcc/14.2.0
export TZ=America/Mexico_City
export LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v anaconda3 | paste -sd:)

cd "$SLURM_SUBMIT_DIR"

/cm/shared/apps/rstudio/rstudio_sandbox/usr/lib/rstudio-server/bin/quarto/bin/quarto render reporte.qmd
