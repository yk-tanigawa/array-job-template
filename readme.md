# Array job template

- requirements
  - GNU parallel (for `find*.sh`, you can submit jobs without paralell)


## SLURM job script
- sbatch.sh
  - You can submit your job with this script. Please modify resource requrements as needed.
- task.sh
  - One array job consists of multiple tasks. One can modify this task.sh to specify your task.

## check script
- find_ok.sh
  - This script checks *.err files to obtain the task_ids of successful tasks
- find_resubmit.sh
  - This script runs find_ok.sh and find the indices of unsuccessful tasks

# How it works?

## job submission

### `sbatch.sh` 

This works as a regular SLURM job script. One can specify resource requirements for SLURM job manager here.
This script also dumps sstart time, end time, hostname, job ID, and task ID. These *debug lines* are used in the check scripts (`find*.sh`).

```
echo "[$0 $(date +%Y%m%d-%H%M%S)] [array-start] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${SLURM_ARRAY_TASK_ID}" >&2

echo "[$0 $(date +%Y%m%d-%H%M%S)] [array-end] hostname = $(hostname) SLURM_JOBID = ${SLURM_JOBID}; SLURM_ARRAY_TASK_ID = ${SLURM_ARRAY_TASK_ID}" >&2
```

### `task.sh`

This script is to configure some parameters based on `task_id`. Usually, I prepare some lookup table to specify the necessary arguments for the analysis. With those parameters, one can call some external script. I personally prefer to keep actual job script (like running GWAS, etc.) in a different location of this directory to keep the script directory clean.

### `find*.sh`

It is annoying to check the indeces of the failed jobs. I prepared some scripts for the following two types of failures.
1. Task may not start even though the `squeue` command says it's running
  - This was a bug in SLURM. 
    - https://github.com/SchedMD/slurm/commit/0148cde0b9b867164173899e89c103dfd49fab02
  - One way to walk around is to check the output/error files.
  - `find_started.sh` and `find_restart.sh` are the scripts to cope with this issue (described later)
2. Task failed for whatever reasons
  - You script may have a bug, resource requirements may not be sufficient, etc. There are tons of reasons that cause some issues in the job.
  - ` find_ok.sh` `find_resubmit.sh` are the scripts to check this type of error.

#### `find_started.sh`
- This script checks *debug lines* (described above) error files 
