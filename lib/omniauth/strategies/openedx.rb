require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OpenEdX < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'profile'

      option :name, 'openedx'

      option :client_options, {
          site: 'https://e0d-berkeley.sandbox.edx.org/oauth2/login',
          authorize_url: 'https://e0d-berkeley.sandbox.edx.org/oauth2/authorize',
          token_url: 'https://e0d-berkeley.sandbox.edx.org/oauth2/access_token'
      }

      option :authorize_options, [:scope]

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('https://e0d-berkeley.sandbox.edx.org/oauth2/user_info').parsed
      end

      def redirect_params
        if options.key?(:callback_path) || OmniAuth.config.full_host
          {:redirect_uri => callback_url}
        else
          {}
        end
      end

      def token_params
        params = super.to_hash(:symbolize_keys => true) \
          .merge(:headers => { 'Authorization' => "Bearer #{client.secret}" })

        redirect_params.merge(params)
      end

      def build_access_token
        auth_code = request.params['code']
        client.auth_code.get_token(auth_code, token_params)
      end

      def callback_phase
        with_authorization_code! do
          super
        end
      rescue NoAuthorizationCodeError => e
        fail(:no_authorization_code, e)
      end

      def authorize_params
        super.tap do |params|
          %w[scope].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def with_authorization_code! 
        if request.params.key?('code')
          yield
        else
          raise NoAuthorizationCodeError
        end
      end
    end
  end
end
