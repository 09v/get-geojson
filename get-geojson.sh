#!/bin/bash
curl https://raw.githubusercontent.com/olahol/iso-3166-2.json/master/data/eQuest.csv | grep JP- | awk -F, '{print $4}' | sed "s/.*\[//g" | sed "s/\]//g" | while read  line; do echo "[$line]"; sleep 1; done
