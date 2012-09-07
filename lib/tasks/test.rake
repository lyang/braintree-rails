require "rake/testtask"

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test/unit"
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test/unit"
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
  end
  
  desc "Run all tests"
  task :all => ["unit", "integration"]
end