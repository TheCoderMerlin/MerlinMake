#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020,2021,2022,2023 CoderMerlin.Academy
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

# Prints the last three characters of the first line of the /etc/flowstate file
# iff it matches the provided argument, e.g. "prd" or "stg"
# Example usage: flowstate prd
# This is useful for screen status

# Halt on errors and undefined environment variables
set -eu

# Validate parameters
if [ $# != 1 ]
then
    echo -e "Usage: $0 <targetFlowstate>"
    exit 1
fi
targetFlowstate=$1

echo "$([ "$(flowstate)" = "$targetFlowstate" ] && echo "$targetFlowstate")"

