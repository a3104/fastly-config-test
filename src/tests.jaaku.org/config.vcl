# Noticing changes to your VCL? The event log
# (https://docs.fastly.com/en/guides/reviewing-service-activity-with-the-event-log)
# in the web interface shows changes to your service's configurations and the
# change log on developer.fastly.com (https://developer.fastly.com/reference/changes/vcl/)
# provides info on changes to the Fastly-provided VCL itself.
pragma optional_param geoip_opt_in true;
pragma optional_param max_object_size 20971520;
pragma optional_param smiss_max_object_size 20971520;
pragma optional_param fetchless_purge_all 1;
pragma optional_param chash_randomize_on_pass true;
pragma optional_param default_ssl_check_cert 1;
pragma optional_param max_backends 20;
pragma optional_param customer_id "7fOCLC2X2RRXkJryQshWcP";
C!
W!
# Backends
backend F_jaaku_test {
    .between_bytes_timeout = 10s;
    .connect_timeout = 1s;
    .dynamic = true;
    .first_byte_timeout = 15s;
    .host = "tests.jaaku.org";
    .max_connections = 200;
    .port = "80";
    .share_key = "HSJ21KnV9WHmi8T1h1lkh7";
    .probe = {
        .dummy = true;
        .initial = 5;
        .request = "HEAD / HTTP/1.1"  "Host: tests.jaaku.org" "Connection: close";
        .threshold = 1;
        .timeout = 2s;
        .window = 5;
      }
}
sub vcl_deliver {
    set resp.http.AAA = "bbb";
    set resp.http.X-Original-Body = req.http.X-Request-Body;
    set resp.http.HOGE = req.body;
}
sub vcl_recv {
#--FASTLY RECV BEGIN
  if (req.restarts == 0) {
    if (!req.http.X-Timer) {
      set req.http.X-Timer = "S" time.start.sec "." time.start.usec_frac;
    }
    set req.http.X-Timer = req.http.X-Timer ",VS0";
  }
  declare local var.fastly_req_do_shield BOOL;
  set var.fastly_req_do_shield = (req.restarts == 0);
  # default conditions
  set req.backend = F_jaaku_test;
    # end default conditions
#--FASTLY RECV END
return(lookup);
}
sub vcl_fetch {
#--FASTLY FETCH BEGIN
# record which cache ran vcl_fetch for this object and when
  set beresp.http.Fastly-Debug-Path = "(F " server.identity " " now.sec ") " if(beresp.http.Fastly-Debug-Path, beresp.http.Fastly-Debug-Path, "");
# generic mechanism to vary on something
  if (req.http.Fastly-Vary-String) {
    if (beresp.http.Vary) {
      set beresp.http.Vary = "Fastly-Vary-String, "  beresp.http.Vary;
    } else {
      set beresp.http.Vary = "Fastly-Vary-String, ";
    }
  }
#--FASTLY FETCH END
return(deliver);
}
sub vcl_error {
#--FASTLY ERROR BEGIN
  if (obj.status == 801) {
     set obj.status = 301;
     set obj.response = "Moved Permanently";
     set obj.http.Location = "https://" req.http.host req.url;
     synthetic {""};
     return (deliver);
  }
  if (req.http.Fastly-Restart-On-Error) {
    if (obj.status == 503 && req.restarts == 0) {
      restart;
    }
  }
  {
    if (obj.status == 550) {
      return(deliver);
    }
  }
#--FASTLY ERROR END
}
sub vcl_miss {
#--FASTLY MISS BEGIN
# this is not a hit after all, clean up these set in vcl_hit
  unset req.http.Fastly-Tmp-Obj-TTL;
  unset req.http.Fastly-Tmp-Obj-Grace;
  {
    if (req.http.Fastly-Check-SHA1) {
       error 550 "Doesnt exist";
    }
#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END
 #;
    set req.http.Fastly-Cachetype = "MISS";
  }
#--FASTLY MISS END
return(fetch);
}
sub vcl_hit {
#--FASTLY HIT BEGIN
# we cannot reach obj.ttl and obj.grace in deliver, save them when we can in vcl_hit
  set req.http.Fastly-Tmp-Obj-TTL = obj.ttl;
  set req.http.Fastly-Tmp-Obj-Grace = obj.grace;
  {
    set req.http.Fastly-Cachetype = "HIT";
  }
#--FASTLY HIT END
return(deliver);
}
sub vcl_pipe {
#--FASTLY PIPE BEGIN
  {
#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END
    #;
    set req.http.Fastly-Cachetype = "PIPE";
    set bereq.http.connection = "close";
  }
#--FASTLY PIPE END
}
sub vcl_pass {
#--FASTLY PASS BEGIN
  {
#--FASTLY BEREQ BEGIN
    {
      {
        if (req.http.Fastly-FF) {
          set bereq.http.Fastly-Client = "1";
        }
      }
      {
        # do not send this to the backend
        unset bereq.http.Fastly-Original-Cookie;
        unset bereq.http.Fastly-Original-URL;
        unset bereq.http.Fastly-Vary-String;
        unset bereq.http.X-Varnish-Client;
      }
      if (req.http.Fastly-Temp-XFF) {
         if (req.http.Fastly-Temp-XFF == "") {
           unset bereq.http.X-Forwarded-For;
         } else {
           set bereq.http.X-Forwarded-For = req.http.Fastly-Temp-XFF;
         }
         # unset bereq.http.Fastly-Temp-XFF;
      }
    }
#--FASTLY BEREQ END
 #;
    set req.http.Fastly-Cachetype = "PASS";
  }
#--FASTLY PASS END
}
sub vcl_log {
#--FASTLY LOG BEGIN
  # default response conditions
  # sftp tests_jaaku_org
  log {"syslog "} req.service_id {" tests.jaaku.org :: "} {"{     "timestamp": ""} strftime({"%Y-%m-%dT%H:%M:%S%z"}, time.start) {"",     "client_ip": ""} req.http.Fastly-Client-IP {"",     "geo_country": ""} client.geo.country_name {"",     "geo_city": ""} client.geo.city {"",     "host": ""} if(req.http.Fastly-Orig-Host, req.http.Fastly-Orig-Host, req.http.Host) {"",     "url": ""} json.escape(req.url) {"",     "request_method": ""} json.escape(req.method) {"",     "request_protocol": ""} json.escape(req.proto) {"",     "request_body":""} json.escape(req.body) {"",     "request_referer": ""} json.escape(req.http.referer) {"",     "request_user_agent": ""} json.escape(req.http.User-Agent) {"",     "response_state": ""} json.escape(fastly_info.state) {"",     "response_status": "} resp.status {",     "response_reason": "} if(resp.response, "%22"+json.escape(resp.response)+"%22", "null") {",     "response_body_size": "} resp.body_bytes_written {",     "fastly_server": ""} json.escape(server.identity) {"",     "fastly_is_edge": "} if(fastly.ff.visits_this_service == 0, "true", "false") "   }";
#--FASTLY LOG END
}
sub vcl_hash {
#--FASTLY HASH BEGIN
  #if unspecified fall back to normal
  {
    set req.hash += req.url;
    set req.hash += req.http.host;
    set req.hash += req.vcl.generation;
    return (hash);
  }
#--FASTLY HASH END
}
