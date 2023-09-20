if [ -z "$1" ]; then
  VERSION=`curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version | jq -r '.[] | select(.active == true) | .number'`
else
  VERSION="$1"
fi

SERVICEFQDN=`curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/backend  | jq '.[0].address' |  sed s/\"//g `
echo $SERVICEFQDN
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/backend  | jq 'map(del(.updated_at))' | sed "s/$SERVICEFQDN/\$SERVICEFQDN/g" > backend.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/apex-redirects  | jq 'map(del(.updated_at))' > apex-redirects.json
 #curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/boilerplate  | jq 'map(del(.updated_at))' > boilerplate.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/condition  | jq 'map(del(.updated_at))' > condition.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/gzip  | jq 'map(del(.updated_at))' > gzip.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/domain  | jq 'map(del(.updated_at))' > domain.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/healthcheck  | jq 'map(del(.updated_at))' > healthcheck.json
 #curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/package  | jq 'map(del(.updated_at))' > package.json

 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/settings  | jq > settings.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/request_settings  | jq 'map(del(.updated_at))' > request_settings.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/response_object  | jq 'map(del(.updated_at))' > response_object.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/vcl  | jq 'map(del(.updated_at))' > vcl.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/cache_settings  | jq 'map(del(.updated_at))' > cache_settings.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/header  | jq 'map(del(.updated_at))'  > header.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/http3  | jq  > http3.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/rate-limiters  | jq 'map(del(.updated_at))' > rate-limiters.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/resource  | jq 'map(del(.updated_at))' > resource.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/acl  | jq 'map(del(.updated_at))'  > acl.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/entries  | jq 'map(del(.updated_at))'  > entries.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/logging/gcs  | jq  '.[0].secret_key = "$GCSPRIVATEKEY"'  | jq 'del(.updated_at)'> gcs.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/dictionary  | jq 'map(del(.updated_at))'  > dictionary.json
 #curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/image_optimizer  | jq 'map(del(.updated_at))' > image_optimizer.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/datacenters  | jq 'map(del(.updated_at))'  > datacenters.json

 #curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/capabilities  | jq 'map(del(.updated_at))'  > capabilities.json

 cat acl.json | jq -r ".[].id" | awk '{print " curl   -H \x22""Fastly-Key: $TOKEN\x22 https://api.fastly.com/service/$SERVICEID/acl/"$1"/entries  | jq \x27map(del(.updated_at))\x27  > entries/"$1".json"} ' | bash
curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/snippet | jq 'map(del(.updated_at))' > snippet.json
echo "end"
