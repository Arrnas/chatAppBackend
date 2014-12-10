module V1
  class LoginController < ApplicationController
    def new
    end

    api :POST, "/v1/login", "Get access token"
    error :code => 401
    param :username, String, :required => true
    param :password, String, :required => true
    def create
      user = User.find_by_username(params[:username])
      if user && user.authenticate(params[:password])
        render json: { "access_token" => user.access_token }, status:200
      else
        render json: {}, status:401
      end
    end
  end
end
