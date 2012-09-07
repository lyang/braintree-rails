require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))
config = File.join(TEST_PATH, "config/braintree_auth.yml")
if auth = YAML.load_file(config)
  Braintree::Configuration.environment = :sandbox
  Braintree::Configuration.merchant_id = auth["merchant_id"]
  Braintree::Configuration.public_key = auth["public_key"]
  Braintree::Configuration.private_key = auth["private_key"]
else
  puts "*" * 80
  puts "You need to provide real credentials in #{config} to run integration tests"
  puts "*" * 80
  exit(0)
end