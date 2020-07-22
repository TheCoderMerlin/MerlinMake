#!/bin/bash
# This script will re-initialize the user's home directory to defaults
# Provides a warning before beginning
set -eu

read -p "This will RESET your configuration to the default, erasing customizations.  Type 'Merlin' to continue. " verify
if [ "$verify" == "Merlin" ]
then
    pushd $HOME > /dev/null
    echo "Removing emacs configuration..."
    rm -f .emacs
    rm -rf .emacs.d

    echo "Removing bash configuration..."
    rm -f .bash_aliases
    rm -f .bashrc
    rm -f .bash_logout
    rm -f .profile

    echo "Restoring default configuration..."
    cp -r /etc/skel/. .

    echo "Done"
    popd > /dev/null
else
    echo "Phrase was not verified; no action taken."
fi


