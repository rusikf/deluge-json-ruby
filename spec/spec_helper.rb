require 'deluge'
require 'pry'
require 'rspec'
require 'vcr'
require 'yaml'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec::Matchers.define :have_sent_method do |expected|
  match do |deluge|
    deluge.last_request[:method] && deluge.last_request[:method] == expected
  end
end

RSpec::Matchers.define :have_sent_params do |expected|
  match do |deluge|
    deluge.last_request[:params] && deluge.last_request[:params].sort == expected.sort
  end
end

# Dummy values for testing
def dummy(key)
  { host: 'http://localhost:8080/json', password: 'password1', method: 'auth.login' }[key]
end

# Create a Response that parses the given body
def mock_response(body, headers = nil)
  raw_response = instance_double('HTTPartyResponse')
  allow(raw_response).to receive(:body).and_return(body)
  allow(raw_response).to receive(:headers).and_return(headers)

  Response.new(raw_response)
end

def load_fixtures(path)
  YAML.load_file(path)
end
