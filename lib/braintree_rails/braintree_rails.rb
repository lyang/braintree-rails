module BraintreeRails
  extend ActiveSupport::Autoload
  Dir.chdir(File.dirname(__FILE__)) do
    eager_autoload do
      Dir.glob("*.rb").each do |file|
        autoload file.chomp(".rb").camelize.to_sym
      end
    end
  end
end
