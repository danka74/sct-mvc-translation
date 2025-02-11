#!/bin/bash

# argument 1 is the id of the valueset, output translation from MyHealth@EU valueset to Swedish SNOMED CT translation
echo $1

# exit if valueset if begins with #
if [ "${1:0:1}" == "#" ]; then exit 0; fi

# offset iterator
i=0
url="http://34.78.75.225/r5/ValueSet/$1/\$expand?offset=$i&count=300&_format=json"
# fetch valueset from terminology.ehdsi.eu FHIR server, filter out SNOMED CT codes and transform to a string with conceptId=... URL query parameters for the Snowstorm API
codes=$(curl -X 'GET' \
  $url \
  -H 'Accept: application/json' \
jq -r '[.expansion.contains[] | select(.system == "http://snomed.info/sct") | "&conceptIds=" + .code] | join("")' || true )

# remove the first &
codes=${codes:1}

# remove output file
rm -f $1.tsv

# loop to fetch 300 codes per request
# try fetching until concepts from terminology.ehdsi.eu until response is empty
while [ "$codes" != "" ];
do
  url="https://browser.ihtsdotools.org/snowstorm/snomed-ct/MAIN%2FSNOMEDCT-SE/concepts?limit=300&$codes"
  # fetch translations from SNOMED server, transform to TSV (tab-separated) and append to output file
  curl -X 'GET' \
    $url \
    -H 'Accept: application/json' \
    -H 'Accept-Language: sv-X-46011000052107' | \
  jq -r '.items[] | [ .conceptId, .pt.term, .fsn.term ] | @tsv' >> $1.tsv || true

  sleep 20s

  i=$((i+300))
  url="http://34.78.75.225/r5/ValueSet/$1/\$expand?offset=$i&count=300&_format=json"
  # fetch valueset from terminology.ehdsi.eu FHIR server, filter out SNOMED CT codes and transform to a string with conceptId=... URL query parameters for the Snowstorm API
  codes=$(curl -X 'GET' \
    $url \
    -H 'Accept: application/json' \
  jq -r '[.expansion.contains[] | select(.system == "http://snomed.info/sct") | "&conceptIds=" + .code] | join("")' || true )

  # remove the first &
  codes=${codes:1}
done
