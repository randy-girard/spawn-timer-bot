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
require_all 'config/initializers'
require_all 'app'
