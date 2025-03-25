#!/bin/bash

rm -f icd-11-allergens.tsv

desc=$(curl -sS -X 'GET' \
  'https://id.who.int/icd/entity/1991139272?releaseId=2024-01&include=descendant' \
  -H 'accept: application/json' \
  -H 'API-Version: v2' \
  -H 'Accept-Language: en' \
  -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE3MzgyNTU0ODMsImV4cCI6MTczODI1OTA4MywiaXNzIjoiaHR0cHM6Ly9pY2RhY2Nlc3NtYW5hZ2VtZW50Lndoby5pbnQiLCJhdWQiOlsiaHR0cHM6Ly9pY2RhY2Nlc3NtYW5hZ2VtZW50Lndoby5pbnQvcmVzb3VyY2VzIiwiaWNkYXBpIl0sImNsaWVudF9pZCI6ImE1MzY4MWFkLTNjYmQtNDQzMy1hY2U3LTVlYjYyOTU0MmVmN185NTlhYWFjMS0yNDU1LTQ2NDItYjVkYS1kYjkxNTM0NTA0Y2UiLCJzY29wZSI6WyJpY2RhcGlfYWNjZXNzIl19.H0FI2_1GY3WpS7P9SQlOCWHjhc31Nf7xa6ajLExygCawZtbDAaunq6se2wdl9Gi7QcgD1vZtBox1_XVZNupbS-Cmmu51CTSVuth0awEEb-EzI0QekyYUFYBDqaKb5qWXt5y-G3Orw2xjGcTalL9Zw5F_vPCG44Yh5UhcGgtkKLgIX-ReKGI1OEf9qjnKusIrMTYx1uOqkFeRm8vcs8zydtn_16x0FRmQAnyvejZ_mrFLvIDNC7-KbVpINcMsMvmQ1tifKfth1UeghPQG8jL-ztbh_S0Hui97LTgtVCpR0k7vtc1TyVR-DzJh_C8Tj37NBbBie37ovipAlJjzbx_M3A' |
jq -r '.descendant[] | [.] | @tsv')

for c in $desc
do
    sleep 5s
    id=$(basename $c)

    url="https://id.who.int/icd/entity/${id}?releaseId=2024-01"
    echo $url

    concept=$(curl -sS -X 'GET' \
        $url \
        -H 'accept: application/json' \
        -H 'API-Version: v2' \
        -H 'Accept-Language: en' \
        -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE3MzgyNTU0ODMsImV4cCI6MTczODI1OTA4MywiaXNzIjoiaHR0cHM6Ly9pY2RhY2Nlc3NtYW5hZ2VtZW50Lndoby5pbnQiLCJhdWQiOlsiaHR0cHM6Ly9pY2RhY2Nlc3NtYW5hZ2VtZW50Lndoby5pbnQvcmVzb3VyY2VzIiwiaWNkYXBpIl0sImNsaWVudF9pZCI6ImE1MzY4MWFkLTNjYmQtNDQzMy1hY2U3LTVlYjYyOTU0MmVmN185NTlhYWFjMS0yNDU1LTQ2NDItYjVkYS1kYjkxNTM0NTA0Y2UiLCJzY29wZSI6WyJpY2RhcGlfYWNjZXNzIl19.H0FI2_1GY3WpS7P9SQlOCWHjhc31Nf7xa6ajLExygCawZtbDAaunq6se2wdl9Gi7QcgD1vZtBox1_XVZNupbS-Cmmu51CTSVuth0awEEb-EzI0QekyYUFYBDqaKb5qWXt5y-G3Orw2xjGcTalL9Zw5F_vPCG44Yh5UhcGgtkKLgIX-ReKGI1OEf9qjnKusIrMTYx1uOqkFeRm8vcs8zydtn_16x0FRmQAnyvejZ_mrFLvIDNC7-KbVpINcMsMvmQ1tifKfth1UeghPQG8jL-ztbh_S0Hui97LTgtVCpR0k7vtc1TyVR-DzJh_C8Tj37NBbBie37ovipAlJjzbx_M3A' |
    jq -r '[.["@id"], .title.["@value"]] | @tsv' >> icd-11-allergens.tsv || true)
    echo $concept
done