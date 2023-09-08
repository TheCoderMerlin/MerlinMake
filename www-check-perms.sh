#!/bin/bash
set -e

normalText="\e[0m"
blackText="\e[30m"
cyanText="\e[36m" 

lightRedText="\e[91m"
lightGreenText="\e[92m"
lightYellowText="\e[93m"

greenBackground="\e[42m"
yellowBackground="\e[43m"
redBackground="\e[41m"

function display_status {
    pathname="$1"
    expectedLinkTarget="$2"

    if [ ! -e "$pathname" ]
    then
	echo -e "❌ $pathname: \n\t${lightYellowText}Does not exist or has insufficient permissions.${normalText}."
	return
    fi
    

    pathStat=$(stat --format "%A" "$pathname")
    fileType=$(echo "$pathStat" | cut -c1)
    ownerPermissions=$(echo "$pathStat" | cut -c2-4)
    groupPermissions=$(echo "$pathStat" | cut -c5-7)
    otherPermissions=$(echo "$pathStat" | cut -c8-10)

    otherRead=$(echo "$otherPermissions" | cut -c1)
    otherWrite=$(echo "$otherPermissions" | cut -c2)
    otherExecute=$(echo "$otherPermissions" | cut -c3)

    if [ "$fileType" == "d" ]
    then
	if [ "$otherExecute" == "x" ]
	then
	   echo -e "✅ $pathname: Directory is traversable by others."
	else
	   echo -e "❌ $pathname: Directory must be traversable by others.\n\tExecute:  ${lightYellowText}chmod a+x \"$pathname\"${normalText}" 
	fi
    elif [ "$fileType" == "-" ]
    then
	if [ "$otherRead" == "r" ]
	then
	   echo -e "✅ $pathname: File is readable by others."
	else
	   echo -e "❌ $pathname: File must be readable by others.\n\tExecute:  ${lightYellowText}chmod a+r \"$pathname\"${normalText}"
	fi
    elif [ "$fileType" == "l" ]
    then
	resolvedPathname=$(readlink -f "$pathname")
	if [ "$resolvedPathname" == "$expectedLinkTarget" ]
	then
	    echo -e "✅ $pathname: Link exists and targets $resolvedPathname as expected."
	else
	   echo -e "❌ $pathname:\n\t${lightYellowText}Link exists but does not target expected target ($expectedLinkTarget).${normalText}"
	fi
    fi
}

# Check standard links
display_status "$HOME/www"
display_status "$HOME/Digital Portfolio"
display_status "$HOME/www/Digital Portfolio" "$HOME/Digital Portfolio"

# Check path trail to root
currentDirectory="$(pwd)"
while [[ "$currentDirectory" != "/" ]]
do
    if [ "$currentDirectory" == "$HOME/www/Digital Portfolio" ]
    then
	display_status "$currentDirectory" "$HOME/Digital Portfolio"
    else
	display_status "$currentDirectory"
    fi
    
    currentDirectory=$(dirname "$currentDirectory")
done

# Check all relevant files in current directory
for file in *.{html,css,js}
do
    if [[ -f "$file" ]]
    then
	display_status "$file"
    fi
done

