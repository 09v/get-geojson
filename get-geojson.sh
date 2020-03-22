#!/bin/bash

usage_exit() {
  echo "Usage: $0 [-d] [-c country_code]" 1>&2
  exit
}

DoDryRun=1
dry_run_flag=0
while getopts dc:h OPT
do
  case $OPT in
    c) country_code=$OPTARG # ISO 3166-1alpha2
      ;;
    d) dry_run_flag=$DoDryRun
      ;;
    h) usage_exit
      ;;
    \?)
      usage_exit
  esac
done

# TODO: $country_code validation

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
  cmd="curl -Ss -o $output $url"
  if [ $dry_run_flag -eq $DoDryRun ]; then
    echo "[SKIP]    (do dry run) $cmd"
  elif [ -e $output ]; then
    echo "[SKIP]    (exist) $output"
  else
    echo "[DOWNLOAD] $cmd"
    $cmd

    # **Requirements** https://operations.osmfoundation.org/policies/nominatim/
    # No heavy uses (an absolute maximum of 1 request per second).
    sleep 2
  fi
}

# -----------------------------------------------------------------------------
getEQuestCsv() {
  # eQuest.csv sample
  # ----------------------
  #  :
  # KI,,,Kiribati
  # ,KI-G,,Gilbert Islands
  # ,KI-L,,Line Islands
  # ,KI-P,,Phoenix Islands
  #  :
  # JP,,,Japan
  # ,JP-23,,Aiti [Aichi]
  # ,JP-05,,Akita
  output=eQuest.csv
  if [ -e $output ]; then
    echo "[SKIP]  (exist) $output"
  else
    cmd="curl -Ss -o $output https://raw.githubusercontent.com/olahol/iso-3166-2.json/master/data/eQuest.csv"
    echo "[DOWNLOAD] $cmd"
    $cmd
  fi

  if [ $? -ne 0 ]; then
    echo "[ERROR] getEQuestCsv ..." >&2
    exit 1
  fi
}

# -----------------------------------------------------------------------------
main() {
  getEQuestCsv
  echo $?
  cat eQuest.csv | grep -i ${country_code}- | awk -F, '{print $4}' | sed "s/.*\[//g" | sed "s/\]//g" | while read line; do getGeojson "$line" $country_code; done
}

main

