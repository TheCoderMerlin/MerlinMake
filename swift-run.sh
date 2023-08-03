#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2023 CoderMerlin.academy
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
set -eu

# Rather than check for updates and the need to recompile,
# we simply find the existing executable and run it
# This also avoids issues when attempting to use "swift run"
# in a different directory from that in which the project was built,
# e.g. "PCH was compiled with module cache path..."
cd "$(swift build --show-bin-path)"
./"$(find . -executable -type f)"


