#!/bin/bash
set -eu

# Installs these scripts into /usr/local/bin
cp build.sh /usr/local/bin/build
cp dylib.sh /usr/local/bin/dylib
cp dylibEmacs.sh /usr/local/bin/dylibEmacs
cp makeSwift.sh /usr/local/bin/makeSwift
cp makeSwiftMake.sh /usr/local/bin/makeSwiftMake
cp run.sh /usr/local/bin/run
cp upfind.sh /usr/local/bin/upfind
cp warnIfAlreadyRunning.sh /usr/local/bin/warnIfAlreadyRunning
cp deployMerlinLibrary.sh /usr/local/bin/deployMerlinLibrary
cp lockMerlinLibrary.sh /usr/local/bin/lockMerlinLibrary
