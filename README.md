# MerlinMake
A collection of utility scripts for making Merlin projects

This is a suite of small utility scripts that enable one to quickly compile and execute Swift projects, especially those that require linking to dynamic libraries.  It's able to compile and execute Swift projects that use Packages (those with a **Package.swift** file) as well as those that are simply a collection of **.swift** files.

## Usage
### Setup
The first step in using these utilities involves creating a **make.sh** file in the root of the project.  To do so, enter the root directory of the project and execute:
```bash
makeSwiftMake
```
NOTE:  This file is usually included in Merlin projects from GitHub.  If a **make.sh** file already exists for the project, there's no need to execute this command.
### Build
After **make.sh** has been created the project may be built using:
```bash
build
```

### Run
After **make.sh** has been created the project may be executed using:
```bash
run
```

### Dynamic Libraries
If any dynamic libraries are required, simply create a file named **dylib.manifest**.  This file must contain one line for each dynamic library required.  There are two options for each line.  For standard, server-supplied libraries, use the format:
```bash
<projectName> <version>
```
For example:
```bash
Igis      1.1.2
Scenes    0.1.8
```

If you are developing your own library, use the format:
```bash
<projectName> LOCAL <path>
```
For example:
```bash
Igis      LOCAL   /home/john-williams/projects/Igis 
```

In order to view the dynamic library paths used for a project, execute:
```bash
dylib
```
