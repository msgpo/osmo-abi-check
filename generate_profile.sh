#!/bin/bash

set -e

project=$1
repo=$2

get_version_date() {
        ref=$1
        git -C "$repo" show -s --format=%cd --date=iso "$ref^{commit}" | awk '{print $1}'
}

if [ "$#" != "2" ]; then
        echo "example: generate_profile.sh libosmocore /tmp/libosmocore.git"
        exit 1
fi

first=1

echo -n "
{
  \"Name\":           \"$project\",
  \"Title\":          \"$project\",
  \"SourceUrl\":      \"https://git.osmocom.org/$project/\",
  \"Git\":            \"git://git.osmocom.org/$project\",
  \"Maintainer\":     \"Pau Espin Pedrol\",
  \"MaintainerUrl\":  \"http://pespin.espeweb.net/~pespin/tmp/osmocom/\",

  \"Versions\": [
          {
            \"Number\":         \"master\",
            \"Installed\":      \"../input/$project/master\",
            \"Date\":           \"$(get_version_date origin/master)\",
            \"HeadersDiff\":    \"Off\",
            \"PkgDiff\":        \"Off\",
            \"ABIView\":        \"Off\",
            \"ABIDiff\":        \"Off\"
          }"

for myv in $(./print_releases.sh $repo desc); do
        echo -n ", {
            \"Number\":         \"$myv\",
            \"Installed\":      \"../input/$project/$myv\",
            \"Date\":           \"$(get_version_date $myv)\",
            \"HeadersDiff\":    \"Off\",
            \"PkgDiff\":        \"Off\",
            \"ABIView\":        \"Off\",
            \"ABIDiff\":        \"Off\"
        }"
done

echo "
  ]
}
"
