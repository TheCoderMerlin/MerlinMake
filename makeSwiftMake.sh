#!/bin/bash
# This script is part of the MerlinMake repository
# Copyright (C) 2018,2019,2020 Tango Golf Digital, LLC
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

# This script simply creates a make.sh file in the current directory
# which invokes the standard makeSwift script.
if [[ -f "make.sh" ]]; then
    echo "make.sh already exists here"
    exit 1
else
    echo "#!/bin/bash" >> make.sh
    echo "makeSwift \"\$@\"" >> make.sh
    chmod a+x make.sh
fi
