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

# This script  generates and executes the command line required to use the
# proper version of merlin libraries based upon a file named 'dylib.manifest'
# which must be located in the project root if dynamic libraries are required.
# If the file does not exist, no error occurs, and the commandline will be
# generated without referencing any dynamic libraries.
# The project root is the same location as .git and Package.swift (if required).
# The script will build both packages and simple directories of *.swift files.

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
#
# An additional available option is to suffix the modifier 'MODULE' after either line format.
# This has the result of suppressing the suffix of ".build/$configuration" to the libraryPath
# This is appropriate for Modules which don't have a build process, such as CNCURSES
# For example:
# CNCURSES	LOCAL		/home/john-williams/projects/CNCURSES     MODULE
# CNCURSES	0.1.8           MODULE

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

# Find the project root
# We search, in order, for Package.swift, then dylib.manifest, and finally main.swift
projectRoot=""
packagePathname=""
manifestPathname=""
mainPathname=""

packagePathname=$(upfind -name 'Package.swift' -type f 2> /dev/null | head -n 1)
if [[ -f $packagePathname ]]; then
    projectRoot=$(dirname "$packagePathname")
fi

if [[ ! -d $projectRoot ]]; then
    manifestPathname=$(upfind -name 'dylib.manifest' -type f 2> /dev/null | head -n 1)
    if [[ -f $manifestPathname ]]; then
	projectRoot=$(dirname "$manifestPathname")
    fi
fi

if [[ ! -d $projectRoot ]]; then
    mainPathname=$(upfind -name 'main.swift' -type f 2> /dev/null | head -n 1)
    if [[ -f $mainPathname ]]; then
	projectRoot=$(dirname "$mainPathname")
    fi
fi

if [[ ! -d $projectRoot ]]; then
    echo "Unable to determine project root from here"
    exit 1
fi

# At this point, we've determined the project root
# If a manifest is present, it will be located here:
manifestPath="$projectRoot/dylib.manifest"

# Start with a basic command line and empty library path
dylibPaths=""
packageCommandLine="swift $mode -c $configuration"

# For the simple command line (no package) we add the source files
simpleBuildCommandLine="swiftc -o $projectRoot/main"
if [ "$configuration" == "debug" ]; then
    simpleBuildCommandLine="$simpleBuildCommandLine -g"
fi
simpleRunCommandLine="$projectRoot/main"
while ifs= read -r line
do
    simpleBuildCommandLine="$simpleBuildCommandLine $line"
done < <(find "$projectRoot" -name '*.swift')

LD_LIBRARY_PATH=""

# Read the manifest file (if it exists)
if [ -f $manifestPath ]; then
    while read line; do
	if [ ! -z "$line" ]; then
	    # If the line is not empty, it must be in the format specified
	    # The first case is specification of a library found in the MERLIN_LIBRARY_ROOT_DIR
	    # This format specifies only a library name and version
	    # e.g. "Igis 1.0.7"
	    # or   "Igis 1.0.7 MODULE"
	    libraryRegex='^([[:alpha:]]+)[[:space:]]+([[:alnum:]\.]+)[[:space:]]*(MODULE)?$'

	    # An alterntive is specifying a local path which will be used directly
	    # iff the tag is 'LOCAL'
	    # e.g. "Igis LOCAL /home/john-williams/Igis"
	    # or   "Igis LOCAL /home/john-williams/Igis MODULE"
	    localRegex='^([[:alpha:]]+)[[:space:]]+LOCAL[[:space:]]+([[:alnum:]/-]+)[[:space:]]*(MODULE)?$'
	    
	    
	    if [[ "$line" =~ $localRegex ]]; then
		project=${BASH_REMATCH[1]}
		directory=${BASH_REMATCH[2]}
		module=${BASH_REMATCH[3]}

		# The library path is determined by the exact name used for the directory
		libraryPath="$directory"
            elif [[ "$line" =~ $libraryRegex ]]; then
		project=${BASH_REMATCH[1]}
		tag=${BASH_REMATCH[2]}
		module=${BASH_REMATCH[3]}

		# Determine the library path based on the name of the project and tag
		libraryPath="$MERLIN_LIBRARY_ROOT_DIR/$project-$tag/$project"
	    else
		echo "Unexpected line format: $line"
		exit 1
	    fi

	    # If we're not dealing with a module, we need to append the acutal build directory to the path
	    if [[ ! "$module" =~ "MODULE" ]]; then
		libraryPath="$libraryPath/.build/$configuration"
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
	    packageCommandLine="$packageCommandLine -Xswiftc -I -Xswiftc $libraryPath"
	    packageCommandLine="$packageCommandLine -Xswiftc -L -Xswiftc $libraryPath"
	    packageCommandLine="$packageCommandLine -Xswiftc -l$project"

	    simpleBuildCommandLine="$simpleBuildCommandLine -I $libraryPath"
	    simpleBuildCommandLine="$simpleBuildCommandLine -L $libraryPath"
	    simpleBuildCommandLine="$simpleBuildCommandLine -l$project"
	    
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
	if [[ -f $packagePathname ]]; then
	    eval "$packageCommandLine"
	else
	    if [ "$mode" == "run" ]; then
		eval "$simpleBuildCommandLine && $simpleRunCommandLine"
	    else
		eval "$simpleBuildCommandLine"
	    fi
	fi
	
	;;
    list-dylib-paths)
	echo "$dylibPaths"
	;;
    *)
	echo "Unexpected mode $mode"
	exit 1
	;;
esac
