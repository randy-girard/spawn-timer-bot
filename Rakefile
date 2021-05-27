require_relative "config/boot"

__DIR__ = File.dirname(__FILE__)
Dir.glob("#{__DIR__}/tasks/*.rake").each do |rake_file|
  import rake_file
end

task :environment do
end

