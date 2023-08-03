#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2021 CoderMerlin.com
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

# This script searches through all directories from the home directory
# and recursively removes and .build directory
find ~ -type d -name .build -print -exec rm -rf "{}" \;
