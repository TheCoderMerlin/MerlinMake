#!/bin/bash
# This script is part of the MerlinMake repository
# Reference: https://superuser.com/questions/455723/is-there-an-upwards-find
# Finds a particular path by searching up through a hierarchy
# Example usage: upfind -name 'make.sh'
# Note that because error messages will also be reported (for example, 'permission denied')
# if using this from a script one option is to examine only the first line returned
# and then verify the path to see if it exists
while [[ $PWD != / ]] ; do
    find "$PWD"/ -maxdepth 1 "$@"
    cd ..
done
