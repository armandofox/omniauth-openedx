require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OpenEdX < OmniAuth::Strategies::OAuth2
      option :name, 'openedx'

      option :client_options, {
          site: 'https://courses.edx.org/oauth2/login',
          authorize_url: 'https://courses.edx.org/oauth2/authorize',
          token_url: 'https://courses.edx.org/oauth2/access_token'
      }

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('https://courses.edx.org/oauth2/user_info').parsed
      end
    end
  end
end
