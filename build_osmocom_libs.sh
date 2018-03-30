#!/usr/bin/env bash

# TODO: have a per project deps variable which lists which projects need to be
# built. then have a function to build each dep.

. ./libs_track.sh.inc

final_project=${1:-none}

if ! [ -x "$(command -v osmo-build-dep.sh)" ]; then
	echo "Error: We need to have scripts/osmo-deps.sh from http://git.osmocom.org/osmo-ci/ in PATH !"
	exit 2
fi

set -ex

build_dep_and_stop() {
	local project="$1"
	local version="$2"
	local configure_opt="$3"
	echo " =============================== $project $version (for $final_project)===================="
	osmo-build-dep.sh $project "$version" "$configure_opt"
	if [ "x$final_project" = "x$project" ]; then exit 0; fi
}

base="$PWD"
deps="$base/deps"
inst="$deps/install"
export deps inst

#osmo-clean-workspace.sh

mkdir "$deps" || true

export PKG_CONFIG_PATH="$inst/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$inst/lib"

export CFLAGS="$CFLAGS -g -Og"
export CPPFLAGS="$CPPFLAGS -g -Og"

echo " =============================== libosmocore ============================="
build_dep_and_stop libosmocore "$VERSION_libosmocore" "--disable-doxygen"

echo " =============================== libosmo-abis ============================"
build_dep_and_stop libosmo-abis "$VERSION_libosmo_abis" "--disable-doxygen"

echo " =============================== libosmo-netif ==========================="
build_dep_and_stop libosmo-netif "$VERSION_libosmo_netif" "--disable-doxygen"

echo " =============================== libosmo-sccp ============================"
build_dep_and_stop libosmo-sccp "$VERSION_libosmo_sccp" ""

echo " =============================== libsmpp34 ==============================="
build_dep_and_stop libsmpp34 "$VERSION_libsmpp34" ""

echo " =============================== osmo-mgw ================================"
build_dep_and_stop osmo-mgw "$VERSION_osmo_mgw" ""

echo " =============================== libasn1c ==============================="
build_dep_and_stop libasn1c "$VERSION_libasn1c" ""

echo " =============================== osmo-iuh ==============================="
build_dep_and_stop osmo-iuh "$VERSION_osmo_iuh" ""

echo " =============================== osmo-ggsn ==============================="
build_dep_and_stop osmo-ggsn "$VERSION_osmo_ggsn" ""

#osmo-clean-workspace.sh
