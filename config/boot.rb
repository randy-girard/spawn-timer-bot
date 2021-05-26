ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

Bundler.require

require 'date'
require 'active_support/time'

ENV['TZ'] ||= 'Eastern Time (US & Canada)'
ENV["RACK_ENV"] ||= "development"

Dotenv.load(".env.local", ".env.#{ENV["RACK_ENV"]}", ".env")

include DOTIW::Methods

require_relative 'initializers/constants'
require_relative 'initializers/sequel'

require_relative '../app/models/timer'
require_relative '../app/models/setting'
require_relative '../app/models/tod'
