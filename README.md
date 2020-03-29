# get-geojson

Get subdivision geojson.

## Example

```
C:\get-geojson>powershell -ExecutionPolicy RemoteSigned ./get-geojson.ps1 -c dk -o C:\Output\Dir
[CountryCode]        dk
[CountryCodeUppered] DK
[DryRunFlag]         False
[mkdir] C:\Output\Dir
[Download] https://raw.githubusercontent.com/olahol/iso-3166-2.js/master/data.csv

==== [1/5] DK-81 (Nordjylland) @ Denmark ====
[GET] 1st try: https://nominatim.openstreetmap.org/search?state=Nordjylland&country=DK&polygon_geojson=1&format=geojson => C:\Output\Dir/DK-81.geojson (847100 byte)

==== [2/5] DK-82 (Midtjylland) @ Denmark ====
[GET] 1st try: https://nominatim.openstreetmap.org/search?state=Midtjylland&country=DK&polygon_geojson=1&format=geojson => C:\Output\Dir/DK-82.geojson (918352 byte)
   :
```

## Options

* `-c <country code>` ... Required option. Set country code (ISO 316601 alpha-2).  Refere to https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 . This script GET https://raw.githubusercontent.com/olahol/iso-3166-2.js/master/data.csv .
* `-d` ... Enable DRY RUN. It means do not download geojson.
* `-o <output dir>` ... Set download directory. It includes geojson and iso-3166-2.csv.

## Specs

This script download geojson from https://nominatim.openstreetmap.org .
If geojson file have `features:[(empty)]` field, it means it cannot find area region data.

## Requirements

Environment:
* PowerShell

Access:
* access to https://raw.githubusercontent.com/olahol/iso-3166-2.js/master/data.csv
* access to https://nominatim.openstreetmap.org


## Checked environment

* Windows 10 Home 1909
* PowerShell 5.1

```
PS> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      5.1.18362.628
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.18362.628
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
```
