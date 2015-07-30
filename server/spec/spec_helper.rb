ENV['RACK_ENV'] = 'test'

require 'dotenv'
Dotenv.load

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/app/initializers/'
    add_group 'Models', 'app/models'
    add_group 'Mutations', 'app/mutations'
    add_group 'Api', 'app/routes'
    add_group 'Helpers', 'app/helpers'
    add_group 'Services', 'app/services'
    add_group 'Workers', 'app/workers'
  end
end

require 'webmock/rspec'
require_relative '../app/boot'
require_relative '../server'
require 'rack/test'
require 'mongoid-rspec'

Celluloid.logger = nil

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include Rack::Test::Methods

  def app
    Server
  end

  config.before(:suite) do
    MongoPubsub.start!(PubsubChannel.collection)
    sleep 0.1 until Mongoid.default_session.collection_names.include?(PubsubChannel.collection.name)
  end

  config.before(:each) do
    stub_request(:get, /https:\/\/discovery.etcd.io\/new.*/).to_return(
      body: 'https://discovery.etcd.io/fake'
    )
  end

  config.after(:each) do
    Mongoid.default_session.collections.each do |collection|
      unless collection.name.include?('system.')
        collection.find.remove_all unless collection.capped?
      end
    end
  end

  def response
    last_response
  end

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

Dir[__dir__ + '/support/*.rb'].each {|file| require file }
