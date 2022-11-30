#!/bin/bash

# Deploys a standard Merlin library
# Usage ./deployMerlinLibrary.sh <repositoryRootURL>  <projectName> <tag>
# tag may be either a specific tag (e.g. 1.0.0 or HEAD)
# If HEAD is specified, the tag used will be determined by the most recent commit
# Example: ./deployMerlinLibrary.sh https://github.com/TheCoderMerlin Igis 1.0.2

# Environment
# Requires: MERLIN_LIBRARY_ROOT_DIR (e.g. /usr/local/lib/merlin)
[ -z "$MERLIN_LIBRARY_ROOT_DIR" ] && { echo "MERLIN_LIBRARY_ROOT_DIR must be defined"; exit 1; }

# Gather arguments
if [ "$#" -ne 3 ]; then
    echo "You must enter exactly 3 command line arguments"
    echo -e "\trepositoryRootURL"
    echo -e "\tprojectName"
    echo -e "\ttag"
    exit 1
fi
repositoryRootURL=$1
projectName=$2
tag=$3

# Remove and recreate target directory
targetDir="$MERLIN_LIBRARY_ROOT_DIR/$projectName-$tag"
echo "Recreating $targetDir"
if [ -d "$targetDir" ]; then
    rm -rf "$targetDir" || { echo "Failed to remove target directory $targetDir"; exit 1; }
fi
mkdir "$targetDir" || { echo "Failed to create target directory $targetDir"; exit 1; }

# Move to target directory
echo "Entering target directory $targetDir"
pushd "$targetDir" || { echo "Failed to move to target directory $targetDir"; exit 1; }

# Clone the repository
git clone --recursive "$repositoryRootURL/$projectName"  || { echo "Failed to clone repostitory $repositoryRootURL/$projectName"; exit 1; }

# Move into the repository
echo "Entering directory $projectName"
pushd "$projectName" || { echo "Failed to move to project directory $projectName"; exit 1; }

# Checkout specified tag
echo "Checking out $tag"
git checkout -q "$tag" || { echo "Failed to checkout tag $tag"; exit 1; }

# Build both the debug and release versions
echo "Building debug"
build --configuration=debug || { echo "Failed to build debug version"; exit 1; }

echo "Building release"
build --configuration=release || { echo "Failed to build release version"; exit 1; }

# Adjust permissions
echo "Adjusting permissions on $targetDir"
chmod -R a+rX "$targetDir" || { echo "Failed to adjust permissions on directory $targetDir"; exit 1; }

# Add path to list of merlin library paths
echo "Adding path to list of melin libraries"
merlinLibraryListPathname="/etc/profile.d/52-merlin.sh"
echo "export MERLIN_LIBRARY_PATH_$projectName=$targetDir/$projectName" >> "$merlinLibraryListPathname"

# Return to original directory
popd 
popd






