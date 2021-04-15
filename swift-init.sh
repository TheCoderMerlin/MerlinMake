#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020 CoderMerlin.com
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

# This script simply creates a make.sh file and Package.swift
# in the current directory (after verifying that they don't yet exist
# using upfind)
set -eu

scriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
makePath=$(upfind -name 'make.sh' -executable 2> /dev/null | head -n 1)
packagePath=$(upfind -name 'Package.swift' 2> /dev/null | head -n 1)
if [[ -f $makePath ]]
then
    echo "make.sh already exists: $makePath"
    exit 1
elif [[ -f $packagePath ]]
then
    echo "Package.swift already exists: $packagePath"
    exit 1
else
    cp "$scriptDirectory/SimplePackage.swift" "./Package.swift"
    cp "$scriptDirectory/SimpleSwiftMake.sh" "./make.sh"
    echo "Done"
fi
