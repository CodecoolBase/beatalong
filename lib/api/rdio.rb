require 'api/base'

module Api
  class Rdio
    include ::Api::Base

    base_uri 'https://services.rdio.com/api/1/'
    format :json

    def search(entity)
    end

    def find(identity)
      params = {
        url: identity.id,
        method: 'getObjectFromUrl',
        access_token: token
      }

      response = self.class.post(
        "",
        body: params
      )

      format_result(response.parsed_response["result"], kind: identity.kind)
    end

    def format_result(result, kind:)
      pe = ProviderEntity.new({
        kind: kind,
        artist: kind == 'artist' ? result['name'] : result['artist'],
        album: kind == 'album' ? result['name'] : result['album'],
        track: kind == 'track' ? result['name'] : nil,
        url: result['shortUrl'],
        cover_image_url: result['dynamicIcon'],
      })
    end

    private

    def token
      @token ||= nil
      return @token if @token

      auth = {
        username: "ccon3zw2gje3vfth5w4qa5i46e",
        password: "nTkxdCl0dxjQbDjrlR0q1Q"
      }
      response = self.class.post(
        "https://services.rdio.com/oauth2/token",
        body: {
          grant_type: 'client_credentials'
        },
        basic_auth: auth
      )

      @token = response.parsed_response["access_token"]
    end

  end
end
