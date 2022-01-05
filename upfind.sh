#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020,2021,2022 CoderMerlin.com
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
