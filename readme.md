# Array job template

- requirements
  - GNU parallel


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

