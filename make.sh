#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020 Tango Golf Digital, LLC
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

# This script is generally included as a submodule within a Swift project
# located (from the project root) at ./MerlinMake/make.sh
# It generates and executes the command line required to use the
# proper version of merlin libraries based upon a file named 'dylib.manifest'
# which must be located in the project root if dynamic libraries are required.
# If the file does not exist, no error occurs, and the commandline will be
# generated without referencing any dynamic libraries.
# The project root is the same location as .git and Package.swift (if required).

# Arguments:
# --mode='build'|'run'|'list-dylib-paths', default is 'build', short key is -m
# --configuration='debug'|'release', default is 'debug', short key -s -c

# Dynamic library dependencies are specified in the file 'dylib.manifest' located in the same directory
# as make.sh.
# There are two line formats:
# project version -OR-
# project LOCAL path
#
# The second format facilitates simple development of libraries by easily allowing a local directory
# as a source.
# For example:
# Igis		LOCAL		/home/john-williams/projects/Igis
# Scenes	0.1.8

# Reference: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

# Reference: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# Read options
options=m:c:
longOptions=mode:,configuration:
! parsed=$(getopt --options=$options --longoptions=$longOptions --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$parsed"

# Defaults
mode='build'
configuration='debug'
while true; do
    case "$1" in
	-m|--mode)
	    mode="$2"
	    shift 2
	    ;;
	-c|--configuration)
	    configuration="$2"
	    shift 2
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

# Verify arguments
if [[ ! "$configuration" =~ ^(debug|release)$ ]]; then
    echo "Unexpected configuration; must be either debug or release, not $configuration"
    exit 1
fi

if [[ ! "$mode" =~ ^(build|run|list-dylib-paths)$ ]]; then
    echo "Unexpected mode; must be either build, run or list-dylib-paths, not $mode"
    exit 1
fi

# Requires: MERLIN_LIBRARY_ROOT_DIR (e.g. /usr/local/lib/merlin)
[ -z "$MERLIN_LIBRARY_ROOT_DIR" ] && { echo "MERLIN_LIBRARY_ROOT_DIR must be defined"; exit 1; }

# Reference: https://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
get_script_dir () {
    source="${BASH_SOURCE[0]}"
    # While $source is a symlink, resolve it
    while [ -h "$source" ]; do
	dir="$( cd -P "$( dirname "$source" )" && pwd )"
	source="$( readlink "$source" )"
	# If $source was a relative symlink (so no "/" as prefix, need to resolve it relative to the symlink base directory
	[[ $source != /* ]] && source="$dir/$source"
    done
    dir="$( cd -P "$( dirname "$source" )" && pwd )"
    echo "$dir"
}

# Start with a basic command line and empty library path
dylibPaths=""
commandLine="swift $mode -c $configuration"
LD_LIBRARY_PATH=""

# Find the manifest path
# Because we're in a submodule of the root directory, we search one level up from the script location
manifestPath="$( realpath "$(get_script_dir)/../dylib.manifest" )"

# Read the manifest file
# If it exists, it must be in the format projectName tag

if [ -f $manifestPath ]; then
    while read line; do
	if [ ! -z "$line" ]; then
	    # If the line is not empty, it must be in the format specified
	    # The first case is specification of a library found in the MERLIN_LIBRARY_ROOT_DIR
	    # This format specifies only a library name and version
	    # e.g. "Igis 1.0.7"
	    libraryRegex='^([[:alpha:]]+)[[:space:]]+([[:alnum:]\.]+)$'

	    # An alterntive is specifying a local path which will be used directly
	    # iff the tag is 'LOCAL'
	    localRegex='^([[:alpha:]]+)[[:space:]]+LOCAL[[:space:]]+([[:alnum:]/-]+)$'
	    
	    if [[ "$line" =~ $localRegex ]]; then
		project=${BASH_REMATCH[1]}
		directory=${BASH_REMATCH[2]}

		# The library path is determined by the exact name used for the directory
		libraryPath="$directory/.build/$configuration"
            elif [[ "$line" =~ $libraryRegex ]]; then
		project=${BASH_REMATCH[1]}
		tag=${BASH_REMATCH[2]}

		# Determine the library path based on the name of the project and tag
		libraryPath="$MERLIN_LIBRARY_ROOT_DIR/$project-$tag/$project/.build/$configuration"
	    else
		echo "Unexpected line format: $line"
		exit 1
	    fi

	    # Verify that the libraryPath exists
  	    if [[ ! -d "$libraryPath" ]]; then
		echo "The specified library path was not found '$libraryPath'"
		exit 1
	    fi

	    # Build the dylib paths for parsing with one path per line
	    if [[ ! -z "$dylibPaths" ]]; then
		printf -v dylibPaths "$dylibPaths\n"
	    fi
	    dylibPaths="$dylibPaths$libraryPath"
	    
	    # Build the command line by appending the library for inclusion and linking
	    commandLine="$commandLine -Xswiftc -I -Xswiftc $libraryPath"
	    commandLine="$commandLine -Xswiftc -L -Xswiftc $libraryPath"
	    commandLine="$commandLine -Xswiftc -l$project"
	    
	    # Build the LD_LIBRARY_PATH
	    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$libraryPath"

	    # Define a new variable of the form DYLIB_$project_PATH to contain the library path for the
	    # specified library.  The library may refer to this environment variable to find files
	    # relative to itself.
	    dylibVariableName=DYLIB_${project}_PATH
	    printf -v $dylibVariableName "%s" "$libraryPath"
	    export $dylibVariableName
	fi 
    done < "$manifestPath"
fi

# Export required variables
export LD_LIBRARY_PATH

# If the mode is run or build, we evaluate the command line
case $mode in
    build|run)
	eval "$commandLine"
	;;
    list-dylib-paths)
	echo "$dylibPaths"
	;;
    *)
	echo "Unexpected mode $mode"
	exit 1
	;;
esac
