#!/bin/bash

# Locks a standard Merlin library so that sources are not visible to non-owners
# Usage ./deployMerlinLibrary.sh <projectName> <tag>
# Example: ./deployMerlinLibrary.sh Igis 1.0.2

# Environment
# Requires: MERLIN_LIBRARY_ROOT_DIR (e.g. /usr/local/lib/merlin)
[ -z "$MERLIN_LIBRARY_ROOT_DIR" ] && { echo "MERLIN_LIBRARY_ROOT_DIR must be defined"; exit 1; }

# Gather arguments
if [ "$#" -ne 2 ]; then
    echo "You must enter exactly 2 command line arguments"
    echo -e "\tprojectName"
    echo -e "\ttag"
    exit 1
fi
projectName=$1
tag=$2

# Move to target directory
targetDir="$MERLIN_LIBRARY_ROOT_DIR/$projectName-$tag"
echo "Entering target directory $targetDir"
pushd "$targetDir" || { echo "Failed to move to target directory $targetDir"; exit 1; }

# Move into the repository
repositoryDir="$targetDir/$projectName"
echo "Entering directory $repositoryDir"
pushd "$repositoryDir" || { echo "Failed to move to project directory $repositoryDir"; exit 1; }

# Adjust permissions for Sources and Tests
echo "Adjusting permissions on Sources and Tests"
chmod -R o-rX Sources || { echo "Failed to adjust permissions on directory Sources"; exit 1; }
chmod -R o-rX Tests   || { echo "Failed to adjust permissions on directory Tests"; exit 1; }

# Return to original directory
popd 
popd

