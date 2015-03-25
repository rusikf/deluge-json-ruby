require 'httparty'
require 'json'
require 'deluge/response'

##
# Uses the Deluge web UI's JSON calls to interact with deluged.
class Deluge
  ##
  # The last request that was made to the web UI.
  attr_accessor :last_request

  ##
  # The current session ID (if any), used to authenticate requests.
  attr_accessor :session_id

  ##
  # The host that we're connecting to. This is a URL in the form:
  #  http[s]://my-deluge-web-ui:port/json
  attr_accessor :host

  ##
  # The data we want back when getting all torrent info.
  UPDATE_UI_PARAMS = %w(queue name total_size state
                        progress num_seeds total_seeds
                        num_peers total_peers
                        download_payload_rate
                        upload_payload_rate eta ratio
                        distributed_copies is_auto_managed
                        time_added tracker_host save_path
                        total_done total_uploaded
                        max_download_speed max_upload_speed
                        seeds_peers_ratio)

  ##
  # Creates a new Deluge instance to connect to the given host.
  def initialize(host)
    @host = host
    @last_request = {}
    @last_id = 0
  end

  ##
  # Authenticates with the web UI by sending the given password & then connects to the first available host.
  #
  # The +password+ is set on the web UI under "Preferences" -> "Interface".
  def login(password)
    send_request('auth.login', [password])

    # Get available hosts
    hosts = send_request('web.get_hosts').result

    fail 'No hosts avilable on this Deluge host!' if hosts.nil?

    first_host_hash = hosts.first[0]

    # Connect to first available host
    send_request('web.connect', [first_host_hash])

    # Ensure we're connected
    response = send_request('web.connected')

    response.result && !session_id.nil?
  end

  ##
  # Checks for session ID (set when authentication succeeds).
  def logged_in?
    !@session_id.nil?
  end

  # Retrieves the list of current torrents.
  def torrents
    response = send_request('web.update_ui', [UPDATE_UI_PARAMS, {}])

    response.result['torrents']
  end

  # Starts downloading a torrent URL (either a path to a torrent file or a magnet link).
  def add_torrent_url(url, download_location, move_completed_path)
    params = add_torrent_params(url, download_location, move_completed_path)

    send_request('web.add_torrents', params).result
  end

  # Sends a raw JSON request to Deluge. Used by other methods to make calls (e.g. adding a new torrent).
  def send_request(method, params = [])
    @last_id += 1

    request_body = { id: @last_id, method: method, params: params }.to_json
    request = HTTParty.post(@host, body: request_body, headers: headers(@session_id))
    response = Response.new(request)

    @session_id = response.session_id unless response.session_id.nil?

    @last_request = { method: method, params: params }

    response
  end

  private

  # Creates the header dictionary used for requests (contains the session ID used for authentication).
  def headers(session_id)
    { 'Cookie' => "_session_id=#{session_id}" }
  end

  # Assembles the parameters used when adding a torrent URL.
  def add_torrent_params(url, download_location, move_completed_path)
    ['0' => {
      options: {
        add_paused: false, compact_allocation: false, download_location: download_location,
        file_priorities: [], max_connections: -1, max_download_speed: -1,
        max_upload_slots: -1, max_upload_speed: -1, move_completed: false,
        move_completed_path: move_completed_path, prioritize_first_last_pieces: false
      },
      path: url
    }]
  end
end
