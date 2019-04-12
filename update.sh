#!/bin/sh

CURL_UPDATER() { 
        TZ=GMT /usr/bin/curl "${1:-geolite.maxmind.com}" --time-cond "$(stat --printf="%Y\n" "${2:-file.tmp}" 2>/dev/null | TZ=GMT LANG=us awk '{print strftime("%c", $1); }')" -L -k --connect-timeout 10 --max-time 10 --remote-time -o "${3:-${2:-file.tmp}}" -s -w "%{http_code}\n" 2>/dev/null
}

COUNTRY=$(CURL_UPDATER "https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country-CSV.zip"  GeoLite2-Country-CSV.zip)
GEO_ASN=$(CURL_UPDATER "https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip"      GeoLite2-ASN-CSV.zip)

if [ "$COUNTRY" -eq 200 ]; then
        ./geolite2legacy.py --debug -i ./GeoLite2-Country-CSV.zip -f ./geoname2fips.csv -o ./GeoIP.dat
fi

if [ "$GEO_ASN" -eq 200 ]; then
        ./geolite2legacy.py --debug -i ./GeoLite2-ASN-CSV.zip     -f ./geoname2fips.csv -o ./GeoLite2-ASN.dat
fi
