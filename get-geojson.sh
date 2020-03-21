#!/bin/bash

usage_exit() {
  echo "Usage: $0 [-c country_code]" 1>&2
  exit
}

while getopts c:h OPT
do
  case $OPT in
    c) country_code=$OPTARG # ISO 3166-1alpha2
      ;;
    h) usage_exit
      ;;
    \?)
      usage_exit
  esac
done

getGeojson() {
  state=$1
  country=$2
  output=${country}/${state}.geojson
  echo "------------------------------------------------------------------"
  echo "[state]   (${state})"
  echo "[country] (${country})"
  echo "[output]  (${output})"
  mkdir -p ${country}

  url="https://nominatim.openstreetmap.org/search?state=${state}&country=${country}&polygon_geojson=1&format=geojson"
  cmd="curl -o $output $url"
  echo $cmd
  $cmd

  # **Requirements** https://operations.osmfoundation.org/policies/nominatim/
  # No heavy uses (an absolute maximum of 1 request per second).
  sleep 2
}

curl https://raw.githubusercontent.com/olahol/iso-3166-2.json/master/data/eQuest.csv | grep -i ${country_code}- | awk -F, '{print $4}' | sed "s/.*\[//g" | sed "s/\]//g" | while read line; do getGeojson $line $country_code; done

