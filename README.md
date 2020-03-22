# get-geojson

## Usage

```
$ ./get-geojson.sh -c jp
------------------------------------------------------------------
[state]   (Aichi)
[country] (jp)
[output]  (jp/Aichi.geojson)
[DOWNLOAD] curl -Ss -o jp/Aichi.geojson https://nominatim.openstreetmap.org/search?state=Aichi&country=jp&polygon_geojson=1&format=geojson
------------------------------------------------------------------
[state]   (Akita)
[country] (jp)
[output]  (jp/Akita.geojson)
[SKIP]    (exist) jp/Akita.geojson
------------------------------------------------------------------
:
```

## Requirements

command:

* bash
* curl
* grep
* sed
* awk
* perl


url:

* access to https://raw.githubusercontent.com/olahol/iso-3166-2.json/master/data/eQuest.csv
* access to https://nominatim.openstreetmap.org


## Check environment

* Windows 10 Home 1903
* Git for Windows 2.21.0.windows.1

