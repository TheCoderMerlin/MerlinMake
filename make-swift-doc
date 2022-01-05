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

# Builds documentation for a swift project, placing in the user's www directory
set -eu

# Variables
sourceKittenPathname=$(mktemp /tmp/sourceKitten_XXXXXXXXXXXX)
projectName=$(basename $PWD)
rootURL=https://www.codermerlin.com/users/$USER/swift-doc/$projectName
documentationDirectory=/home/$USER/www/swift-doc
outputPathname=$documentationDirectory/$projectName

# Code
echo "Generating reference files..."
sourcekitten doc --spm > "$sourceKittenPathname"

echo "Writing files to $outputPathname..."
jazzy -s "$sourceKittenPathname" --root-url "$rootURL" --output "$outputPathname"

echo "Setting permissions for $documentationDirectory"
chmod -R a+rX "$documentationDirectory"

echo "Cleaning up..."
rm $sourceKittenPathname

echo "done"

echo "Documentation is now available at: $rootURL/index.html"


