require './app'
require 'rspec'
require 'rack/test'
require 'rspec-html-matchers'
require 'coveralls'

Coveralls.wear!

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
  config.include RSpecMixin
end

RSpec::Matchers.define(:redirect_to) do |url|
  match do |response|
    response.status == 302 && response.location.match(url)
  end
end
