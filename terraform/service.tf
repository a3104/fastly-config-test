resource "fastly_service_acl_entries" "generated_by_ip_block_list" {
   manage_entries = true
  acl_id     = each.value.acl_id
  service_id = fastly_service_vcl.service.id

  entry {
    comment = "test"
    ip      = "192.168.0.1"
    negated = false
  }

  for_each = {
    for a in fastly_service_vcl.service.acl : a.name => a if a.name == "Generated_by_IP_block_list"
  }
}
resource "fastly_service_acl_entries" "generated_by_ip_block_list2" {
  acl_id     = each.value.acl_id
  service_id = fastly_service_vcl.service.id

  for_each = {
    for a in fastly_service_vcl.service.acl : a.name => a if a.name == "Generated_by_IP_block_list2"
  }
}
resource "fastly_service_vcl" "service" {
  activate = false
  default_host       = "tests.jaaku.org"
  default_ttl        = 3600
  http3              = true
  name               = "tests.jaaku.org"
  stale_if_error     = false
  stale_if_error_ttl = 43200

  acl {
    force_destroy = false
    name          = "Generated_by_IP_block_list"
  }
  acl {
    force_destroy = false
    name          = "Generated_by_IP_block_list2"
  }

  backend {
    address               = "tests.jaaku.org"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    keepalive_time        = 0
    max_conn              = 200
    name                  = "jaaku-test"
    port                  = 80
    ssl_check_cert        = true
    use_ssl               = false
    weight                = 100
  }

  cache_setting {
    name      = "aaa"
    stale_ttl = 30
    ttl       = 100
  }

  condition {
    name      = "Generated by IP block list"
    priority  = 0
    statement = "client.ip ~ Generated_by_IP_block_list"
    type      = "REQUEST"
  }
  condition {
    name      = "Generated by synthetic response for 404 page"
    priority  = 0
    statement = "beresp.status == 404"
    type      = "CACHE"
  }
  condition {
    name      = "Generated by synthetic response for 503 page"
    priority  = 0
    statement = "beresp.status == 503"
    type      = "CACHE"
  }

  domain {
    name = "hoge.jaaku.org"
  }

  header {
    action        = "set"
    destination   = "http.zzzz"
    ignore_if_set = false
    name          = "header"
    priority      = 10
    source        = "\"hoge\""
    type          = "response"
  }

  healthcheck {
    check_interval    = 60000
    expected_response = 200
    headers           = []
    host              = "tests.jaaku.org"
    http_version      = "1.1"
    initial           = 1
    method            = "HEAD"
    name              = "aaa"
    path              = "/?a=b"
    threshold         = 1
    timeout           = 5000
    window            = 2
  }
  healthcheck {
    check_interval    = 60000
    expected_response = 200
    headers           = []
    host              = "tests.jaaku.org"
    http_version      = "1.1"
    initial           = 1
    method            = "HEAD"
    name              = "top page health check"
    path              = "/"
    threshold         = 1
    timeout           = 5000
    window            = 2
  }

  product_enablement {
    brotli_compression = false
    domain_inspector   = false
    image_optimizer    = false
    origin_inspector   = false
    websockets         = false
  }

  response_object {
    content_type      = "text/html"
    name              = "Generated by IP block list"
    request_condition = "Generated by IP block list"
    response          = "Forbidden"
    status            = 403
    content           = file("content/service/generated_by_ip_block_list.txt")
  }
  response_object {
    cache_condition = "Generated by synthetic response for 404 page"
    content         = file("content/service/generated_by_synthetic_response_for_404_page.txt")
    content_type    = "text/html"
    name            = "Generated by synthetic response for 404 page"
    response        = "Not Found"
    status          = 404
  }
  response_object {
    cache_condition = "Generated by synthetic response for 503 page"
    content         = file("content/service/generated_by_synthetic_response_for_503_page.txt")
    content_type    = "text/html"
    name            = "Generated by synthetic response for 503 page"
    response        = "Service Unavailable"
    status          = 503
  }

  snippet {
    content  = file("vcl/service/snippet_hoge.vcl")
    name     = "hoge"
    priority = 100
    type     = "init"
  }
  comment = ""
}
