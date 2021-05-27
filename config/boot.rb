ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

Bundler.require

require 'date'
require 'active_support/time'

Dotenv.load(".env.local", ".env.#{ENV["RACK_ENV"]}", ".env")

ENV['TZ'] ||= 'Eastern Time (US & Canada)'
ENV["RACK_ENV"] ||= "development"

include DOTIW::Methods

require_relative 'initializers/constants'
require_relative 'initializers/sequel'

require_relative '../app/models/timer'
require_relative '../app/models/setting'
require_relative '../app/models/tod'

require_relative '../lib/time_parser'
require_relative '../lib/argument_parser'
