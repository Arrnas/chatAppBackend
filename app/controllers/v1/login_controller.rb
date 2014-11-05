module V1
  class LoginController < ApplicationController
    def new
    end

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
