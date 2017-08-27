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
  - `find_ok.sh` `find_resubmit.sh` are the scripts to check this type of error.

#### `find_started.sh`

- This script checks *debug lines* (described above) error files in a directory (1st argument for the script) to enumerate list of task IDs of succesfully started jobs. More specifically, this script looks at line with `array-start` (simple `grep`).
- usage: `bash find_started.sh .` (to check the current dir)

#### `find_restart.sh`

- This script finds a missing indeces from interval [1, number_of_tasks]. This calls `find_started.sh` as a subroutine. 
- If you believe the tasks 1-100 is running on the cluster (based on what you get from `squeue`), you can run `find_restart.sh 100 .`. If they are all running, the output should be empty.

#### `find_ok.sh`

- Similar idea to `find_started.sh`, but now this checks `array-end` in debug lines in your error files.
- usage: `bash find_ok.sh .`

#### `find_resubmit.sh`

- Similar idea to `find_restart.sh`. If you have 800 tasks (usually the same number as `wc -l lookup.tsv`), you can run `find_resubmit.sh 800 .`. If all of them are successful, the output should be empty. If not, look at specific error files to understand what went wrong.
