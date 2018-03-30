Osmo-ABI-Check
==============

This repository contains a set of scripts to build and use abi-* tools to
generate a report in html format containing changes of ABI/API over different
versions of osmocom projects.

There's several big different steps in the procedure for each project that we
want to track:
1- Generate profile .json file. This file contains some meta-data about the
project, as well as a list of versions. The script generate_profile.sh can be
used to generate this profile file from a given git repository. Profile files
are stored in profile/ directory of this repository.
2- Build libraries for a set of versions of a target project (and previously its
required dependencies to be able to compile it properly) and store (prepare) the
output (.so files, headers) in a filesystem structure which abi-* tools can
handle. This output is stored in input/ directory of this repository. This step
is handled by "run_all_project_versions.sh prepare" script.
3- Run abi-* tools to generate the reports. This step is handled by
"run_all_project_versions.sh report" script. It will create all generated
metadata in build/, and final report output is available in deploy/.

As building the whole matrix of elements take an enormous time (project(+deps) *
project_versions), the idea is to keep in git the
build/$project/abi-dump/$non_master/ subdirs to be used as a cache so we don't
need to do the "prepare" step everytime, only for master.

Some details about abi-* tools:
"abi-tracker -t abidump" calls abi-dump and puts the output in build/abi-dump/$project/$version/$lib_hash/{2files here}.
"abi-tracker -t report" uses the files in build/abi-dump/ together with the profile json file to generate a web report.
"abi-tracker -t index generates a general index file containing a list with links to each project report.

Examples:
* Generate profile for libosmo-abis:
./generate_profile libosmo-abis /path/to/existing/git/repo/libosmo-abis.git >profile/libosmo-abis.json

* Build whole list of known versions for project libosmo-abis into input/:
./run_all_project_versions.sh prepare libosmo-abis all

* Build last of known version + master for project libosmo-abis into input/:
./run_all_project_versions.sh prepare libosmo-abis latest

* Build master for master rev of project libosmo-abis into input/:
./run_all_project_versions.sh prepare libosmo-abis master

* Build specific known version 0.4.0 for project libosmo-abis into input/:
./run_all_project_versions.sh prepare libosmo-abis 0.4.0

* Generate report for whole list of known versions for project libosmo-abis into input/:
./run_all_project_versions.sh report libosmo-abis all

* Generate report for known version + master for project libosmo-abis into input/:
./run_all_project_versions.sh report libosmo-abis latest

* Generate report for master rev of project libosmo-abis into input/:
./run_all_project_versions.sh report libosmo-abis master

* Generate report for 0.4.0 for project libosmo-abis into input/:
./run_all_project_versions.sh report libosmo-abis 0.4.0
