# A response from the deluged daemon
class Response
  attr_accessor :result, :error, :session_id

  # Takes a raw httparty response & parses out useful info
  def initialize(raw_response)
    @headers = raw_response.headers
    @session_id = parse_session_id

    body = JSON.parse(raw_response.body)

    @result = body['result']
    @error = body['error']
  end

  private

  def parse_session_id
    return if @headers.nil?

    cookies_hash = HTTParty::CookieHash.new
    @headers.each { |header, value| cookies_hash.add_cookies(value) if header.downcase == 'set-cookie' }

    cookies_hash[:_session_id]
  end
end
