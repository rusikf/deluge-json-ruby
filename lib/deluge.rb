require 'httparty'
require 'json'
require 'deluge/response'

# Uses the Deluge web ui's JSON calls to interact with deluged
class Deluge
  attr_accessor :last_request, :session_id, :host

  # Creates a new deluge instance which will connect to the given host
  def initialize(host)
    @host = host
    @last_request = {}
    @last_id = 0
  end

  def login(password)
    response = send_request('auth.login', [password])

    response.result && !session_id.nil?
  end

  def logged_in?
    false
  end

  # Sends a JSON request to Deluge
  def send_request(method, params)
    @last_id += 1

    request_body = { id: @last_id, method: method, params: params }.to_json
    response = Response.new(HTTParty.post(@host, body: request_body))

    @session_id ||= response.session_id

    @last_request = { method: method, params: params }

    response
  end
end
