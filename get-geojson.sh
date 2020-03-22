#!/bin/bash

# -----------------------------------------------------------------------------
# legend:
# * global ... gXXX
# * const  ... kXXX

# -----------------------------------------------------------------------------
# parse option ...
usage_exit() {
  echo "Usage: $0 [-d] [-c country_code]" >&2
  exit
}
kDoDryRun=1
gDryRunFlag=0
kInvalidCountryCode="Invalid Country Code"
country_code=$kInvalidCountryCode
while getopts dc:h OPT
do
  case $OPT in
    c) country_code=$OPTARG # ISO 3166-1alpha2
      ;;
    d) gDryRunFlag=$kDoDryRun
      ;;
    h) usage_exit
      ;;
    \?)
      usage_exit
  esac
done
if [ "$country_code" = "$kInvalidCountryCode" ]; then
  echo "[ERROR] -c option is required." >&2
  usage_exit
fi

# -----------------------------------------------------------------------------
# TODO: $country_code validation
getGeojsonImpl() {
  region_code=$1
  state=$2
  country=$3
  output="${country}/${region_code}.geojson"
  escaped_state=`perl -MURI::Escape -e "print uri_escape '${state}'"`
  echo "------------------------------------------------------------------"
  echo "[state]         (${state})"
  echo "[escaped_state] ($escaped_state)"
  echo "[country]       (${country})"
  echo "[region_code]   (${region_code})"
  echo "[output]        (${output})"
  mkdir -p ${country}

  # 1st try [state=xxxx&country=YY]
  # 2nd try [q=xxxx+YY]

  url="https://nominatim.openstreetmap.org/search?state=${escaped_state}&country=${country}&polygon_geojson=1&format=geojson"
  cmd="curl -Ss -o $output $url"
  if [ $gDryRunFlag -eq $kDoDryRun ]; then
    echo "[DRY RUN]       $cmd"
  elif [ -e $output ]; then
    echo "[SKIP] (exist)  ($output)"
  else
    echo "[DOWNLOAD]      $cmd"
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
getGeojson() {
  country_code=$1
  cat eQuest.csv | grep -i ${country_code}- | awk -F, '{print $2, "@", $4}' | sed "s/.*\[//g" | sed "s/\]//g" > _tmp.csv
  country=$1
  cat _tmp.csv | while IFS=" @ " read key value; do
    getGeojsonImpl $key "$value" $country
  done
}

# -----------------------------------------------------------------------------
main() {
  getEQuestCsv
  # cat eQuest.csv | grep -i ${country_code}- | awk -F, '{print $2,$4}' | sed "s/.*\[//g" | sed "s/\]//g" | while read line; do getGeojson "$line" $country_code; done
  getGeojson $country_code
}

main

