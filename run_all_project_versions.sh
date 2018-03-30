#!/bin/bash
action=${1:-all}
projects_defaults="libosmocore libosmo-abis libosmo-netif libosmo-sccp libasn1c libsmpp34 osmo-iuh osmo-ggsn osmo-mgw"
PROJECTS="${2:-$projects_defaults}"
if [ "x$PROJECTS" = "x" ]; then PROJECTS="$projects_defaults"; fi
versions="${3:-latest}"

REPO_PREFIX="${REPO_PREFIX:-/tmp/}"

run_repo() {
        local action=$1
        local project=$2
        local project_underscore="$(echo $project | sed "s/-/_/g")"
        local versions=$3
        local vs="$3"
        if [ "$versions" = "latest" ]; then
                vs="$(./print_releases.sh $REPO_PREFIX/$project asc | awk '{print $NF}')"
        elif [ "$versions" = "all" ]; then
                vs="$(./print_releases.sh $REPO_PREFIX/$project asc)"
        fi
        # Prepare all project versions
        for v in $vs; do
                version_var="VERSION_${project_underscore}"
                export $version_var=$v
                echo "$action version $v for $project"
                ./generate_reports.sh $project $action
        done
}

for p in $PROJECTS; do
        if [ "$action" = "prepare" ] || [ "$action" = "all" ]; then
                run_repo prepare $p $versions
        fi
        if [ "$action" = "report" ] || [ "$action" = "all" ]; then
                run_repo report $p $versions
        fi
done
