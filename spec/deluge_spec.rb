require 'spec_helper'

describe Deluge do
  subject { Deluge.new(dummy(:host)) }

  context 'when newly created' do
    it 'is not logged in' do
      expect(subject.logged_in?).to be false
    end

    it 'uses the provided host' do
      expect(subject.host).to eq(dummy(:host))
    end
  end

  context '#login' do
    it 'sends an auth.login request' do
      VCR.use_cassette('login_success') do
        subject.login(dummy(:password))
      end

      expect(subject).to have_sent_method('auth.login')
      expect(subject).to have_sent_params([dummy(:password)])
    end

    context 'login failed' do
      before :each do
        VCR.use_cassette('login_failed') do
          @response = subject.login('sfh528ysdh4yhsg')
        end
      end

      it '#login returns false' do
        expect(@response).to be(false)
      end

      it 'does not set a session ID' do
        expect(subject.session_id).to be_nil
      end

      it 'does not report being logged in' do
        expect(subject.logged_in?).to eq(false)
      end
    end

    context 'login is successful' do
      before :each do
        VCR.use_cassette('login_success') do
          @response = subject.login(dummy(:password))
        end
      end

      it '#login returns true' do
        expect(@response).to be(true)
      end

      it 'sets the session ID' do
        expect(subject.session_id).to_not be_nil
      end

      it 'reports being logged in' do
        expect(subject.logged_in?).to eq(true)
      end
    end
  end
end
