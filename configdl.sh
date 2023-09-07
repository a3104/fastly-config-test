VERSION=`curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version | jq -r '.[] | select(.active == true) | .number'`
SERVICEFQDN=`curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/backend  | jq '.[0].address' | sed s/\"//g `
curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/backend  | jq | sed "s/$SERVICEFQDN/\$SERVICEFQDN/g" > backend.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/apex-redirects  | jq > apex-redirects.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/boilerplate  | jq > boilerplate.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/condition  | jq > condition.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/gzip  | jq > gzip.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/healthcheck  | jq > healthcheck.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/package  | jq > package.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/request_settings  | jq > request_settings.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/response_object  | jq > response_object.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/vcl  | jq > vcl.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/cache_settings  | jq > cache_settings.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/header  | jq > header.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/http3  | jq > http3.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/rate-limiters  | jq > rate-limiters.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/resource  | jq > resource.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/acl  | jq > acl.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/logging/gcs  | jq  '.[0].secret_key = "$GCSPRIVATEKEY"' > gcs.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/dictionary  | jq > dictionary.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/image_optimizer  | jq > image_optimizer.json
 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/datacenters  | jq > datacenters.json

 curl   -H "Fastly-Key: $TOKEN" https://api.fastly.com/service/$SERVICEID/version/$VERSION/capabilities  | jq > capabilities.json
