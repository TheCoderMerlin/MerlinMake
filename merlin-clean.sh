#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020,2021 Tango Golf Digital, LLC
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script cleans all .build directories from ~/Merlin

# Arguments:
# --dry-run

# Reference: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset
set -eu
shopt -s nullglob

merlinDirectory=~/Merlin

# Reference: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# Read options
options=d
longOptions=dryrun
! parsed=$(getopt --options=$options --longoptions=$longOptions --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$parsed"

# Defaults
dryrun=false
while true
do
    case "$1" in
	-d|--dryrun)
	    dryrun=true
	    shift 1
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo "Unexpected argument $1"
	    exit 3
	    ;;
    esac
done

if $dryrun
then
    echo "DRY RUN only.  No files will be deleted."
fi


# Regardless from where we're executing, we always operate ONLY on the ~/Merlin directory
pushd "$merlinDirectory" > /dev/null

# Iterate through all missions (first directory level)
totalSize=0
for mission in M[0-9][0-9][0-9][0-9]-[0-9][0-9]*
do
    if [ -d "$mission" ]
    then
	pushd "$mission" > /dev/null
	# Iterate through all challenges
	for challenge in C[0-9][0-9][0-9]*
	do
	    if [ -d "$challenge" ]
	    then
		# Determine if a .build directory exists
		pushd "$challenge" > /dev/null

		if [ -d ".build" ]
		then
		    directorySize=$(du -sb '.build' | cut -f1)
		    totalSize=$((totalSize + directorySize))
		    echo "Cleaning $challenge to free $directorySize bytes"

		    if [ "$dryrun" == "false" ]
		    then
			rm -rf '.build'
		    fi
		fi

		popd > /dev/null # Pop challenge
	    fi
	done
	popd > /dev/null # Pop mission
    fi
done


# Return to our original directory
popd > /dev/null # Pop Merlin mission directory

echo "Total bytes freed: $totalSize"

      

