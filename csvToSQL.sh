#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2023 CoderMerlin.Academy
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

# Halt on errors and undefined environment variables
set -eu


# Validate parameters
if [ $# != 3 ]
then
    echo -e "Usage: $0 <csvPathname> <templatePathname> <outputPathname>"
    echo -e "\tThe first line of the csv file MUST contain a comment containing the field names, e.g."
    echo -e "\t\t# name,description,source,target"
    exit 1
fi
csvPathname=$1
templatePathname=$2
outputPathname=$3

if [ ! -f "$csvPathname" ]
then
    echo "The specified csv pathname '${csvPathname}' could not be found."
    exit 2
fi

if [ ! -f "$templatePathname" ]
then
    echo "The specified template pathname '${templatePathname}' could not be found."
    exit 2
fi

rm -f "$outputPathname"

# Read the first line of the csv file to determine variable names for replacement
fieldCount=$(csvstat -n "$csvPathname" | wc -l)
fieldNames=()
for fieldIndex in $(seq 1 $fieldCount)
do
    fieldName=$(head -n 1 "$csvPathname" | sed 's/^#[ \t]*//' | csvcut --skipinitialspace -c $fieldIndex)
    fieldNames+=("$fieldName")
    echo "Field[$fieldIndex] -> $fieldName"
done
echo

# The template file should produce valid SQL after any specified
# environment variables have been replaced
while read -r line
do      
    for fieldIndex in $(seq 0 $((fieldCount-1)) )
    do
	fieldValue=$(echo $line | csvcut --skipinitialspace -c $((fieldIndex+1)) | sed -e 's/^"\(.*\)"$/\1/')
	declare "${fieldNames[$fieldIndex]}=${fieldValue}"
    done
    envsubst < "$templatePathname" | tee --append "$outputPathname"
done < <(tail -n +2 "$csvPathname")
