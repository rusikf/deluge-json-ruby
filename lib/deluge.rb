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
  #
  # @param host See {Deluge#host}.
  def initialize(host)
    @host = host
    @last_request = {}
    @last_id = 0
  end

  ##
  # Authenticates with the web UI by sending the given password & then connects to the first available host.
  #
  # @param password Set on the web UI under "Preferences" -> "Interface".
  # @param connect_to The host to connect to, in the form *hostname:port*. If nil, uses the first one found.
  def login(password, connect_to = nil)
    login_req = send_request('auth.login', [password])

    return false if login_req.nil? || login_req.result == false

    # Get available hosts
    hosts = send_request('web.get_hosts').result

    fail 'No hosts available on this Deluge web UI!' if hosts.nil?

    host = hosts[0] # Default to first host found

    # Find a matching host, if given
    if connect_to
      host = hosts.find { |raw_host| connect_to == "#{raw_host[1]}:#{raw_host[2]}" } || nil

      fail "No host matching '#{connect_to}' was found!" if host.nil?
    end

    send_request('web.connect', [host[0]])

    # Ensure we're connected
    response = send_request('web.connected')

    response.result && !session_id.nil?
  end

  ##
  # Checks for session ID (set when authentication succeeds).
  def logged_in?
    !@session_id.nil?
  end

  ##
  # Retrieves the list of current torrents.
  def torrents
    response = send_request('web.update_ui', [UPDATE_UI_PARAMS, {}])

    response.result['torrents']
  end

  ##
  # Gets the files for a torrent hash.
  def torrent_files(torrent_hash)
    response = send_request('web.get_torrent_files', [torrent_hash])

    parse_files(nil, response.result)
  end

  ##
  # Get basic configuration values, useful for getting the default file save path
  def config_values
    send_request('core.get_config_values', [%w(add_paused move_completed download_location max_connections_per_torrent
                                               max_download_speed_per_torrent compact_allocation move_completed_path
                                               max_upload_slots_per_torrent max_upload_speed_per_torrent
                                               prioritize_first_last_pieces)]).result
  end

  ##
  # Starts downloading a torrent URL (either a path to a torrent file or a magnet link).
  #
  # @param url (see #add_torrent_params)
  # @param download_location (see #add_torrent_params)
  # @param move_completed_path (see #add_torrent_params)
  def add_torrent_url(url, download_location, move_completed_path)
    params = add_torrent_params(url, download_location, move_completed_path)

    send_request('web.add_torrents', params).result
  end

  ##
  # Sends a raw JSON request to Deluge. Used by other methods to make calls (e.g. adding a new torrent).
  #
  # @param method The web UI method, e.g. 'web.update_ui'. Can be determined by viewing traffic sent by a browser.
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

  ##
  # Gets the files and folders in the given directory and all subdirectories.
  def parse_files(base_path, raw_data)
    # Return the parsed info if a file
    return torrent_file_hash(raw_data) if raw_data['type'] == 'file'

    parsed_directories = []
    parsed_files = []

    # If a directory, parse the contents
    raw_data['contents'].each do |path, item|
      if item['type'] == 'dir'
        parsed_directories << parse_files(path, item)
      else
        parsed_files << torrent_file_hash(path, item)
      end
    end

    { name: base_path, files: parsed_files, directories: parsed_directories }
  end

  ##
  # Takes the raw data provided for each torrent file and
  # returns a sensibly typed hash.
  def torrent_file_hash(name, raw_data)
    {
      name: name,
      path: raw_data['path'],
      size: raw_data['size'].to_i,
      progress: raw_data['progress'].to_f * 100
    }
  end

  ##
  # Creates the header dictionary used for requests (contains the session ID used for authentication).
  #
  # @param session_id Used for authentication
  def headers(session_id)
    { 'Cookie' => "_session_id=#{session_id}" }
  end

  ##
  # Assembles the parameters used when adding a torrent URL.
  #
  # @param url The torrent or magnet URL
  # @param download_location The directory to place the torrent's file(s) in
  # @param move_completed_path The path to move the torrent to, once complete (if applicable)
  def add_torrent_params(url, download_location, move_completed_path)
    [[{
      path: url,
      options: {
        add_paused: false, compact_allocation: false, download_location: download_location,
        file_priorities: [], max_connections: -1, max_download_speed: -1,
        max_upload_slots: -1, max_upload_speed: -1, move_completed: false,
        move_completed_path: move_completed_path, prioritize_first_last_pieces: false
      }
    }]]
  end
end
