#!/bin/bash
# Check to see if target is already running
# If not, start target with the specified parameters
# If so, inform the user that the target is already running and that they may
#    resume with "fg"

# Because this script relies on the 'jobs' command, it MUST be sourced
# Reference: https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script MUST be sourced."
    exit 1
fi
   
# Remember the target
target=$1

# Shift the target out so that we can start the application with the remaining
# arguments in $@
shift


# Determine running processes (in all shells of this user)
runningPids=`pidof $target`

# The list is space delimited but we want it to be line delimited
runningPids=`tr ' ' '\n' <<< "$runningPids"`

# We now look for only those jobs in our current shell
# with a matching pid
jobs=`jobs -l`
jobPids=`awk '{print $2}' <<< "$jobs"`

# Iterate over the jobPids
# If the pid of our process(es) matches that of a job in this shell
# track it in an array
# This is the intersection of all processes for the target and those
# in the current shell
pidsInShell=()
while read jobPid; do
    while read runningPid; do
	if [ $jobPid -eq $runningPid ]; then
	    pidsInShell+=($jobPid)
	fi
    done <<< "$runningPids"
done <<< "$jobPids"

# Iterate over only the relevant pids
# Print the associated job description for each relevant pid
for pidInShell in "${pidsInShell[@]}"
do
    while read job; do
	jobPid=`awk '{print $2}' <<< "$job"`
	jobNumber=`awk -F'[][]' '{print $2}' <<< "$job"`
	if [ $jobPid -eq $pidInShell ]; then
	    echo -e "$target is already running in this shell: $job"
	    echo -e "\tType 'fg $jobNumber' to resume"
	fi
    done <<< $jobs
done

# If no jobs are already running, start a new instance of target with the specified
# arguments
if [ ${#pidsInShell[@]} -eq 0 ]; then
    commandPath=`which $target`
    echo "$target is not already running.  Starting $target."
    commandLine="$commandPath $@"
    eval $commandLine
fi
