module Requests
  module JsonHelpers
    def json
      @json = JSON.parse(response.body)
    end

    def access_token_header(access_token = current_access_token)
      { "HTTP_AUTHORIZATION" => "Token token=\"" << access_token << "\"" }
    end

    def access_token_path(path, access_token = current_access_token)
      access_token_str = "?access_token=" << access_token
      newPath = path.dup
      unless path.include? "?access_token="
        newPath << access_token_str
      end
      newPath
    end
  end
end
