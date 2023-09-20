require 'fastly'
require 'json'

CONVERT_CONFIG = {
  "main" => "tests.jaaku.org"
}
TOKEN = ENV["TOKEN"]

Fastly.configure do |config|
  config.api_token = TOKEN
end

def load_config(base_dir, file_type)
  file = File.read("#{base_dir}/#{file_type}.json")
  JSON.parse(file).map { |x| x.transform_keys(&:to_sym) }
end

def apply_backend_config(base_dir, version)
  api_instance = Fastly::BackendApi.new
  config_data = load_config(base_dir, "backend")
  config_data.each do |config|
    config[:version_id] = version
    api_instance.create_backend(config)
  end
end

def apply_config(api_instance, base_dir, file_type, version)
  config_data = load_config(base_dir, file_type)
  config_data.each do |config|
    config[:version_id] = version
    api_instance.send("create_#{file_type}", config)
  end
end

def apply_acl_entries(api_instance, base_dir, acl_id, version)
  entry_config = load_config(base_dir, "entries/#{acl_id}")
  entry_config.each do |entry|
    entry[:version_id] = version
    entry[:acl_id] = acl_id
    entry[:acl_entry] = { ip: entry[:ip], subnet: entry[:subnet] || 32 }
    entry.delete(:negated)
    begin
      api_instance.create_acl_entry(entry)
    rescue => e
      p e
    end
  end
end

begin
  service_name = ARGV[0]
  base_dir = "src/#{service_name}/"
  service_id = Fastly::ServiceApi.new.list_services.find { |service| service.name == service_name }.id
  version = Fastly::VersionApi.new.create_service_version(service_id: service_id).number

  apply_backend_config(base_dir, version)
  apply_config(Fastly::HealthcheckApi.new, base_dir, "healthcheck", version)

  # Special case for acl because it has entries associated
  acl_instance = Fastly::AclApi.new
  acl_entry_instance = Fastly::AclEntryApi.new
  apply_config(acl_instance, base_dir, "acl", version) do |instance, config|
    acl_id = instance.create_acl(config).id
    apply_acl_entries(acl_entry_instance, base_dir, acl_id, version)
  end

  # Add similar calls for other APIs as shown above
  # For example:
  # apply_config(Fastly::ConditionApi.new, base_dir, "condition", version)

rescue => e
  p e
end
