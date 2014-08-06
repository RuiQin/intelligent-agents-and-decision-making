#!/bin/csh

# Give the job a name
#$ -N example_job

# set working directory on all host to
# directory where the job was started
#$ -cwd

# send all process STDOUT (fd 2) to this file
#$ -o job_output.txt

# send all process STDERR (fd 3) to this file
#$ -e job_output.err

# Commands
./run.sh
