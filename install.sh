#!/bin/bash
set -eu

# Installs these scripts into $targetDirectory
targetDirectory=/usr/local/bin

cp build.sh                "$targetDirectory/build"
cp dylib.sh                "$targetDirectory/dylib"
cp dylibEmacs.sh           "$targetDirectory/dylibEmacs"
cp dylibLoader.sh          "$targetDirectory/dylibLoader"
cp makeSwift.sh            "$targetDirectory/makeSwift"
cp swift-init.sh           "$targetDirectory/swift-init"
cp swift-run.sh            "$targetDirectory/swift-run"
cp java-init.sh            "$targetDirectory/java-init"
cp run.sh                  "$targetDirectory/run"
cp upfind.sh               "$targetDirectory/upfind"
cp warnIfAlreadyRunning.sh "$targetDirectory/warnIfAlreadyRunning"
cp deployMerlinLibrary.sh  "$targetDirectory/deployMerlinLibrary"
cp lockMerlinLibrary.sh    "$targetDirectory/lockMerlinLibrary"
cp skel-init.sh            "$targetDirectory/skel-init"
cp merlin-clean.sh         "$targetDirectory/merlin-clean"
cp swift-clean.sh          "$targetDirectory/swift-clean"
cp make-swift-doc.sh       "$targetDirectory/make-swift-doc"

# Install utility files
cp www-check-perms.sh      "$targetDirectory/www-check-perms"
cp csvToSQL.sh             "$targetDirectory/csvToSQL"

# Installs required support files
cp SimpleSwiftMake.sh  "$targetDirectory/SimpleSwiftMake.sh"
cp SimplePackage.swift "$targetDirectory/SimplePackage.swift"

cp SimpleJavaMake.sh  "$targetDirectory/SimpleJavaMake.sh"
cp SimpleJavaRun.sh  "$targetDirectory/SimpleJavaRun.sh"
