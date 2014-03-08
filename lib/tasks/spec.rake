require 'rspec/core/rake_task'

namespace :spec do
  desc "Run unit specs"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = 'spec/unit/**/*_spec.rb'
    t.verbose = true
  end

  desc "Run integration specs"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = 'spec/integration/**/*_spec.rb'
    t.verbose = true
  end

  desc "Run all specs"
  task :all => [:unit, :integration]
end
