require 'fileutils'
require 'tmpdir'
require 'rspec'
require 'rack/test'

ENV["RACK_ENV"] = "test"

load "bin/haml-server"

RSpec.configure do |config|

  config.include Rack::Test::Methods

end
