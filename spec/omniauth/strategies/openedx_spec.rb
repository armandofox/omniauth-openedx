require 'spec_helper'

describe OmniAuth::Strategies::OpenEdX do
  let(:access_token) { stub('AccessToken', :options => {}) }
  let(:parsed_response) { stub('ParsedResponse') }
  let(:response) { stub('Response', :parsed => parsed_response) }

  let(:site)          { 'https://some.other.site.com/api/v3' }
  let(:authorize_url) { 'https://some.other.site.com/login/oauth/authorize' }
  let(:token_url)     { 'https://some.other.site.com/login/oauth/access_token' }
  let(:subject2) do
    OmniAuth::Strategies::OpenEdX.new('EDX_KEY', 'EDX_SECRET',
                                     {
                                         :client_options => {
                                             :site => site,
                                             :authorize_url => authorize_url,
                                             :token_url => token_url
                                         }
                                     }
    )
  end

  subject do
    OmniAuth::Strategies::OpenEdX.new({})
  end

  before(:each) do
    subject.stub!(:access_token).and_return(access_token)
  end

  context 'client options' do
    it 'should have correct site' do
      subject.options.client_options.site.should eq('https://accounts.edx.org')
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://accounts.edx.org/oauth2/v1/auth')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://accounts.edx.org/oauth2/v1/token')
    end

    describe 'should be overrideable' do
      it 'for site' do
        subject2.options.client_options.site.should eq(site)
      end

      it 'for authorize url' do
        subject2.options.client_options.authorize_url.should eq(authorize_url)
      end

      it 'for token url' do
        subject2.options.client_options.token_url.should eq(token_url)
      end
    end
  end

  context '#raw_info' do
    it 'should use relative paths' do
      access_token.should_receive(:get).with('https://api.edx.org/api/externalBasicProfiles.v1?q=me').and_return(response)
      subject.raw_info.should eq(parsed_response)
    end
  end
end
