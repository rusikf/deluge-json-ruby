require 'spec_helper'

describe Response do
  before :each do
    @fixtures ||= load_fixtures('fixtures/response.yml')
    @response = mock_response(@fixtures['body_no_error'])
  end

  context '#new' do
    it 'parses out the result' do
      expect(@response.result).to be(true)
    end

    it 'identifies a null error respones (no error)' do
      expect(@response.error).to be_nil
    end

    it 'parses errors correctly' do
      @response = mock_response(@fixtures['body_with_error'])

      expect(@response.error).to_not be_nil
      expect(@response.error['message']).to eq('Not authenticated')
      expect(@response.error['code']).to eq(1)
    end

    it 'reads the session ID from the headers' do
      @response = mock_response(@fixtures['body_no_error'], @fixtures['headers_with_session'])

      expect(@response.session_id).to eq('85caf1e46dd96117011c50b556e61c3b2183')
    end

    it 'does not read a session ID if one is not present' do
      @response = mock_response(@fixtures['body_no_error'], @fixtures['headers_no_session'])

      expect(@response.session_id).to be_nil
    end
  end
end
