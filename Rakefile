require File.expand_path(File.join(File.dirname(__FILE__), 'lib/env'))
Dir.glob(File.join(ROOT_PATH, 'lib/tasks/*.rake')).each { |file| import file }

task :default => ['test:all']