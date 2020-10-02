#!/bin/bash

# Try to find one file which contains the main() function
# public static void main(...)
filesContainingMain=$(grep -E -l "public[[:space:]]+static[[:space:]]+void[[:space:]]+main[[:space:]]*\(.+\)" *.java)


# Ensure that we found only one file
fileCount=$(echo $filesContainingMain | wc --words)
if [ $fileCount -gt 1 ]
then
    echo "Too many files have a main() function.  Please create the run.sh file manually."
    exit 1
fi
if [ $fileCount -eq 0 ]
then
    echo "No files have a main() function.  Please create the run.sh file manually."
    exit 1
fi

# Drop the suffix
fileBasename=$(basename --suffix=.java $filesContainingMain)

# Run
java $fileBasename

