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

  def raw_info_hash
    {
      'name' => 'John Smith',
      'email' => 'smith@example.com'
    }
  end

  subject do
    OmniAuth::Strategies::OpenEdX.new({})
  end

  before(:each) do
    subject.stub(:access_token).and_return(access_token)
  end

  context 'client options' do
    it 'should have correct provider name' do
      expect(subject.options.name).to eq('openedx')
    end

    it 'should have correct site' do
      subject.options.client_options.site.should eq('https://courses.edx.org/oauth2/login')
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://courses.edx.org/oauth2/authorize')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://courses.edx.org/oauth2/access_token')
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
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'should return user name' do
      expect(subject.info[:name]).to eq(raw_info_hash['name'])
    end

    it 'should return user email' do
      expect(subject.info[:email]).to eq(raw_info_hash['email'])
    end

    it 'should use relative paths' do
      access_token.should_receive(:get).with('https://courses.edx.org/oauth2/user_info').and_return(response)
      subject.raw_info.should eq(parsed_response)
    end
  end
end
