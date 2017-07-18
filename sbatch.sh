#!/bin/bash

#SBATCH --job-name=array
#SBATCH   --output=array.%A_%a.out
#SBATCH    --error=array.%A_%a.err
#SBATCH --time=1:00:00
#SBATCH --qos=normal
#SBATCH -p owners
#SBATCH --nodes=1
#SBATCH --cores=1
#SBATCH --mem=8000
#SBATCH --mail-type=END,FAIL
#################
# Usage: $ sbatch --array=1-2,4%1 sbatch.sh
#
set -beEu -o pipefail

echo "[$0 $(date +%Y%m%d-%H%M%s)] [array-start] SLURM_JOBID = ${SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${SLURM_ARRAY_TASK_ID}" >&2

task_id=$SLURM_ARRAY_TASK_ID
bash task.sh $task_id

echo "[$0 $(date +%Y%m%d-%H%M%s)] [array-end] SLURM_JOBID = ${SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${SLURM_ARRAY_TASK_ID}" >&2

