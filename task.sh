#!/bin/bash
set -beEu -o pipefail


# pass the following paramters to your script
task_id=$1
memory=8000
threads=1

bash your_script.sh $task_id $memory $threads

sleep 10

