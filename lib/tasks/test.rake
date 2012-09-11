require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'minitest/autorun'
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'minitest/autorun'
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:all) do |t|
    t.libs << 'minitest/autorun'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
end