#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2020 Tango Golf Digital, LLC
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

# This script searches upwards from the current directory looking for the
# first run.sh file found.  If found, executes that file passing any
# specified parameters.
# If not found, searches upwards from the current directory looking for the
# first make.sh file found.  If found, executes that file passing any
# specified parameters, after inserting --mode=run.
runPath=$(upfind -name 'run.sh' -executable 2> /dev/null | head -n 1)
if [[ -f $runPath ]]; then
    runCommandLine="$runPath $@"
    eval $runCommandLine
else
    makePath=$(upfind -name 'make.sh' -executable 2> /dev/null | head -n 1)
    if [[ -f $makePath ]]; then
	makeCommandLine="$makePath --mode=run $@"
	eval $makeCommandLine
    else
	echo "neither run.sh nor make.sh were found from here"
	exit 1
    fi
fi
