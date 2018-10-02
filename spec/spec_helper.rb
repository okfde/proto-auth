require './app'
require 'rack/test'
require 'rspec-html-matchers'
require 'coveralls'

Coveralls.wear!

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
end

RSpec::Matchers.define(:redirect_to) do |url|
  match do |response|
    response.status == 302 && response.location.match(url)
  end
end
