require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Geeklist < OmniAuth::Strategies::OAuth
      option :name, 'geeklist'

      option :client_options, {
        :site => 'http://geekli.st',
        :request_token_url => 'http://api.geekli.st/v1/oauth/request_token',
        :authorize_path => '/oauth/authorize',
        :access_token_url => 'http://api.geekli.st/v1/oauth/access_token'
      }

      def request_phase
        super
      end
      
      def callback_phase
        super
      end

      uid { raw_info['data']['id'] }

      info do
        {
          :nickname => raw_info['data']['screen_name'],
          :name => raw_info['data']['name'],
          :email => raw_info['data']['email'],
          :location => raw_info['data']['location'],
          :image => raw_info['data']['avatar']['small'],
          :description => raw_info['data']['bio'],
          :urls => {
            'Website' => raw_info['data']['blog_url'],
            'Geeklist' => 'http://geekli.st/' + raw_info['data']['screen_name'],
          }
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/v1/user').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
      
    end
  end
end