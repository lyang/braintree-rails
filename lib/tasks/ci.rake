require 'coveralls/rake/task'

namespace :ci do
  Coveralls::RakeTask.new
  desc "Run all specs in Travis CI"
  task :travis => ["spec:all", "coveralls:push"]
end
