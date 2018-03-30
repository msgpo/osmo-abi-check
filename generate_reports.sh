#!/bin/bash

set -e

. ./libs_track.sh.inc

#rm -rf deps
#./build_osmocom_libs.sh

base="$PWD"
deps="$base/deps"
inst="$deps/install"
profiles="$base/profiles"
build="$base/build"
deploy="$base/deploy"

#rm -rf "$deploy"

project=${1:-libosmocore}
action=${2:-report}

if [ "$action" != "prepare" ] && [ "$action" != "report" ]; then
        echo "Non supported action"
        exit 1
fi


generate_input_ext() {
        project="$1"
        version="$2"
        project_underscore="$(echo $project | sed "s/-/_/g")"
        input="$base/input/$project/$version" # this is the format used in profile files
        mkdir -p "$input"
        #abi-tracker expects to find files, not symlinks:
        libs_var="LIBRARIES_${project_underscore}"
        libs="${!libs_var}"
        for f in $libs; do
                orig="$(readlink -f $inst/lib/$f.so)"
                cp -v $orig "$input/$(basename $orig)"
        done

        #abi-tracker looks for headers under Installed. Again, it doesn't support symlinks.
        cp -rL $(readlink -f "$inst/include")  "$input/include"
}

generate_abi_dump_ext() {
        project="$1"
        version="$2"
        echo "Generating report for $project $version ($profiles/$project.json)"
        mkdir -p "$build" "$deploy"
        pushd "$build"
        abi-tracker -rebuild -t abidump -deploy "$deploy" -v "$version" "$profiles/$project.json"
        abi-tracker -rebuild -t abireport -deploy "$deploy" -v "$version" "$profiles/$project.json"
        abi-tracker -rebuild -global-index -t date -deploy "$deploy" -v "$version" "$profiles/$project.json"
        cp "$build/index.html" "$deploy/index.html"
        popd
}

generate_input() {
        project="$1"
        project_underscore="$(echo $project | sed "s/-/_/g")"
        version_var="VERSION_${project_underscore}"
        version="${!version_var}"
        generate_input_ext "$project" "$version"
}

generate_abi_dump() {
        project="$1"
        project_underscore="$(echo $project | sed "s/-/_/g")"
        version_var="VERSION_${project_underscore}"
        version="${!version_var}"
        generate_abi_dump_ext "$project" "$version"
}

if [ "$action" == "prepare" ]; then
        ./build_osmocom_libs.sh $project
        generate_input $project
elif [ "$action" == "report" ]; then
        generate_abi_dump $project
fi
